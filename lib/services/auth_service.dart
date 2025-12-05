import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class AuthService {
  // Lazy initialization - only access Firebase when needed
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;

  FirebaseAuth get _authInstance {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  FirebaseFirestore get _firestoreInstance {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  FirebaseStorage get _storageInstance {
    _storage ??= FirebaseStorage.instance;
    return _storage!;
  }

  // Check if Firebase is initialized
  bool get _isFirebaseInitialized {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user
  User? get currentUser {
    if (!_isFirebaseInitialized) return null;
    try {
      return _authInstance.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Auth state stream (fires on login/logout)
  Stream<User?> get authStateChanges {
    if (!_isFirebaseInitialized) {
      return Stream.value(null);
    }
    try {
      return _authInstance.authStateChanges();
    } catch (e) {
      return Stream.value(null);
    }
  }

  // User changes stream (fires on user data changes like email, displayName, etc.)
  Stream<User?> get userChanges {
    if (!_isFirebaseInitialized) {
      return Stream.value(null);
    }
    try {
      return _authInstance.userChanges().asyncMap((user) async {
        // Sync Firebase Auth data to Firestore when user data changes
        if (user != null) {
          await _syncUserDataToFirestore(user);
        }
        return user;
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  // Sync user data from Firebase Auth to Firestore
  Future<void> _syncUserDataToFirestore(User user) async {
    if (!_isFirebaseInitialized) return;

    try {
      // Get current Firestore data to preserve fields like profile_image_url
      final currentUserData = await getCurrentUserData();
      
      // Prepare update data
      Map<String, dynamic> updateData = {
        'email': user.email ?? '',
        'display_name': user.displayName ?? '',
      };

      // Preserve profile_image_url if it exists
      if (currentUserData?.profileImageUrl != null) {
        updateData['profile_image_url'] = currentUserData!.profileImageUrl;
      }

      // Update Firestore with latest data from Firebase Auth
      await _firestoreInstance
          .collection('users')
          .doc(user.uid)
          .update(updateData);
    } catch (e) {
      // Silently fail - don't throw error for background sync
      // This is just to keep Firestore in sync with Firebase Auth
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }

    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await _authInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.updateProfile(displayName: displayName);
      await userCredential.user?.reload();

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Create user document in Firestore
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestoreInstance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toFirestore());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }

    try {
      UserCredential userCredential = await _authInstance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload user to get latest email verification status
      await userCredential.user?.reload();
      final user = _authInstance.currentUser;

      // Check if email is verified
      if (user != null && !user.emailVerified) {
        await signOut();
        throw Exception('Please verify your email before signing in. Check your inbox for the verification link.');
      }

      // Get user data from Firestore
      DocumentSnapshot doc = await _firestoreInstance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (!_isFirebaseInitialized) return;
    try {
      await _authInstance.signOut();
    } catch (e) {
      // Ignore errors if Firebase isn't initialized
    }
  }

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    if (!_isFirebaseInitialized || currentUser == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestoreInstance.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }

    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      if (user.emailVerified) {
        throw Exception('Email is already verified.');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Check if email is verified
  Future<bool> checkEmailVerification() async {
    if (!_isFirebaseInitialized) {
      return false;
    }

    try {
      final user = currentUser;
      if (user == null) {
        return false;
      }

      // Reload user to get latest verification status
      await user.reload();
      return user.emailVerified;
    } catch (e) {
      return false;
    }
  }

  // Get current user as UserModel
  Future<UserModel?> getCurrentUserModel() async {
    if (!_isFirebaseInitialized || currentUser == null) {
      return null;
    }

    try {
      return await getCurrentUserData();
    } catch (e) {
      return null;
    }
  }

  // Re-authenticate user (required for sensitive operations like email change)
  Future<void> reauthenticateUser(String password) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }

    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      if (user.email == null) {
        throw Exception('User email is not available.');
      }

      // Create credential with current email and password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      // Re-authenticate user
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Re-authentication failed: $e');
    }
  }

  // Update user profile (nama profile/display name)
  Future<void> updateProfile({
    required String displayName,
    String? email,
    String? password, // Password required if email is being changed
  }) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }

    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      // Update display name in Firebase Auth
      await user.updateDisplayName(displayName);
      await user.updateProfile(displayName: displayName);
      
      // Update email if provided and different from current email
      await user.reload();

      // Get current user data to preserve existing fields (like profile_image_url)
      final currentUserData = await getCurrentUserData();
      
      // Update in Firestore
      Map<String, dynamic> updateData = {
        'display_name': displayName,
      };
      
      // Preserve profile_image_url if it exists
      if (currentUserData?.profileImageUrl != null) {
        updateData['profile_image_url'] = currentUserData!.profileImageUrl;
      }
      
      if (email != null && email.trim() != user.email) {
        // Re-authenticate user before changing email (required by Firebase)
        if (password == null || password.isEmpty) {
          throw Exception('Password is required to change email address.');
        }

        try {
          // Re-authenticate user with password
          await reauthenticateUser(password);
        } catch (e) {
          // Re-throw re-authentication errors
          throw Exception('Re-authentication failed: $e');
        }

        // Verify email before updating
        // This method sends verification email to the NEW email address
        // Email will be updated in Firebase Auth after user verifies the new email
        try {
          await user.verifyBeforeUpdateEmail(email.trim());
          // If successful, verification email is sent to the new email
          // Don't update email in Firestore yet - wait for user to verify
          // The email in Firebase Auth will be updated automatically after verification
        } on FirebaseAuthException catch (e) {
          // Re-throw with a more user-friendly message
          throw Exception('Failed to send verification email: ${_handleAuthException(e)}');
        } catch (e) {
          // Re-throw any other errors
          throw Exception('Failed to send verification email: $e');
        }
        
        // Update email in Firestore (will be synced with Firebase Auth after verification)
        updateData['email'] = email.trim();
      }
      
      await _firestoreInstance
          .collection('users')
          .doc(user.uid)
          .update(updateData);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(File imageFile) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }

    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      // Create reference to profile image in Storage
      final ref = _storageInstance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      // Upload file dengan metadata
      await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=3600',
        ),
      );

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();

      // Update profile_image_url in Firestore
      await _firestoreInstance
          .collection('users')
          .doc(user.uid)
          .update({
        'profile_image_url': downloadUrl,
      });

      return downloadUrl;
    } on FirebaseException catch (e) {
      // Handle berbagai error code dari Firebase Storage
      String errorMessage;
      switch (e.code) {
        case 'object-not-found':
        case 'bucket-not-found':
          errorMessage = 'Firebase Storage bucket is not configured. Please enable Storage in Firebase Console.';
          break;
        case 'unauthorized':
        case 'permission-denied':
          errorMessage = 'Storage permission denied. Please check Storage Rules in Firebase Console.';
          break;
        case 'unauthenticated':
          errorMessage = 'User is not authenticated. Please sign in again.';
          break;
        case 'quota-exceeded':
          errorMessage = 'Storage quota exceeded. Please check your Firebase plan.';
          break;
        default:
          errorMessage = 'Failed to upload profile image: ${e.message ?? e.code}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign out and sign in again.';
      case 'invalid-action-code':
        return 'The verification link is invalid or has expired.';
      default:
        return 'An authentication error occurred: ${e.message ?? e.code}';
    }
  }

}


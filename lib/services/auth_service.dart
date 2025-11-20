import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

class AuthService {
  // Lazy initialization - only access Firebase when needed
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth get _authInstance {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  FirebaseFirestore get _firestoreInstance {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
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

  // Auth state stream
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
      throw Exception('An error occurred: $e');
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

  // Generate and send email OTP
  Future<void> sendEmailOTP({
    required String email,
    required Function(String otpCode) onCodeGenerated,
    required Function(String error) onError,
  }) async {
    if (!_isFirebaseInitialized) {
      onError('Firebase is not configured. Please run: flutterfire configure');
      return;
    }

    try {
      // Generate 6-digit OTP
      String otpCode = _generateOTP();
      
      // Store OTP in Firestore with expiration (10 minutes)
      final otpData = {
        'email': email,
        'otp': otpCode,
        'created_at': FieldValue.serverTimestamp(),
        'expires_at': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 10)),
        ),
        'verified': false,
      };

      await _firestoreInstance
          .collection('email_otps')
          .doc(email)
          .set(otpData);

      // Call the callback with the OTP code
      // In production, you would send this via email using Cloud Functions
      // For now, we'll pass it to the callback (you can log it for testing)
      onCodeGenerated(otpCode);
      
      // TODO: Implement email sending via Cloud Functions
      // The OTP should be sent via email, not exposed to the client
      // For development/testing, you can check the console or Firestore
    } catch (e) {
      onError('An error occurred: $e');
    }
  }

  // Generate 6-digit OTP
  String _generateOTP() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final otp = (random % 1000000).toString().padLeft(6, '0');
    return otp;
  }

  // Verify email OTP
  Future<bool> verifyEmailOTP({
    required String email,
    required String otpCode,
  }) async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not configured. Please run: flutterfire configure');
    }

    try {
      // Get OTP document from Firestore
      DocumentSnapshot doc = await _firestoreInstance
          .collection('email_otps')
          .doc(email)
          .get();

      if (!doc.exists) {
        throw Exception('OTP not found. Please request a new code.');
      }

      final data = doc.data() as Map<String, dynamic>;
      final storedOTP = data['otp'] as String?;
      final expiresAt = (data['expires_at'] as Timestamp?)?.toDate();
      final verified = data['verified'] as bool? ?? false;

      // Check if already verified
      if (verified) {
        throw Exception('This OTP has already been used.');
      }

      // Check if expired
      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
        throw Exception('OTP has expired. Please request a new code.');
      }

      // Verify OTP
      if (storedOTP != otpCode) {
        throw Exception('Invalid OTP code. Please try again.');
      }

      // Mark as verified
      await _firestoreInstance
          .collection('email_otps')
          .doc(email)
          .update({'verified': true});

      // Mark user email as verified in Firebase Auth
      if (currentUser != null && currentUser!.email == email) {
        await currentUser!.reload();
        if (!currentUser!.emailVerified) {
          // Note: Firebase doesn't have a direct way to mark email as verified
          // You may need to use email verification link or custom claims
        }
      }

      return true;
    } catch (e) {
      throw Exception(e.toString());
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
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }

}


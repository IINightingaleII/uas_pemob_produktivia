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


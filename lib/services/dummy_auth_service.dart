import '../models/user_model.dart';

/// Dummy authentication service that stores users in memory
/// This is for development/testing purposes only
class DummyAuthService {
  // In-memory storage for users
  static final Map<String, Map<String, dynamic>> _users = {};
  static UserModel? _currentUser;

  /// Get current logged in user
  UserModel? get currentUser => _currentUser;

  /// Auth state stream (simplified - just returns current user)
  Stream<UserModel?> get authStateChanges {
    return Stream.value(_currentUser);
  }

  /// Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if email already exists
    if (_users.containsKey(email.toLowerCase())) {
      throw Exception('An account already exists for that email.');
    }

    // Validate password
    if (password.length < 6) {
      throw Exception('The password provided is too weak.');
    }

    // Create new user
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final newUser = UserModel(
      id: userId,
      email: email.toLowerCase(),
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    // Store user with password (in real app, password would be hashed)
    _users[email.toLowerCase()] = {
      'user': newUser,
      'password': password, // In production, this should be hashed
    };

    // Set as current user
    _currentUser = newUser;

    return newUser;
  }

  /// Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final emailLower = email.toLowerCase();
    
    // Check if user exists
    if (!_users.containsKey(emailLower)) {
      throw Exception('No user found for that email.');
    }

    final userData = _users[emailLower]!;
    
    // Check password
    if (userData['password'] != password) {
      throw Exception('Wrong password provided.');
    }

    // Set as current user
    _currentUser = userData['user'] as UserModel;

    return _currentUser;
  }

  /// Sign out
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  /// Get current user data
  Future<UserModel?> getCurrentUserData() async {
    return _currentUser;
  }

  /// Clear all users (for testing)
  static void clearAllUsers() {
    _users.clear();
    _currentUser = null;
  }
}


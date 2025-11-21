import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isAuthenticated = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
    _firebaseService.authStateChanges.listen((user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _user = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser != null) {
      _isAuthenticated = true;
      await _loadUserData(currentUser.uid);
    } else {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final userData = await _firebaseService.getUserData(uid);
      if (userData != null) {
        _user = userData;
        _isAuthenticated = true;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _errorMessage = null;
      notifyListeners();

      final credential = await _firebaseService.signInWithEmail(email, password);
      if (credential?.user != null) {
        _isAuthenticated = true;
        _errorMessage = null;
        notifyListeners();
        // Load user data asynchronously without blocking the login response
        _loadUserData(credential!.user!.uid).then((_) {
          debugPrint('AuthProvider.login: User data loaded successfully');
        }).catchError((e) {
          debugPrint('AuthProvider.login: Error loading user data: $e');
        });
        return true;
      }
      return false;
    } catch (e) {
      // Prefer not to expose raw exception text to the user. Show a simple
      // 'Sign in failed' message for missing accounts and a generic message
      // otherwise. Log details to console for debugging.
      if (e is FirebaseAuthException) {
        debugPrint('AuthProvider.login FirebaseAuthException: code=${e.code} message=${e.message}');
        if (e.code == 'user-not-found') {
          _errorMessage = 'Sign in failed';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Invalid credentials';
        } else {
          _errorMessage = 'Sign in failed';
        }
      } else {
        debugPrint('AuthProvider.login unexpected error: $e');
        _errorMessage = 'Sign in failed';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String phone, String password) async {
    try {
      _errorMessage = null;
      notifyListeners();

      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters';
        notifyListeners();
        return false;
      }

      final credential = await _firebaseService.signUpWithEmail(email, password, name, phone);
      if (credential?.user != null) {
        await _loadUserData(credential!.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      if (e is FirebaseAuthException) {
        debugPrint('AuthProvider.signup FirebaseAuthException: code=${e.code} message=${e.message}');
        if (e.code == 'email-already-in-use') {
          _errorMessage = 'Email already in use';
        } else if (e.code == 'weak-password') {
          _errorMessage = 'Password is too weak';
        } else {
          _errorMessage = 'Sign up failed';
        }
      } else {
        debugPrint('AuthProvider.signup unexpected error: $e');
        _errorMessage = 'Sign up failed';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _errorMessage = null;
      notifyListeners();

      final credential = await _firebaseService.signInWithGoogle();
      if (credential?.user != null) {
        await _loadUserData(credential!.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      if (e is FirebaseAuthException) {
        debugPrint('AuthProvider.signInWithGoogle FirebaseAuthException: code=${e.code} message=${e.message}');
      } else {
        debugPrint('AuthProvider.signInWithGoogle unexpected error: $e');
      }
      // Keep UI message generic to avoid exposing internals
      _errorMessage = 'Sign in failed';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseService.signOut();
      _user = null;
      _isAuthenticated = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed';
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      notifyListeners();
      await _firebaseService.sendPasswordResetEmail(email);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is FirebaseAuthException) {
        debugPrint('AuthProvider.resetPassword FirebaseAuthException: code=${e.code}');
        _errorMessage = e.code == 'user-not-found' 
            ? 'No account found with this email'
            : 'Failed to send reset email';
      } else {
        debugPrint('AuthProvider.resetPassword error: $e');
        _errorMessage = 'Failed to send reset email';
      }
      notifyListeners();
      return false;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  
  // Getters
  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.signInWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userCredential = await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      
      // If user canceled the sign-in process, userCredential will be null
      return userCredential != null;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Create account with email and password
  Future<bool> createAccount(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.createAccountWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Send password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Handle Firebase Auth Exceptions
  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _error = 'No user found with this email.';
        break;
      case 'wrong-password':
        _error = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        _error = 'An account already exists with this email.';
        break;
      case 'weak-password':
        _error = 'Password is too weak.';
        break;
      case 'invalid-email':
        _error = 'Please enter a valid email address.';
        break;
      default:
        _error = e.message ?? 'An unknown error occurred.';
    }
    _isLoading = false;
    notifyListeners();
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

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
      
      // Get and save the token
      await _saveAuthToken();
      
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
      // If user canceled the sign-in process, userCredential will be null
      if (userCredential != null) {
        // Get and save the token
        await _saveAuthToken();
      }
      
      _isLoading = false;
      notifyListeners();
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
      
      // Get and save the token for newly created account
      await _saveAuthToken();
      
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
      // Clear any saved credentials in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
      
      // Sign out from Firebase
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
  
  // Save auth token to SharedPreferences and log it
  Future<void> _saveAuthToken() async {
    try {
      final token = await _authService.getUserIdToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        
        // Print the token more prominently
        print('==========================================');
        print('FIREBASE ID TOKEN: $token');
        print('==========================================');
        
        // Also log with developer tools
        developer.log('Firebase Auth Token: $token', name: 'AuthProvider');
      } else {
        print('WARNING: Failed to get Firebase ID token - token is null');
      }
    } catch (e) {
      print('ERROR: Failed to get Firebase ID token: $e');
      developer.log('Error saving auth token: $e', name: 'AuthProvider', error: e);
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId:
          "128410338756-99ea9lttdc55bqvglb42eic9fjj6qol1.apps.googleusercontent.com");

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user ID token
  Future<String?> getUserIdToken() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create new account with email and password
  Future<UserCredential> createAccountWithEmail(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user canceled the sign-in flow, googleUser will be null
      if (googleUser == null) return null;

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase with the token
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google Auth credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow; // Rethrow to be caught by the provider
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  // Check if current user is banned
  Future<bool> isCurrentUserBanned() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final bannedDoc = await FirebaseFirestore.instance
          .collection('bannedUsers')
          .doc(user.uid)
          .get();
      
      return bannedDoc.exists;
    } catch (e) {
      print('Error checking if user is banned: $e');
      return false;
    }
  }
  
  // Check if user is signed in with Google
  bool isUserSignedInWithGoogle() {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    for (var userInfo in user.providerData) {
      if (userInfo.providerId == 'google.com') {
        return true;
      }
    }
    
    return false;
  }
}

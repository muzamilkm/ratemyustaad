import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }
      
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (!docSnapshot.exists) {
        return null;
      }
      
      return docSnapshot.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Get current user's reviews
  Future<List<Review>> getUserReviews({int limit = 10, DocumentSnapshot? startAfter}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return [];
      }
      
      Query query = _firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true);
          
      // Apply pagination if startAfter document is provided
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final querySnapshot = await query.limit(limit).get();
          
      return querySnapshot.docs
          .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting user reviews: $e');
      return [];
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }
      
      await _firestore.collection('users').doc(user.uid).update(userData);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
  
  // Update user email
  Future<bool> updateUserEmail(String newEmail, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }
      
      // Re-authenticate user first
      final credential = EmailAuthProvider.credential(
        email: user.email ?? '', 
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updateEmail(newEmail);
      
      // Update email in Firestore as well
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
      });
      
      return true;
    } catch (e) {
      print('Error updating user email: $e');
      return false;
    }
  }
  
  // Update user password
  Future<bool> updateUserPassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return false;
      }
      
      // Re-authenticate user first
      final credential = EmailAuthProvider.credential(
        email: user.email!, 
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      
      return true;
    } catch (e) {
      print('Error updating user password: $e');
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

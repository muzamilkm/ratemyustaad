import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
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
  Future<List<Review>> getUserReviews(
      {int limit = 10, DocumentSnapshot? startAfter}) async {
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
          .map((doc) =>
              Review.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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

      // Check if the user is signed in with Google
      bool isGoogleUser = false;
      for (var userInfo in user.providerData) {
        if (userInfo.providerId == 'google.com') {
          isGoogleUser = true;
          break;
        }
      }

      if (isGoogleUser) {
        // For Google users, we can't update email via Firebase Auth
        // We can only update it in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'email': newEmail,
        });
        return true;
      } else {
        // For email/password users, re-authenticate and update email
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
      }
    } catch (e) {
      print('Error updating user email: $e');
      return false;
    }
  }
  // Update user password
  Future<bool> updateUserPassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return false;
      }

      // Check if the user is signed in with Google
      bool isGoogleUser = false;
      for (var userInfo in user.providerData) {
        if (userInfo.providerId == 'google.com') {
          isGoogleUser = true;
          break;
        }
      }

      if (isGoogleUser) {
        // For Google users, we can't update password
        throw Exception('Google-authenticated users cannot change their password in this app. Please manage your Google account password separately.');
      } else {
        // For email/password users, re-authenticate and update password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        return true;
      }
    } catch (e) {
      print('Error updating user password: $e');
      rethrow; // Rethrow to show specific error to user
    }
  }
  // Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Get the review first
      final reviewDoc =
          await _firestore.collection('reviews').doc(reviewId).get();

      if (!reviewDoc.exists) {
        return false;
      }

      final reviewData = reviewDoc.data() as Map<String, dynamic>;

      // Check if the current user is an admin
      final isAdmin = await isUserAdmin();
      
      // Verify that the review belongs to the current user or the user is an admin
      if (reviewData['userId'] != user.uid && !isAdmin) {
        return false;
      }

      // Delete the review
      await _firestore.collection('reviews').doc(reviewId).delete();

      // Update teacher's average rating and review count
      await _updateTeacherRatings(reviewData['teacherId']);

      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  // Update a review
  Future<bool> updateReview(
      String reviewId, Map<String, dynamic> reviewData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Get the review first to check if it belongs to the user
      final reviewDoc =
          await _firestore.collection('reviews').doc(reviewId).get();

      if (!reviewDoc.exists) {
        return false;
      }

      final existingReviewData = reviewDoc.data() as Map<String, dynamic>;

      // Verify that the review belongs to the current user
      if (existingReviewData['userId'] != user.uid) {
        return false;
      }

      // Update the review
      await _firestore.collection('reviews').doc(reviewId).update(reviewData);

      // Update teacher's average rating and review count
      await _updateTeacherRatings(existingReviewData['teacherId']);

      return true;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

  // Update teacher ratings (helper method for delete/update)
  Future<void> _updateTeacherRatings(String teacherId) async {
    try {
      // Get all reviews for this teacher
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        // No reviews left, reset the teacher ratings
        await _firestore.collection('teachers').doc(teacherId).update({
          'averageRating': 0.0,
          'reviewCount': 0,
          'ratingBreakdown': {
            'teaching': 0.0,
            'knowledge': 0.0,
            'approachability': 0.0,
            'grading': 0.0,
          },
        });
        return;
      }

      // Calculate average rating
      double totalRating = 0;
      final Map<String, double> ratingBreakdown = {
        'teaching': 0.0,
        'knowledge': 0.0,
        'approachability': 0.0,
        'grading': 0.0,
      };

      // Sum up all ratings
      for (final doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] ?? 0.0).toDouble();

        // Sum up breakdown
        final breakdown =
            data['ratingBreakdown'] as Map<String, dynamic>? ?? {};
        for (final key in ratingBreakdown.keys) {
          ratingBreakdown[key] = (ratingBreakdown[key] ?? 0.0) +
              (breakdown[key] ?? 0.0).toDouble();
        }
      }

      // Calculate averages
      final reviewCount = reviewsSnapshot.docs.length;
      final averageRating = totalRating / reviewCount;

      // Calculate average breakdown
      for (final key in ratingBreakdown.keys) {
        ratingBreakdown[key] = ratingBreakdown[key]! / reviewCount;
      }

      // Update the teacher document
      await _firestore.collection('teachers').doc(teacherId).update({
        'averageRating': averageRating,
        'reviewCount': reviewCount,
        'ratingBreakdown': ratingBreakdown,
      });
    } catch (e) {
      print('Error updating teacher ratings: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  // Admin-related methods
  Future<bool> isUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }
      
      final adminDoc = await _firestore.collection('admins').doc(user.uid).get();
      return adminDoc.exists;
    } catch (e) {
      print('Error checking if user is admin: $e');
      return false;
    }
  }
  
  // Find a user by email
  Future<String?> findUserIdByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return querySnapshot.docs.first.id;
    } catch (e) {
      print('Error finding user by email: $e');
      return null;
    }
  }
  
  Future<bool> addAdmin(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }
      
      // Check if current user is an admin
      final isAdmin = await isUserAdmin();
      if (!isAdmin) {
        return false;
      }
      
      // Get the user data to include in the admin document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return false;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Add the user to the admins collection
      await _firestore.collection('admins').doc(userId).set({
        'userId': userId,
        'email': userData['email'] ?? '',
        'firstName': userData['firstName'] ?? '',
        'lastName': userData['lastName'] ?? '',
        'addedBy': currentUser.uid,
        'addedOn': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error adding admin: $e');
      return false;
    }
  }
  
  Future<bool> removeAdmin(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }
      
      // Check if current user is an admin
      final isAdmin = await isUserAdmin();
      if (!isAdmin) {
        return false;
      }
      
      // Don't allow admins to remove themselves
      if (userId == currentUser.uid) {
        return false;
      }
      
      // Remove the user from the admins collection
      await _firestore.collection('admins').doc(userId).delete();
      
      return true;
    } catch (e) {
      print('Error removing admin: $e');
      return false;
    }
  }
    Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }
      
      // Check if current user is an admin
      final isAdmin = await isUserAdmin();
      if (!isAdmin) {
        return [];
      }
      
      // Get all admins
      final adminsSnapshot = await _firestore.collection('admins').get();
      
      return adminsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'email': data['email'] ?? '',
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'addedBy': data['addedBy'] ?? '',
          'addedOn': data['addedOn'] != null 
              ? (data['addedOn'] as Timestamp).toDate().toString() 
              : '',
        };
      }).toList();
    } catch (e) {
      print('Error getting all admins: $e');
      return [];
    }
  }
  
  // Find an admin by email
  Future<Map<String, dynamic>?> findAdminByEmail(String email) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }
      
      // Check if current user is an admin
      final isAdmin = await isUserAdmin();
      if (!isAdmin) {
        return null;
      }
      
      // Get admin with matching email
      final adminsSnapshot = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (adminsSnapshot.docs.isEmpty) {
        return null;
      }
      
      final doc = adminsSnapshot.docs.first;
      final data = doc.data();
      
      return {
        'userId': doc.id,
        'email': data['email'] ?? '',
        'firstName': data['firstName'] ?? '',
        'lastName': data['lastName'] ?? '',
        'addedBy': data['addedBy'] ?? '',
        'addedOn': data['addedOn'] != null 
            ? (data['addedOn'] as Timestamp).toDate().toString() 
            : '',
      };
    } catch (e) {
      print('Error finding admin by email: $e');
      return null;
    }
  }

  // Check review content with censorship API with fallback
  Future<Map<String, dynamic>> checkReviewContent(String reviewText) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to submit a review');
      }

      // Get the authentication token
      final idToken = await user.getIdToken();

      try {
        // Make the API call to the censorship endpoint with a timeout
        final response = await http
            .post(
              Uri.parse('https://censorship.ratemyustaaddev.workers.dev'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $idToken',
              },
              body: jsonEncode({
                'review': reviewText,
              }),
            )
            .timeout(const Duration(seconds: 15)); // Add timeout

        if (response.statusCode == 200) {
          print('Censorship API response: ${response.body}');
          final responseData = jsonDecode(response.body);
          return responseData;
        } else {
          print('Censorship API returned error status: ${response.statusCode}');
          // Return a specific error for API errors
          throw Exception('validation_server_error');
        }
      } catch (e) {
        // Handle network errors or timeouts
        print('Error connecting to censorship API: $e');

        // Return a specific error for connectivity issues
        throw Exception('validation_connectivity_error');
      }
    } catch (e) {
      print('Error in review content check: $e');
      rethrow;
    }
  }
  
  // Store rejected review in the rejectedReviews collection
  Future<bool> storeRejectedReview({
    required String reviewText,
    required String teacherName,
    required String teacherDepartment,
    required double rating,
    required Map<String, double> ratingBreakdown,
    String? institution,
    String? courseCode,
    String? courseName,
    List<String> tags = const [],
    bool isAnonymous = false,
    String? rejectionReason,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }
      
      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      
      // Find teacher ID (if the teacher exists)
      String? teacherId;
      String normalizedName = teacherName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      String normalizedDepartment = teacherDepartment.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      String formattedTeacherId = '${normalizedName}_${normalizedDepartment}';
      
      try {
        final teacherDoc = await _firestore.collection('teachers').doc(formattedTeacherId).get();
        if (teacherDoc.exists) {
          teacherId = teacherDoc.id;
        }
      } catch (e) {
        print('Error finding teacher for rejected review: $e');
      }
      
      // Create rejected review document
      final rejectedReview = {
        'teacherId': teacherId,
        'teacherName': teacherName.trim(),
        'teacherDepartment': teacherDepartment.trim(),
        'institution': institution?.trim() ?? '',
        'userId': user.uid,
        'userName': isAnonymous ? 'Anonymous' : (userData['firstName'] ?? '') + ' ' + (userData['lastName'] ?? ''),
        'userEmail': user.email ?? '',
        'text': reviewText.trim(),
        'rating': rating,
        'ratingBreakdown': ratingBreakdown,
        'tags': tags,
        'timestamp': FieldValue.serverTimestamp(),
        'courseCode': courseCode?.trim() ?? '',
        'courseName': courseName?.trim() ?? '',
        'isAnonymous': isAnonymous,
        'rejectionReason': rejectionReason ?? 'Content flagged by AI content checker',
        'reviewedByModerator': false,
      };
      
      // Store in the rejectedReviews collection
      await _firestore.collection('rejectedReviews').add(rejectedReview);
      
      return true;
    } catch (e) {
      print('Error storing rejected review: $e');
      return false;
    }
  }

  // Local validation fallback when censorship API is unavailable
  Map<String, dynamic> _performBasicLocalValidation(String reviewText) {
    // List of basic profanity words to check - this is a minimal example
    final List<String> profanityList = [
      'fuck',
      'shit',
      'asshole',
      'bitch',
      'bastard',
      'damn',
      'dick',
      'cunt',
      'whore',
      'slut'
    ];

    // Convert to lowercase for case-insensitive matching
    final String lowerText = reviewText.toLowerCase();      // Check if the review contains any profanity
    for (final word in profanityList) {
      if (lowerText.contains(word)) {
        return {
          'accepted': false,
          'reason':
              'Your review contains inappropriate language or irrelevant phrasing as detected by our AI. Please revise and try again.'
        };
      }
    }

    // If no profanity is found, accept the review
    return {
      'accepted': true,      'reason':
          'The review was accepted (using local validation due to API unavailability).'
    };
  }
  
  // Check if a user is banned
  Future<bool> isUserBanned(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('bannedUsers').doc(userId).get();
      return docSnapshot.exists;
    } catch (e) {
      print('Error checking if user is banned: $e');
      return false;
    }
  }
  
  // Ban a user
  Future<bool> banUser(String userId, String reason) async {
    try {
      // Get current admin information
      final adminId = _auth.currentUser?.uid;
      if (adminId == null) return false;
      
      // Get user information
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;
      
      final userData = userDoc.data() ?? {};
      
      // Create banned user record
      await _firestore.collection('bannedUsers').doc(userId).set({
        'email': userData['email'] ?? '',
        'firstName': userData['firstName'] ?? '',
        'lastName': userData['lastName'] ?? '',
        'banReason': reason.isNotEmpty ? reason : 'Violation of terms of service',
        'bannedBy': adminId,
        'adminEmail': _auth.currentUser?.email ?? 'Unknown',
        'bannedAt': Timestamp.now(),
      });
      
      return true;
    } catch (e) {
      print('Error banning user: $e');
      return false;
    }
  }
  
  // Unban a user
  Future<bool> unbanUser(String userId) async {
    try {
      await _firestore.collection('bannedUsers').doc(userId).delete();
      return true;
    } catch (e) {
      print('Error unbanning user: $e');
      return false;
    }
  }
  
  // Get all banned users
  Future<List<Map<String, dynamic>>> getBannedUsers() async {
    try {
      final querySnapshot = await _firestore.collection('bannedUsers').get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'email': data['email'] ?? '',
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'banReason': data['banReason'] ?? '',
          'bannedBy': data['bannedBy'] ?? '',
          'adminEmail': data['adminEmail'] ?? '',
          'bannedAt': data['bannedAt'] ?? Timestamp.now(),
        };
      }).toList();
    } catch (e) {
      print('Error getting banned users: $e');
      return [];
    }
  }
    // Search for users by name or email with support for partial matching
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      query = query.trim();
      final lowerQuery = query.toLowerCase();
      final Set<String> userIds = {};
      final List<Map<String, dynamic>> results = [];
      
      // Get all users if the query is very short (for better UX)
      if (query.length < 2) {
        // If query is too short, return limited results to prevent loading too many users
        final allUsers = await _firestore
            .collection('users')
            .limit(20)
            .get();
            
        // Get list of banned users for checking status
        final bannedUsersSnapshot = await _firestore.collection('bannedUsers').get();
        final Set<String> bannedUserIds = bannedUsersSnapshot.docs.map((doc) => doc.id).toSet();
        
        for (final doc in allUsers.docs) {
          final userId = doc.id;
          final data = doc.data();
          
          results.add({
            'userId': userId,
            'email': data['email'] ?? '',
            'firstName': data['firstName'] ?? '',
            'lastName': data['lastName'] ?? '',
            'photoURL': data['photoURL'] ?? '',
            'isBanned': bannedUserIds.contains(userId),
          });
        }
        
        return results;
      }
      
      // Perform multiple targeted queries
      
      // 1. Search by exact email match
      final exactEmailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: lowerQuery)
          .get();
      
      // 2. Search by first name (partial match)
      final firstNameQuery = await _firestore
          .collection('users')
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      
      // 3. Search by last name (partial match)
      final lastNameQuery = await _firestore
          .collection('users')
          .where('lastName', isGreaterThanOrEqualTo: query)
          .where('lastName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
          
      // 4. For email partial matching, we'll need to load users and filter client-side
      // This is because Firestore doesn't support substring queries directly
      // We'll limit this query to avoid performance issues
      final emailPartialQuery = await _firestore
          .collection('users')
          .limit(100) // Limit to prevent loading too many users
          .get();
      
      // Process results
      final allDocs = [
        ...exactEmailQuery.docs,
        ...firstNameQuery.docs,
        ...lastNameQuery.docs,
      ];
      
      // Get list of banned users for checking status
      final bannedUsersSnapshot = await _firestore.collection('bannedUsers').get();
      final Set<String> bannedUserIds = bannedUsersSnapshot.docs.map((doc) => doc.id).toSet();
      
      // First process the direct query results (more precise matches)
      for (final doc in allDocs) {
        final userId = doc.id;
        if (userIds.contains(userId)) continue;
        
        userIds.add(userId);
        final data = doc.data();
        
        results.add({
          'userId': userId,
          'email': data['email'] ?? '',
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'photoURL': data['photoURL'] ?? '',
          'isBanned': bannedUserIds.contains(userId),
        });
      }
      
      // Then process the partial email matches
      for (final doc in emailPartialQuery.docs) {
        final userId = doc.id;
        if (userIds.contains(userId)) continue; // Skip if already added
        
        final data = doc.data();
        final email = (data['email'] ?? '').toLowerCase();
        
        // Check if email contains the query string
        if (email.contains(lowerQuery)) {
          userIds.add(userId);
          
          results.add({
            'userId': userId,
            'email': data['email'] ?? '',
            'firstName': data['firstName'] ?? '',
            'lastName': data['lastName'] ?? '',
            'photoURL': data['photoURL'] ?? '',
            'isBanned': bannedUserIds.contains(userId),
          });
        }
      }      
      return results;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }
}

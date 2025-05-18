import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/teacher.dart';
import '../models/review.dart';
import 'search_utils.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection references
  final CollectionReference _teachersCollection;
  final CollectionReference _reviewsCollection;
  
  TeacherService() 
    : _teachersCollection = FirebaseFirestore.instance.collection('teachers'),
      _reviewsCollection = FirebaseFirestore.instance.collection('reviews');
  
  // Format teacher ID by normalizing name and department
  String _formatTeacherId(String name, String department) {
    final normalizedName = name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final normalizedDepartment = department.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    return '${normalizedName}_${normalizedDepartment}';
  }
  
  // Find a teacher by name and department
  Future<Teacher?> findTeacher(String name, String department) async {
    try {
      // Format the teacher ID
      final teacherId = _formatTeacherId(name, department);
      
      // Get document by ID (most efficient)
      final docSnapshot = await _teachersCollection.doc(teacherId).get();
      
      if (docSnapshot.exists) {
        return Teacher.fromMap(
          docSnapshot.data() as Map<String, dynamic>, 
          docSnapshot.id
        );
      }
      
      // As a fallback, query by name and department 
      // (in case the name or department has special characters)
      final querySnapshot = await _teachersCollection
          .where('name', isEqualTo: name.trim())
          .where('department', isEqualTo: department.trim())
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      
      return null;
    } catch (e) {
      print('Error finding teacher: $e');
      return null;
    }
  }
  
  // Create or update a teacher
  Future<Teacher> saveTeacher(String name, String department, {
    String? institution,
    String? photoUrl,
  }) async {
    try {
      // Format the teacher ID
      final teacherId = _formatTeacherId(name, department);
      
      // Check if teacher exists
      final existingTeacher = await findTeacher(name, department);
      
      if (existingTeacher != null) {
        // Return existing teacher
        return existingTeacher;
      }
      
      // Create a new teacher object
      final newTeacher = Teacher(
        id: teacherId,
        name: name.trim(),
        department: department.trim(),
        institution: institution?.trim() ?? '',
        photoUrl: photoUrl ?? '',
      );
      
      // Save to Firestore
      await _teachersCollection.doc(teacherId).set(newTeacher.toMap());
      
      return newTeacher;
    } catch (e) {
      print('Error saving teacher: $e');
      rethrow;
    }
  }
  
  // Add a review for a teacher
  Future<Review> addReview({
    required String teacherName,
    required String teacherDepartment,
    required String text,
    required double rating,
    required Map<String, double> ratingBreakdown,
    String? institution,
    String? courseCode,
    String? courseName,
    List<String> tags = const [],
    bool isAnonymous = false,
  }) async {
    try {
      // Ensure user is authenticated
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to submit a review');
      }
      
      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      
      // Create or get the teacher
      final teacher = await saveTeacher(
        teacherName, 
        teacherDepartment,
        institution: institution,
      );
      
      // Create review
      final reviewId = _reviewsCollection.doc().id; // Auto-generate ID
      final newReview = Review(
        id: reviewId,
        teacherId: teacher.id,
        teacherName: teacher.name,
        teacherDepartment: teacher.department,
        userId: user.uid,
        userName: isAnonymous ? 'Anonymous' : (userData['firstName'] ?? '') + ' ' + (userData['lastName'] ?? ''),
        userEmail: user.email ?? '',
        text: text.trim(),
        rating: rating,
        ratingBreakdown: ratingBreakdown,
        tags: tags,
        timestamp: DateTime.now(),
        courseCode: courseCode?.trim() ?? '',
        courseName: courseName?.trim() ?? '',
        isAnonymous: isAnonymous,
      );
      
      // Save review to Firestore
      await _reviewsCollection.doc(reviewId).set(newReview.toMap());
      
      // Update teacher's average rating and review count
      await _updateTeacherRatings(teacher.id);
      
      return newReview;
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }
  
  // Update a teacher's average rating and rating breakdown
  Future<void> _updateTeacherRatings(String teacherId) async {
    try {
      // Get all reviews for this teacher
      final reviewsSnapshot = await _reviewsCollection
          .where('teacherId', isEqualTo: teacherId)
          .get();
          
      final reviews = reviewsSnapshot.docs
          .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
          
      // Calculate average rating
      double averageRating = 0;
      if (reviews.isNotEmpty) {
        averageRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      }
      
      // Calculate average rating breakdown
      final Map<String, double> ratingBreakdown = {
        'teaching': 0.0,
        'knowledge': 0.0,
        'approachability': 0.0,
        'grading': 0.0,
      };
      
      if (reviews.isNotEmpty) {
        // Sum up all individual breakdowns
        for (final review in reviews) {
          for (final key in ratingBreakdown.keys) {
            ratingBreakdown[key] = (ratingBreakdown[key] ?? 0) + (review.ratingBreakdown[key] ?? 0);
          }
        }
        
        // Calculate averages
        for (final key in ratingBreakdown.keys) {
          ratingBreakdown[key] = (ratingBreakdown[key] ?? 0) / reviews.length;
        }
      }
      
      // Update teacher document
      await _teachersCollection.doc(teacherId).update({
        'averageRating': averageRating,
        'reviewCount': reviews.length,
        'ratingBreakdown': ratingBreakdown,
      });
    } catch (e) {
      print('Error updating teacher ratings: $e');
    }
  }
  
  // Get all reviews for a teacher
  Future<List<Review>> getTeacherReviews(String teacherId, {int limit = 20, DocumentSnapshot? startAfter}) async {
    try {
      print('Fetching reviews for teacher ID: $teacherId');
      
      Query query = _reviewsCollection
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('timestamp', descending: true);
          
      // Apply pagination if startAfter document is provided
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final querySnapshot = await query.limit(limit).get();
          
      print('Found ${querySnapshot.docs.length} reviews for teacher');
      
      // Convert to review objects
      final reviews = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Review data: $data');
        return Review.fromMap(data, doc.id);
      }).toList();
      
      return reviews;
    } catch (e) {
      print('Error getting teacher reviews: $e');
      return [];
    }
  }
  
  // Get the top rated teachers
  Future<List<Teacher>> getTopRatedTeachers({int limit = 10, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _teachersCollection
          .where('reviewCount', isGreaterThan: 0)
          .orderBy('averageRating', descending: true)
          .orderBy('reviewCount', descending: true)
          .orderBy('__name__', descending: true);
      
      // Apply pagination if startAfter document is provided
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      // Apply limit
      final querySnapshot = await query.limit(limit).get();
          
      return querySnapshot.docs
          .map((doc) => Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting top rated teachers: $e');
      return [];
    }
  }
  
  // Mark a review as helpful
  Future<void> markReviewAsHelpful(String reviewId, String userId) async {
    try {
      // Get the review
      final reviewDoc = await _reviewsCollection.doc(reviewId).get();
      
      if (!reviewDoc.exists) {
        throw Exception('Review not found');
      }
      
      final reviewData = reviewDoc.data() as Map<String, dynamic>;
      final helpfulVotes = List<String>.from(reviewData['helpfulVotes'] ?? []);
      
      // Check if the user has already voted
      if (helpfulVotes.contains(userId)) {
        // Remove the vote (toggle functionality)
        helpfulVotes.remove(userId);
      } else {
        // Add the vote
        helpfulVotes.add(userId);
      }
      
      // Update the review
      await _reviewsCollection.doc(reviewId).update({
        'helpfulVotes': helpfulVotes,
        'helpfulCount': helpfulVotes.length,
      });
    } catch (e) {
      print('Error marking review as helpful: $e');
      rethrow;
    }
  }
  
  // Get all unique departments
  Future<List<String>> getAllDepartments() async {
    try {
      final querySnapshot = await _teachersCollection.get();
      
      // Extract departments and remove duplicates using a Set
      final departments = querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['department'] as String)
          .where((dept) => dept.isNotEmpty)
          .toSet()
          .toList();
      
      // Sort alphabetically
      departments.sort();
      
      // Add debug information
      print('DEPTS: Found ${departments.length} unique departments');
      if (departments.isNotEmpty) {
        print('DEPTS: Sample departments: ${departments.take(5).toList()}');
      }
      
      return departments;
    } catch (e) {
      print('Error getting departments: $e');
      return [];
    }
  }

  // Get all unique institutions
  Future<List<String>> getAllInstitutions() async {
    try {
      final querySnapshot = await _teachersCollection.get();
      
      // Extract institutions and remove duplicates using a Set
      final institutions = querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['institution'] as String)
          .where((inst) => inst.isNotEmpty)
          .toSet()
          .toList();
      
      // Sort alphabetically
      institutions.sort();
      
      return institutions;
    } catch (e) {
      print('Error getting institutions: $e');
      return [];
    }
  }

  // Get all unique tags from reviews
  Future<List<String>> getAllTags({int limit = 30}) async {
    try {
      final querySnapshot = await _reviewsCollection
          .orderBy('timestamp', descending: true)
          .limit(200) // Sample a reasonable number of recent reviews
          .get();
      
      // Extract all tags
      final allTagsList = querySnapshot.docs.expand((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final tags = data['tags'] as List<dynamic>? ?? [];
        return tags.map((tag) => tag.toString());
      }).toList();

      // Count occurrences of each tag
      final Map<String, int> tagCount = {};
      for (final tag in allTagsList) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }

      // Sort by frequency
      final sortedTags = tagCount.keys.toList()
        ..sort((a, b) => tagCount[b]!.compareTo(tagCount[a]!));
      
      // Return top N most frequent tags
      return sortedTags.take(limit).toList();
    } catch (e) {
      print('Error getting tags: $e');
      return [];
    }
  }
  
  // Enhanced search with filtering and sorting
  Future<List<Teacher>> advancedSearch({
    String query = '',
    String? department,
    String? institution,
    double? minRating,
    List<String>? tags,
    String sortBy = 'rating', // Options: 'rating', 'name', 'reviewCount'
    bool descending = true,
    int limit = 20,
  }) async {
    try {
      print('SEARCH: Starting advanced search with params:');
      print('SEARCH: query="$query", department="$department", institution="$institution"');
      print('SEARCH: minRating=$minRating, tags=$tags, sortBy=$sortBy, descending=$descending');
      
      // Use the enhanced search from search_utils.dart
      return await SearchUtils.enhancedSearch(
        teachersCollection: _teachersCollection,
        reviewsCollection: _reviewsCollection,
        query: query.trim(),
        department: department?.trim(),
        institution: institution?.trim(),
        minRating: minRating,
        tags: tags,
        sortBy: sortBy,
        descending: descending,
        limit: limit,
      );
    } catch (e) {
      print('Error in advanced search: $e');
      return [];
    }
  }
  
  // Search for teachers (basic search - maintained for backward compatibility)
  Future<List<Teacher>> searchTeachers(String query, {int limit = 20}) async {
    return advancedSearch(query: query, limit: limit);
  }
  // Get departments for a specific institution
  Future<List<String>> getDepartmentsByInstitution(String institution) async {
    try {
      final querySnapshot = await _teachersCollection
          .where('institution', isEqualTo: institution)
          .get();
      
      // Extract departments and remove duplicates using a Set
      final departments = querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['department'] as String)
          .where((dept) => dept.isNotEmpty)
          .toSet()
          .toList();
      
      // Sort alphabetically
      departments.sort();
      
      return departments;
    } catch (e) {
      print('Error getting departments for institution: $e');
      return [];
    }
  }
  
  // Check if a department exists in a specific institution
  bool isDepartmentInInstitution(String department, String institution) {
    // This is a simple implementation that will work without
    // making another network call. For more accurate results,
    // you can use getDepartmentsByInstitution and check the result.
    return true;
  }
  
  // Get teachers by institution and department
  Future<List<Teacher>> getTeachersByInstitutionAndDepartment(
    String institution,
    String department,
  ) async {
    try {
      final querySnapshot = await _teachersCollection
          .where('institution', isEqualTo: institution)
          .where('department', isEqualTo: department)
          .orderBy('name')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting teachers by institution and department: $e');
      return [];
    }
  }
}

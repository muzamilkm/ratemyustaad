import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/teacher.dart';
import '../models/review.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection references
  final CollectionReference _teachersCollection;
  final CollectionReference _reviewsCollection;
  
  TeacherService() 
    : _teachersCollection = FirebaseFirestore.instance.collection('teachers'),
      _reviewsCollection = FirebaseFirestore.instance.collection('reviews');
  
  // SIMPLE VERSION OF ADVANCED SEARCH - USE THIS INSTEAD
  Future<List<Teacher>> simpleAdvancedSearch({
    String query = '',
    String? department,
    String? institution,
    double? minRating,
    List<String>? tags,
    String sortBy = 'rating',
    bool descending = true,
    int limit = 20,
  }) async {
    try {
      // Get all teachers
      final querySnapshot = await _teachersCollection.get();
      print('SEARCH: Found ${querySnapshot.docs.length} total teachers');
      print('SEARCH: Parameters - department: "$department", institution: "$institution"');
      
      // Convert to teacher objects
      List<Teacher> allTeachers = querySnapshot.docs
          .map((doc) => Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // Print first few documents for debugging
      if (allTeachers.isNotEmpty) {
        print('SEARCH: First few teachers:');
        for (var i = 0; i < allTeachers.length && i < 3; i++) {
          final teacher = allTeachers[i];
          print('SEARCH: Teacher ${i+1}: ${teacher.name}, Department: "${teacher.department}"');
        }
      }
      
      // Apply filters
      var results = List<Teacher>.from(allTeachers);
      
      if (department != null && department.isNotEmpty) {
        final deptLower = department.toLowerCase();
        results = results.where((teacher) => 
          teacher.department.toLowerCase() == deptLower).toList();
        print('SEARCH: After department filter, ${results.length} teachers remain');
      }
      
      if (institution != null && institution.isNotEmpty) {
        final instLower = institution.toLowerCase();
        results = results.where((teacher) => 
          teacher.institution.toLowerCase() == instLower).toList();
        print('SEARCH: After institution filter, ${results.length} teachers remain');
      }
      
      if (minRating != null && minRating > 0) {
        results = results.where((teacher) => 
          teacher.averageRating >= minRating).toList();
        print('SEARCH: After rating filter, ${results.length} teachers remain');
      }
      
      if (query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        results = results.where((teacher) => 
          teacher.name.toLowerCase().contains(queryLower) ||
          teacher.department.toLowerCase().contains(queryLower) ||
          teacher.institution.toLowerCase().contains(queryLower)
        ).toList();
        print('SEARCH: After text query filter, ${results.length} teachers remain');
      }
      
      // Handle tag filtering
      if (tags != null && tags.isNotEmpty) {
        final filteredResults = <Teacher>[];
        
        for (final teacher in results) {
          final reviewsSnapshot = await _reviewsCollection
              .where('teacherId', isEqualTo: teacher.id)
              .get();
              
          final teacherTags = reviewsSnapshot.docs
              .expand((doc) => List<String>.from((doc.data() as Map<String, dynamic>)['tags'] ?? []))
              .toSet();
              
          if (tags.any((tag) => teacherTags.contains(tag))) {
            filteredResults.add(teacher);
          }
        }
        
        results = filteredResults;
        print('SEARCH: After tag filter, ${results.length} teachers remain');
      }
      
      // Sort results
      results.sort((a, b) {
        int compareValue = 0;
        switch (sortBy) {
          case 'name':
            compareValue = a.name.compareTo(b.name);
            break;
          case 'reviewCount':
            compareValue = a.reviewCount.compareTo(b.reviewCount);
            break;
          case 'rating':
          default:
            compareValue = a.averageRating.compareTo(b.averageRating);
            break;
        }
        return descending ? -compareValue : compareValue;
      });
      
      // Apply limit
      final limitedResults = results.take(limit).toList();
      
      // Print the results
      print('SEARCH: Returning ${limitedResults.length} teachers');
      if (limitedResults.isNotEmpty) {
        for (var i = 0; i < limitedResults.length && i < 3; i++) {
          final teacher = limitedResults[i];
          print('SEARCH: Result ${i+1}: ${teacher.name}, Department: "${teacher.department}"');
        }
      } else {
        print('SEARCH: No teachers found matching the criteria');
      }
      
      return limitedResults;
    } catch (e) {
      print('Error in advanced search: $e');
      return [];
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import '../models/review.dart';

/// Utility functions to enhance the search functionality
class SearchUtils {
  /// Performs a robust search across teacher documents
  static Future<List<Teacher>> enhancedSearch({
    required CollectionReference teachersCollection,
    required CollectionReference reviewsCollection,
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
      print('SEARCH: Starting enhanced search with params:');
      print('SEARCH: query="$query", department="$department", institution="$institution"');
      
      // Get all teachers
      final querySnapshot = await teachersCollection.get();
      print('SEARCH: Found ${querySnapshot.docs.length} total teachers');
      
      // Convert to teacher objects
      List<Teacher> allTeachers = querySnapshot.docs
          .map((doc) => Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // Print first few documents for debugging
      if (allTeachers.isNotEmpty) {
        print('SEARCH: Sample of available teachers:');
        for (var i = 0; i < allTeachers.length && i < 3; i++) {
          final teacher = allTeachers[i];
          print('SEARCH: Teacher ${i+1}: ${teacher.name}, Department: "${teacher.department}"');
        }
      }
      
      // Apply filters
      var results = List<Teacher>.from(allTeachers);
      
      // Department filter (case-insensitive)
      if (department != null && department.isNotEmpty) {
        final deptLower = department.toLowerCase().trim();
        results = results.where((teacher) => 
          teacher.department.toLowerCase().trim() == deptLower).toList();
        print('SEARCH: After department filter, ${results.length} teachers remain');
        
        // Debug department matching
        if (results.isEmpty) {
          print('SEARCH: No teachers found with department "$department"');
          print('SEARCH: Available departments:');
          final departments = allTeachers
              .map((t) => t.department)
              .toSet()
              .take(10)
              .toList();
          print('SEARCH: $departments');
        }
      }
      
      // Institution filter (case-insensitive)
      if (institution != null && institution.isNotEmpty) {
        final instLower = institution.toLowerCase().trim();
        results = results.where((teacher) => 
          teacher.institution.toLowerCase().trim() == instLower).toList();
        print('SEARCH: After institution filter, ${results.length} teachers remain');
      }
      
      // Rating filter
      if (minRating != null && minRating > 0) {
        results = results.where((teacher) => 
          teacher.averageRating >= minRating).toList();
        print('SEARCH: After rating filter, ${results.length} teachers remain');
      }
      
      // Text query filter (name, department, institution)
      if (query.isNotEmpty) {
        final queryLower = query.toLowerCase().trim();
        results = results.where((teacher) => 
          teacher.name.toLowerCase().trim().contains(queryLower) ||
          teacher.department.toLowerCase().trim().contains(queryLower) ||
          teacher.institution.toLowerCase().trim().contains(queryLower)
        ).toList();
        print('SEARCH: After text query filter, ${results.length} teachers remain');
      }
      
      // Handle tag filtering
      if (tags != null && tags.isNotEmpty) {
        final filteredResults = <Teacher>[];
        
        for (final teacher in results) {
          final reviewsSnapshot = await reviewsCollection
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
      print('Error in enhanced search: $e');
      return [];
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class RejectedReview {
  final String id;
  final String teacherId;
  final String teacherName;
  final String teacherDepartment;
  final String userId;
  final String userName;
  final String userEmail;
  final String text;
  final double rating;
  final Map<String, double> ratingBreakdown;
  final List<String> tags;
  final DateTime timestamp;
  final DateTime rejectionTimestamp;
  final String courseCode;
  final String courseName;
  final bool isAnonymous;
  final String rejectionReason;
  final String teacherInstitution;

  RejectedReview({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.teacherDepartment,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.text,
    required this.rating,
    required this.ratingBreakdown,
    this.tags = const [],
    required this.timestamp,
    required this.rejectionTimestamp,
    this.courseCode = '',
    this.courseName = '',
    this.isAnonymous = false,
    required this.rejectionReason,
    this.teacherInstitution = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherDepartment': teacherDepartment,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'text': text,
      'rating': rating,
      'ratingBreakdown': ratingBreakdown,
      'tags': tags,
      'timestamp': timestamp,
      'rejectionTimestamp': FieldValue.serverTimestamp(),
      'courseCode': courseCode,
      'courseName': courseName,
      'isAnonymous': isAnonymous,
      'rejectionReason': rejectionReason,
      'teacherInstitution': teacherInstitution,
    };
  }

  factory RejectedReview.fromMap(Map<String, dynamic> map, String id) {
    // Helper function to safely convert numeric values to double
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }
    
    // Handle rating breakdown with safe conversion
    Map<String, double> parseRatingBreakdown(dynamic rawBreakdown) {
      if (rawBreakdown == null) {
        return {
          'teaching': 0.0,
          'knowledge': 0.0,
          'approachability': 0.0,
          'grading': 0.0,
        };
      }
      
      final Map<String, dynamic> breakdownMap = Map<String, dynamic>.from(rawBreakdown);
      return breakdownMap.map((key, value) => MapEntry(key, toDouble(value)));
    }

    return RejectedReview(
      id: id,
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      teacherDepartment: map['teacherDepartment'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      text: map['text'] ?? '',
      rating: toDouble(map['rating']),
      ratingBreakdown: parseRatingBreakdown(map['ratingBreakdown']),
      tags: List<String>.from(map['tags'] ?? []),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rejectionTimestamp: (map['rejectionTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      courseCode: map['courseCode'] ?? '',
      courseName: map['courseName'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
      rejectionReason: map['rejectionReason'] ?? '',
      teacherInstitution: map['teacherInstitution'] ?? '',
    );
  }
}

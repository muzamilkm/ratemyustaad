import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
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
  final String courseCode;
  final String courseName;
  final bool isAnonymous;
  final bool isVerified;
  final int helpfulCount;
  final List<String> helpfulVotes;

  Review({
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
    this.courseCode = '',
    this.courseName = '',
    this.isAnonymous = false,
    this.isVerified = false,
    this.helpfulCount = 0,
    this.helpfulVotes = const [],
  });

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      teacherDepartment: map['teacherDepartment'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      text: map['text'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingBreakdown: Map<String, double>.from(
        map['ratingBreakdown'] ?? {
          'teaching': 0.0,
          'knowledge': 0.0,
          'approachability': 0.0,
          'grading': 0.0,
        },
      ),
      tags: List<String>.from(map['tags'] ?? []),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      courseCode: map['courseCode'] ?? '',
      courseName: map['courseName'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
      isVerified: map['isVerified'] ?? false,
      helpfulCount: map['helpfulCount'] ?? 0,
      helpfulVotes: List<String>.from(map['helpfulVotes'] ?? []),
    );
  }

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
      'timestamp': FieldValue.serverTimestamp(),
      'courseCode': courseCode,
      'courseName': courseName,
      'isAnonymous': isAnonymous,
      'isVerified': isVerified,
      'helpfulCount': helpfulCount,
      'helpfulVotes': helpfulVotes,
    };
  }
}
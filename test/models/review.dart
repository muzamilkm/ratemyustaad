import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ratemyustaad/models/review.dart';

void main() {
  group('Review Model', () {
    test('fromMap() creates a Review object with complete data', () {
      final timestamp = Timestamp.now();
      final map = {
        'teacherId': 'teacher123',
        'teacherName': 'Dr. Smith',
        'teacherDepartment': 'Computer Science',
        'userId': 'user456',
        'userName': 'John Doe',
        'userEmail': 'johndoe@example.com',
        'text': 'Great teacher!',
        'rating': 4.5,
        'ratingBreakdown': {
          'teaching': 4.0,
          'knowledge': 5.0,
          'approachability': 3.5,
          'grading': 4.0,
        },
        'tags': ['engaging', 'helpful'],
        'timestamp': timestamp,
        'courseCode': 'CS101',
        'courseName': 'Intro to Computer Science',
        'isAnonymous': true,
        'isVerified': true,
        'helpfulCount': 10,
        'helpfulVotes': ['user1', 'user2'],
      };

      final review = Review.fromMap(map, 'review123');

      expect(review.id, 'review123');
      expect(review.teacherId, 'teacher123');
      expect(review.teacherName, 'Dr. Smith');
      expect(review.teacherDepartment, 'Computer Science');
      expect(review.userId, 'user456');
      expect(review.userName, 'John Doe');
      expect(review.userEmail, 'johndoe@example.com');
      expect(review.text, 'Great teacher!');
      expect(review.rating, 4.5);
      expect(review.ratingBreakdown['teaching'], 4.0);
      expect(review.tags, contains('engaging'));
      expect(review.timestamp, timestamp.toDate());
      expect(review.courseCode, 'CS101');
      expect(review.courseName, 'Intro to Computer Science');
      expect(review.isAnonymous, isTrue);
      expect(review.isVerified, isTrue);
      expect(review.helpfulCount, 10);
      expect(review.helpfulVotes, contains('user1'));
    });

    test('fromMap() handles missing optional fields', () {
      final map = {
        'teacherId': 'teacher123',
        'teacherName': 'Dr. Smith',
        'teacherDepartment': 'Computer Science',
        'userId': 'user456',
        'userName': 'John Doe',
        'userEmail': 'johndoe@example.com',
        'text': 'Great teacher!',
        'rating': 4.5,
      };

      final review = Review.fromMap(map, 'review456');

      expect(review.id, 'review456');
      expect(review.teacherId, 'teacher123');
      expect(review.teacherName, 'Dr. Smith');
      expect(review.teacherDepartment, 'Computer Science');
      expect(review.userId, 'user456');
      expect(review.userName, 'John Doe');
      expect(review.userEmail, 'johndoe@example.com');
      expect(review.text, 'Great teacher!');
      expect(review.rating, 4.5);
      expect(review.ratingBreakdown['teaching'], 0.0); // Default value
      expect(review.tags, isEmpty); // Default value
      expect(review.timestamp, isNotNull); // Default to current time
      expect(review.courseCode, ''); // Default value
      expect(review.courseName, ''); // Default value
      expect(review.isAnonymous, isFalse); // Default value
      expect(review.isVerified, isFalse); // Default value
      expect(review.helpfulCount, 0); // Default value
      expect(review.helpfulVotes, isEmpty); // Default value
    });

    test('toMap() returns a correct map representation', () {
      final review = Review(
        id: 'review789',
        teacherId: 'teacher123',
        teacherName: 'Dr. Smith',
        teacherDepartment: 'Computer Science',
        userId: 'user456',
        userName: 'John Doe',
        userEmail: 'johndoe@example.com',
        text: 'Great teacher!',
        rating: 4.5,
        ratingBreakdown: {
          'teaching': 4.0,
          'knowledge': 5.0,
          'approachability': 3.5,
          'grading': 4.0,
        },
        tags: ['engaging', 'helpful'],
        timestamp: DateTime(2023, 1, 1),
        courseCode: 'CS101',
        courseName: 'Intro to Computer Science',
        isAnonymous: true,
        isVerified: true,
        helpfulCount: 10,
        helpfulVotes: ['user1', 'user2'],
      );

      final map = review.toMap();

      expect(map['teacherId'], 'teacher123');
      expect(map['teacherName'], 'Dr. Smith');
      expect(map['teacherDepartment'], 'Computer Science');
      expect(map['userId'], 'user456');
      expect(map['userName'], 'John Doe');
      expect(map['userEmail'], 'johndoe@example.com');
      expect(map['text'], 'Great teacher!');
      expect(map['rating'], 4.5);
      expect(map['ratingBreakdown']['teaching'], 4.0);
      expect(map['tags'], contains('engaging'));
      expect(map['courseCode'], 'CS101');
      expect(map['courseName'], 'Intro to Computer Science');
      expect(map['isAnonymous'], true);
      expect(map['isVerified'], true);
      expect(map['helpfulCount'], 10);
      expect(map['helpfulVotes'], contains('user1'));
    });
  });
}

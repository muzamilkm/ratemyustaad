import 'package:flutter_test/flutter_test.dart';
import 'package:ratemyustaad/models/teacher.dart';

void main() {
  group('Teacher Model', () {
    test('fromMap() creates a Teacher object with complete data', () {
      final map = {
        'name': 'Dr. Smith',
        'department': 'Computer Science',
        'institution': 'State University',
        'photoUrl': 'https://example.com/photo.jpg',
        'averageRating': 4.3,
        'reviewCount': 15,
        'ratingBreakdown': {
          'teaching': 4.5,
          'knowledge': 5.0,
          'approachability': 3.5,
          'grading': 4.0,
        },
        'isVerified': true,
      };

      final teacher = Teacher.fromMap(map, 'teacher123');

      expect(teacher.id, 'teacher123');
      expect(teacher.name, 'Dr. Smith');
      expect(teacher.department, 'Computer Science');
      expect(teacher.institution, 'State University');
      expect(teacher.photoUrl, 'https://example.com/photo.jpg');
      expect(teacher.averageRating, 4.3);
      expect(teacher.reviewCount, 15);
      expect(teacher.ratingBreakdown['teaching'], 4.5);
      expect(teacher.isVerified, isTrue);
    });

    test('fromMap() handles missing optional fields', () {
      final map = {
        'name': 'Dr. Johnson',
        'department': 'Mathematics',
        'institution': 'Tech Institute',
      };

      final teacher = Teacher.fromMap(map, 'teacher456');

      expect(teacher.id, 'teacher456');
      expect(teacher.name, 'Dr. Johnson');
      expect(teacher.department, 'Mathematics');
      expect(teacher.institution, 'Tech Institute');
      expect(teacher.photoUrl, isEmpty);
      expect(teacher.averageRating, 0.0);
      expect(teacher.reviewCount, 0);
      expect(teacher.ratingBreakdown['teaching'], 0.0);
      expect(teacher.isVerified, isFalse);
    });

    test('toMap() returns a correct map representation', () {
      final teacher = Teacher(
        id: 'teacher123',
        name: 'Dr. Smith',
        department: 'CS',
        institution: 'University',
        photoUrl: 'https://example.com/photo.jpg',
        averageRating: 4.3,
        reviewCount: 10,
        ratingBreakdown: {
          'teaching': 4.5,
          'knowledge': 5.0,
          'approachability': 3.5,
          'grading': 4.0,
        },
        isVerified: true,
      );

      final map = teacher.toMap();

      expect(map['name'], 'Dr. Smith');
      expect(map['department'], 'CS');
      expect(map['institution'], 'University');
      expect(map['photoUrl'], 'https://example.com/photo.jpg');
      expect(map['averageRating'], 4.3);
      expect(map['reviewCount'], 10);
      expect(map['ratingBreakdown']['teaching'], 4.5);
      expect(map['isVerified'], true);
    });

    test('copyWith() updates only specified fields', () {
      final original = Teacher(
        id: 'teacher123',
        name: 'Dr. Smith',
        department: 'CS',
        institution: 'University',
        isVerified: false,
      );

      final updated = original.copyWith(
        name: 'Dr. Johnson',
        isVerified: true,
      );

      expect(updated.id, 'teacher123'); // Unchanged
      expect(updated.name, 'Dr. Johnson'); // Updated
      expect(updated.department, 'CS'); // Unchanged
      expect(updated.institution, 'University'); // Unchanged
      expect(updated.isVerified, isTrue); // Updated
    });
  });
}

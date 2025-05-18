import 'package:flutter_test/flutter_test.dart';
import 'package:ratemyustaad/models/user_model.dart';

void main() {
  group('OnboardingUserModel', () {
    test('toMap should convert model to a map', () {
      final user = OnboardingUserModel(
        firstName: 'John',
        lastName: 'Doe',
        birthday: DateTime(2000, 1, 1),
        gender: 'Male',
        country: 'USA',
      );

      final map = user.toMap();

      expect(map['firstName'], 'John');
      expect(map['lastName'], 'Doe');
      expect(map['birthday'], DateTime(2000, 1, 1).millisecondsSinceEpoch);
      expect(map['gender'], 'Male');
      expect(map['country'], 'USA');
    });

    test('fromMap should create model from a map', () {
      final map = {
        'firstName': 'Jane',
        'lastName': 'Doe',
        'birthday': DateTime(1995, 5, 15).millisecondsSinceEpoch,
        'gender': 'Female',
        'country': 'Canada',
      };

      final user = OnboardingUserModel.fromMap(map);

      expect(user.firstName, 'Jane');
      expect(user.lastName, 'Doe');
      expect(user.birthday, DateTime(1995, 5, 15));
      expect(user.gender, 'Female');
      expect(user.country, 'Canada');
    });

    test('copyWith should create a copy with updated fields', () {
      final user = OnboardingUserModel(
        firstName: 'Alice',
        lastName: 'Smith',
        country: 'UK',
      );

      final updatedUser = user.copyWith(
        firstName: 'Bob',
        country: 'Germany',
      );

      expect(updatedUser.firstName, 'Bob');
      expect(updatedUser.lastName, 'Smith'); // Unchanged
      expect(updatedUser.country, 'Germany');
    });
  });
}

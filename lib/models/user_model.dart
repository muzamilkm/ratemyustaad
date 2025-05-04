class OnboardingUserModel {
  String? firstName;
  String? lastName;
  DateTime? birthday;
  String? gender;
  String? country;
  String? academicStatus;  // e.g., "Undergraduate", "Graduate", etc.
  String? university;
  String? major;
  String? graduationYear;
  String? careerGoal;  // e.g., "Research", "Industry", etc.
  Map<String, bool>? financialPreferences;  // e.g., {"Scholarship": true, "Student Loan": false}
  Map<String, bool>? livingPreferences;  // e.g., {"On-campus": true, "Off-campus": false}

  OnboardingUserModel({
    this.firstName,
    this.lastName,
    this.birthday,
    this.gender,
    this.country,
    this.academicStatus,
    this.university,
    this.major,
    this.graduationYear,
    this.careerGoal,
    this.financialPreferences,
    this.livingPreferences,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday?.millisecondsSinceEpoch,
      'gender': gender,
      'country': country,
      'academicStatus': academicStatus,
      'university': university,
      'major': major,
      'graduationYear': graduationYear,
      'careerGoal': careerGoal,
      'financialPreferences': financialPreferences,
      'livingPreferences': livingPreferences,
    };
  }

  // Create from a Firestore map
  factory OnboardingUserModel.fromMap(Map<String, dynamic> map) {
    return OnboardingUserModel(
      firstName: map['firstName'],
      lastName: map['lastName'],
      birthday: map['birthday'] != null ? DateTime.fromMillisecondsSinceEpoch(map['birthday']) : null,
      gender: map['gender'],
      country: map['country'],
      academicStatus: map['academicStatus'],
      university: map['university'],
      major: map['major'],
      graduationYear: map['graduationYear'],
      careerGoal: map['careerGoal'],
      financialPreferences: map['financialPreferences'] != null 
          ? Map<String, bool>.from(map['financialPreferences']) 
          : null,
      livingPreferences: map['livingPreferences'] != null 
          ? Map<String, bool>.from(map['livingPreferences']) 
          : null,
    );
  }

  // Create a copy with updated fields
  OnboardingUserModel copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? gender,
    String? country,
    String? academicStatus,
    String? university,
    String? major,
    String? graduationYear,
    String? careerGoal,
    Map<String, bool>? financialPreferences,
    Map<String, bool>? livingPreferences,
  }) {
    return OnboardingUserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      academicStatus: academicStatus ?? this.academicStatus,
      university: university ?? this.university,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
      careerGoal: careerGoal ?? this.careerGoal,
      financialPreferences: financialPreferences ?? this.financialPreferences,
      livingPreferences: livingPreferences ?? this.livingPreferences,
    );
  }
}
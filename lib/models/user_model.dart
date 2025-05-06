class OnboardingUserModel {
  String? firstName;
  String? lastName;
  DateTime? birthday;
  String? gender;
  String? country;
  
  // Academic background fields
  String? educationLevel;
  String? currentStatus;
  String? degreeProgram;
  String? academicStatus;  // study level (e.g., "Undergraduate", "Graduate", etc.)
  String? major;  // field of study
  
  // University preference fields
  String? studyLocation;
  String? universityType;
  String? universityRanking;
  String? universitySize;
  String? specificUniversity;  // specific university
  
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
    this.educationLevel,
    this.currentStatus,
    this.degreeProgram,
    this.academicStatus,
    this.major,
    this.studyLocation,
    this.universityType,
    this.universityRanking,
    this.universitySize,
    this.specificUniversity,
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
      'educationLevel': educationLevel,
      'currentStatus': currentStatus,
      'degreeProgram': degreeProgram,
      'academicStatus': academicStatus,
      'major': major,
      'studyLocation': studyLocation,
      'universityType': universityType,
      'universityRanking': universityRanking,
      'universitySize': universitySize,
      'university': specificUniversity,
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
      educationLevel: map['educationLevel'],
      currentStatus: map['currentStatus'],
      degreeProgram: map['degreeProgram'],
      academicStatus: map['academicStatus'],
      major: map['major'],
      studyLocation: map['studyLocation'],
      universityType: map['universityType'],
      universityRanking: map['universityRanking'],
      universitySize: map['universitySize'],
      specificUniversity: map['specificUniversity'],
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
    String? educationLevel,
    String? currentStatus,
    String? degreeProgram,
    String? academicStatus,
    String? major,
    String? studyLocation,
    String? universityType,
    String? universityRanking,
    String? universitySize,
    String? university,
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
      educationLevel: educationLevel ?? this.educationLevel,
      currentStatus: currentStatus ?? this.currentStatus,
      degreeProgram: degreeProgram ?? this.degreeProgram,
      academicStatus: academicStatus ?? this.academicStatus,
      major: major ?? this.major,
      studyLocation: studyLocation ?? this.studyLocation,
      universityType: universityType ?? this.universityType,
      universityRanking: universityRanking ?? this.universityRanking,
      universitySize: universitySize ?? this.universitySize,
      specificUniversity: university ?? this.specificUniversity,
      graduationYear: graduationYear ?? this.graduationYear,
      careerGoal: careerGoal ?? this.careerGoal,
      financialPreferences: financialPreferences ?? this.financialPreferences,
      livingPreferences: livingPreferences ?? this.livingPreferences,
    );
  }
}
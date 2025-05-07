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
  
  // Career goals fields
  String? fieldOfInterest;
  String? careerGoal;  // e.g., "Research", "Industry", etc.
  String? partTimeWork;
  String? internships;
  String? entrepreneurship;
  Map<String, String>? careerPreferences;  // For storing all career-related preferences

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
    this.fieldOfInterest,
    this.careerGoal,
    this.partTimeWork,
    this.internships,
    this.entrepreneurship,
    this.careerPreferences,
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
      'fieldOfInterest': fieldOfInterest,
      'careerGoal': careerGoal,
      'partTimeWork': partTimeWork,
      'internships': internships,
      'entrepreneurship': entrepreneurship,
      'careerPreferences': careerPreferences,
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
      specificUniversity: map['university'],
      graduationYear: map['graduationYear'],
      fieldOfInterest: map['fieldOfInterest'],
      careerGoal: map['careerGoal'],
      partTimeWork: map['partTimeWork'],
      internships: map['internships'],
      entrepreneurship: map['entrepreneurship'],
      careerPreferences: map['careerPreferences'] != null 
          ? Map<String, String>.from(map['careerPreferences']) 
          : null,
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
    String? fieldOfInterest,
    String? careerGoal,
    String? partTimeWork,
    String? internships,
    String? entrepreneurship,
    Map<String, String>? careerPreferences,
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
      fieldOfInterest: fieldOfInterest ?? this.fieldOfInterest,
      careerGoal: careerGoal ?? this.careerGoal,
      partTimeWork: partTimeWork ?? this.partTimeWork,
      internships: internships ?? this.internships,
      entrepreneurship: entrepreneurship ?? this.entrepreneurship,
      careerPreferences: careerPreferences ?? this.careerPreferences,
      financialPreferences: financialPreferences ?? this.financialPreferences,
      livingPreferences: livingPreferences ?? this.livingPreferences,
    );
  }
}
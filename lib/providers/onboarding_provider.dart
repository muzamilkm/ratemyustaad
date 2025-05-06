import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class OnboardingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  OnboardingUserModel _userData = OnboardingUserModel();
  bool _isLoading = false;
  String? _error;
  int _currentStep = 0;
  bool _onboardingCompleted = false;
  
  // Getters
  OnboardingUserModel get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStep => _currentStep;
  bool get onboardingCompleted => _onboardingCompleted;
  
  // Check if user has completed onboarding
  Future<bool> checkOnboardingStatus() async {
    if (_auth.currentUser == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['onboardingCompleted'] == true) {
          _onboardingCompleted = true;
          _userData = OnboardingUserModel.fromMap(userData);
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return _onboardingCompleted;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update user data for a specific step
  void updateUserData({
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
    String? specificUniversity,
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
    _userData = _userData.copyWith(
      firstName: firstName,
      lastName: lastName,
      birthday: birthday,
      gender: gender,
      country: country,
      educationLevel: educationLevel,
      currentStatus: currentStatus,
      degreeProgram: degreeProgram,
      academicStatus: academicStatus,
      major: major,
      studyLocation: studyLocation,
      universityType: universityType,
      universityRanking: universityRanking,
      universitySize: universitySize,
      university: specificUniversity,
      graduationYear: graduationYear,
      fieldOfInterest: fieldOfInterest,
      careerGoal: careerGoal,
      partTimeWork: partTimeWork,
      internships: internships,
      entrepreneurship: entrepreneurship,
      careerPreferences: careerPreferences,
      financialPreferences: financialPreferences,
      livingPreferences: livingPreferences,
    );
    
    notifyListeners();
  }
  
  // Move to next step
  void nextStep() {
    _currentStep++;
    notifyListeners();
  }
  
  // Move to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
  
  // Save all user data to Firestore
  Future<bool> saveUserData() async {
    if (_auth.currentUser == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final userMap = _userData.toMap();
      userMap['onboardingCompleted'] = true;
      userMap['email'] = _auth.currentUser!.email;
      userMap['userId'] = _auth.currentUser!.uid;
      userMap['createdAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set(userMap, SetOptions(merge: true));
      
      _onboardingCompleted = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Skip onboarding
  Future<bool> skipOnboarding() async {
    if (_auth.currentUser == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({
            'onboardingCompleted': true,
            'email': _auth.currentUser!.email,
            'userId': _auth.currentUser!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      _onboardingCompleted = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Reset error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
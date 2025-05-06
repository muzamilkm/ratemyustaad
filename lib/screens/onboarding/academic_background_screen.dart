import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratemyustaad/providers/onboarding_provider.dart';

class OnboardingAcademicBackgroundScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const OnboardingAcademicBackgroundScreen({
    Key? key,
    required this.onContinue,
    required this.onSkip,
    required this.onBack,
  }) : super(key: key);

  @override
  State<OnboardingAcademicBackgroundScreen> createState() =>
      _OnboardingAcademicBackgroundScreenState();
}

class _OnboardingAcademicBackgroundScreenState
    extends State<OnboardingAcademicBackgroundScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _educationLevel;
  String? _currentStatus;
  String? _degreeProgram;
  String? _studyLevel;
  String? _fieldOfStudy;

  final List<String> _educationLevels = [
    'High School',
    'Associate',
    'Bachelor',
    'Master',
    'Doctorate',
    'Professional (MD, JD, etc.)',
    'Other'
  ];

  final List<String> _educationStatuses = [
    'Currently enrolled',
    'On break',
    'Graduated',
    'Not currently enrolled'
  ];

  final List<String> _degreePrograms = [
    'Computer Science',
    'Engineering',
    'Business Administration',
    'Medicine',
    'Law',
    'Arts & Humanities',
    'Social Sciences',
    'Education',
    'Other'
  ];

  final List<String> _studyLevels = [
    'Undergraduate',
    'Graduate',
    'Postgraduate',
    'PhD',
    'Other'
  ];

  // Constants for consistent styling
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const hintTextColor = Color(0xFF708090);
  static const borderColor = Color(0xFFCBD5E1);
  static const backgroundColor = Color(0xFFF0F8FF);

  // Text styles for reuse
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.3,
    letterSpacing: -0.02,
    color: darkTextColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.5,
    letterSpacing: -0.03,
    color: hintTextColor,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: -0.01,
    color: darkTextColor,
  );

  static const TextStyle inputTextStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    letterSpacing: -0.01,
    color: darkTextColor,
  );

  static const TextStyle hintStyle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
    fontSize: 15,
    letterSpacing: -0.01,
    color: hintTextColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    color: Colors.white,
  );

  Widget _buildInputField({
    required String label,
    required Widget child,
    double bottomPadding = 24.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required void Function(String) onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          isDense: true,
        ),
        style: inputTextStyle,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          isDense: true,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: hintTextColor,
        ),
        style: inputTextStyle,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: darkTextColor, size: 20),
          onPressed: widget.onBack,
        ),
        actions: [
          TextButton(
            onPressed: widget.onSkip,
            child: const Text(
              "Skip",
              style: TextStyle(
                color: primaryColor,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAECF0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width *
                              0.25, // 2/8 steps completed
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title and subtitle
                  const Text("Your Academic Background", style: headingStyle),
                  const SizedBox(height: 8),
                  const Text(
                    "We'll ask you a few questions to tailor your experience",
                    style: subheadingStyle,
                  ),
                  const SizedBox(height: 32),

                  // Education Level field
                  _buildInputField(
                    label: "Highest Education Level",
                    child: _buildDropdownField(
                      hintText: "Select education level",
                      value: _educationLevel,
                      items: _educationLevels,
                      onChanged: (value) {
                        setState(() {
                          _educationLevel = value;
                        });
                      },
                    ),
                  ),

                  // Current Status field
                  _buildInputField(
                    label: "Current Education Status",
                    child: _buildDropdownField(
                      hintText: "Select status",
                      value: _currentStatus,
                      items: _educationStatuses,
                      onChanged: (value) {
                        setState(() {
                          _currentStatus = value;
                        });
                      },
                    ),
                  ),

                  // Degree Program field
                  _buildInputField(
                    label: "Preferred Degree Program",
                    child: _buildDropdownField(
                      hintText: "Select program",
                      value: _degreeProgram,
                      items: _degreePrograms,
                      onChanged: (value) {
                        setState(() {
                          _degreeProgram = value;
                        });
                      },
                    ),
                  ),

                  // Study Level field
                  _buildInputField(
                    label: "Intended Study Level",
                    child: _buildDropdownField(
                      hintText: "Select study level",
                      value: _studyLevel,
                      items: _studyLevels,
                      onChanged: (value) {
                        setState(() {
                          _studyLevel = value;
                        });
                      },
                    ),
                  ),

                  // Field of Study field
                  _buildInputField(
                    label: "Intended Field",
                    bottomPadding: 36.0,
                    child: _buildTextField(
                      hintText: "What's your field of choice?",
                      onChanged: (value) {
                        setState(() {
                          _fieldOfStudy = value;
                        });
                      },
                    ),
                  ),

                  // Continue button
                  Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x335E17EB),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final onboardingProvider =
                              Provider.of<OnboardingProvider>(context,
                                  listen: false);

                          // Save all collected fields to the provider
                          onboardingProvider.updateUserData(
                            educationLevel: _educationLevel,
                            currentStatus: _currentStatus,
                            degreeProgram: _degreeProgram,
                            academicStatus: _studyLevel,
                            major: _fieldOfStudy,
                          );

                          widget.onContinue();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Continue", style: buttonTextStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

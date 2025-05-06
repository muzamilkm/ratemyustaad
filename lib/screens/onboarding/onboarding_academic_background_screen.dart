import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratemyustaad/providers/onboarding_provider.dart';

class OnboardingAcademicBackgroundScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const OnboardingAcademicBackgroundScreen({
    Key? key,
    required this.onContinue,
    required this.onSkip,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF01242D), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: widget.onSkip,
            child: const Text(
              "Skip",
              style: TextStyle(
                color: Color(0xFF5E17EB),
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  Container(
                    width: double.infinity,
                    height: 4,
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
                            color: const Color(0xFF5E17EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Your Academic Background",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      letterSpacing: -0.02,
                      color: Color(0xFF01242D),
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    "We'll ask you a few questions to tailor your experience",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      letterSpacing: -0.03,
                      color: Color(0xFF708090),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Highest Education Level",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: -0.03,
                      color: Color(0xFF01242D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDropdownField(
                    hintText: "What's your highest level of education?",
                    value: _educationLevel,
                    items: _educationLevels,
                    onChanged: (value) {
                      setState(() {
                        _educationLevel = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Current Education Status",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: -0.03,
                      color: Color(0xFF01242D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDropdownField(
                    hintText: "Are you currently enrolled in a program?",
                    value: _currentStatus,
                    items: _educationStatuses,
                    onChanged: (value) {
                      setState(() {
                        _currentStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Preferred Degree Program",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: -0.03,
                      color: Color(0xFF01242D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDropdownField(
                    hintText: "What degree program are you pursuing?",
                    value: _degreeProgram,
                    items: _degreePrograms,
                    onChanged: (value) {
                      setState(() {
                        _degreeProgram = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Intended Study Level",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: -0.03,
                      color: Color(0xFF01242D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDropdownField(
                    hintText: "What level of education are you pursuing?",
                    value: _studyLevel,
                    items: _studyLevels,
                    onChanged: (value) {
                      setState(() {
                        _studyLevel = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Intended Field",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: -0.03,
                      color: Color(0xFF01242D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: "What's your field of choice?",
                        hintStyle: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          letterSpacing: -0.03,
                          color: Color(0xFF708090),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        letterSpacing: -0.03,
                        color: Color(0xFF01242D),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _fieldOfStudy = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E17EB),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 15,
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
                          onboardingProvider.updateUserData(
                            academicStatus: _studyLevel,
                            major: _fieldOfStudy,
                          );

                          widget.onContinue();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.04,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
            fontSize: 15,
            letterSpacing: -0.03,
            color: Color(0xFF708090),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: InputBorder.none,
          isDense: true,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF708090),
        ),
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          letterSpacing: -0.03,
          color: Color(0xFF01242D),
        ),
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

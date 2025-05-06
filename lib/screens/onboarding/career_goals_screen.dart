import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratemyustaad/providers/onboarding_provider.dart';

class OnboardingCareerGoalsScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const OnboardingCareerGoalsScreen({
    Key? key,
    required this.onContinue,
    required this.onSkip,
    required this.onBack,
  }) : super(key: key);

  @override
  State<OnboardingCareerGoalsScreen> createState() =>
      _OnboardingCareerGoalsScreenState();
}

class _OnboardingCareerGoalsScreenState
    extends State<OnboardingCareerGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fieldOfInterest;
  String? _careerGoal;
  String? _partTimeWork;
  String? _internships;
  String? _entrepreneurship;

  // List of field of interest options
  final List<String> _fieldsOfInterest = [
    'Business & Management',
    'Computer Science & IT',
    'Engineering',
    'Healthcare & Medicine',
    'Social Sciences',
    'Arts & Humanities',
    'Natural Sciences',
    'Education',
    'Law',
    'Agriculture & Environment',
    'Other'
  ];

  // List of career goal options
  final List<String> _careerGoals = [
    'Industry Position',
    'Academic Career',
    'Research',
    'Entrepreneurship',
    'Public Service',
    'Further Education',
    'Self-Employment',
    'Non-Profit Work',
    'Still Exploring',
    'Other'
  ];

  // List of yes/no options
  final List<String> _yesNoOptions = ['Yes', 'No', 'Not Sure'];

  // Constants for consistent styling - matching get_started_screen
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
        child: Column(
          children: [
            Expanded(
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
                                    0.55, // 4/8 steps completed
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
                        const Text("Your Career Goals", style: headingStyle),
                        const SizedBox(height: 8),
                        const Text(
                          "We'll ask you a few questions to tailor your experience",
                          style: subheadingStyle,
                        ),
                        const SizedBox(height: 32),

                        // Field of Interest
                        _buildInputField(
                          label: "Field of Interest",
                          child: _buildDropdownField(
                            hintText: "Select your main area of interest",
                            value: _fieldOfInterest,
                            items: _fieldsOfInterest,
                            onChanged: (value) {
                              setState(() {
                                _fieldOfInterest = value;
                              });
                            },
                          ),
                        ),

                        // Career Goal
                        _buildInputField(
                          label: "Career Goal",
                          child: _buildDropdownField(
                            hintText: "Select your long term goal",
                            value: _careerGoal,
                            items: _careerGoals,
                            onChanged: (value) {
                              setState(() {
                                _careerGoal = value;
                              });
                            },
                          ),
                        ),

                        // Part-Time Work
                        _buildInputField(
                          label: "Part-Time Work",
                          child: _buildDropdownField(
                            hintText: "Are you open to part-time work?",
                            value: _partTimeWork,
                            items: _yesNoOptions,
                            onChanged: (value) {
                              setState(() {
                                _partTimeWork = value;
                              });
                            },
                          ),
                        ),

                        // Internships & Co-ops
                        _buildInputField(
                          label: "Internships & Co-ops",
                          child: _buildDropdownField(
                            hintText: "Are you interested in internships?",
                            value: _internships,
                            items: _yesNoOptions,
                            onChanged: (value) {
                              setState(() {
                                _internships = value;
                              });
                            },
                          ),
                        ),

                        // Entrepreneurship
                        _buildInputField(
                          label: "Entrepreneurship?",
                          bottomPadding: 36.0,
                          child: _buildDropdownField(
                            hintText: "Are you interested in entrepreneurship?",
                            value: _entrepreneurship,
                            items: _yesNoOptions,
                            onChanged: (value) {
                              setState(() {
                                _entrepreneurship = value;
                              });
                            },
                          ),
                        ),

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

                                // Update user data with both individual fields and the map
                                onboardingProvider.updateUserData(
                                  fieldOfInterest: _fieldOfInterest,
                                  careerGoal: _careerGoal,
                                  partTimeWork: _partTimeWork,
                                  internships: _internships,
                                  entrepreneurship: _entrepreneurship,                                  
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
                            child:
                                const Text("Continue", style: buttonTextStyle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

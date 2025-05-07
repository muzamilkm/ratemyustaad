import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratemyustaad/providers/onboarding_provider.dart';

class OnboardingUniversityPreferencesScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const OnboardingUniversityPreferencesScreen({
    Key? key,
    required this.onContinue,
    required this.onSkip,
    required this.onBack,
  }) : super(key: key);

  @override
  State<OnboardingUniversityPreferencesScreen> createState() =>
      _OnboardingUniversityPreferencesScreenState();
}

class _OnboardingUniversityPreferencesScreenState
    extends State<OnboardingUniversityPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _studyLocation;
  String? _universityType;
  String? _universityRanking;
  String? _universitySize;
  String? _specificUniversity;

  // List of countries for study location
  final List<String> _countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'Pakistan',
    'India',
    'Germany',
    'France',
    'China',
    'Japan',
    // Add more countries as needed
  ];

  // List of university types
  final List<String> _universityTypes = [
    'Public',
    'Private',
    'Community College',
    'Liberal Arts',
    'Research University',
    'Technical Institute',
    'Online University',
    'No Preference'
  ];

  // List of university rankings
  final List<String> _universityRankings = [
    'Top 10',
    'Top 50',
    'Top 100',
    'Top 500',
    'Not ranked',
    'No Preference'
  ];

  // List of university sizes
  final List<String> _universitySizes = [
    'Small (< 5,000 students)',
    'Medium (5,000 - 15,000 students)',
    'Large (15,000 - 30,000 students)',
    'Very Large (> 30,000 students)',
    'No Preference'
  ];

  // Constants for consistent styling - updated to match get_started_screen
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
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: hintTextColor,
          ),
        ),
        style: inputTextStyle,
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
                                    0.6, // Changed from 0.40 to 0.6 (3/5)
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
                        const Text("Your University Preferences",
                            style: headingStyle),
                        const SizedBox(height: 8),
                        const Text(
                          "We'll ask you a few questions to tailor your experience",
                          style: subheadingStyle,
                        ),
                        const SizedBox(height: 32),

                        // Study Location field
                        _buildInputField(
                          label: "Study Location",
                          child: _buildDropdownField(
                            hintText: "Select a country",
                            value: _studyLocation,
                            items: _countries,
                            onChanged: (value) {
                              setState(() {
                                _studyLocation = value;
                              });
                            },
                          ),
                        ),

                        // University Type field
                        _buildInputField(
                          label: "University Type",
                          child: _buildDropdownField(
                            hintText: "Select University Type",
                            value: _universityType,
                            items: _universityTypes,
                            onChanged: (value) {
                              setState(() {
                                _universityType = value;
                              });
                            },
                          ),
                        ),

                        // University Ranking field
                        _buildInputField(
                          label: "University Ranking",
                          child: _buildDropdownField(
                            hintText: "Select University Ranking",
                            value: _universityRanking,
                            items: _universityRankings,
                            onChanged: (value) {
                              setState(() {
                                _universityRanking = value;
                              });
                            },
                          ),
                        ),

                        // University Size field
                        _buildInputField(
                          label: "University Size",
                          child: _buildDropdownField(
                            hintText: "Select University Size",
                            value: _universitySize,
                            items: _universitySizes,
                            onChanged: (value) {
                              setState(() {
                                _universitySize = value;
                              });
                            },
                          ),
                        ),

                        // Specific University field
                        _buildInputField(
                          label: "Specific University?",
                          bottomPadding: 36.0,
                          child: _buildTextField(
                            hintText:
                                "Is there a university you're considering?",
                            onChanged: (value) {
                              setState(() {
                                _specificUniversity = value;
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
                                onboardingProvider.updateUserData(
                                  studyLocation: _studyLocation,
                                  universityType: _universityType,
                                  universityRanking: _universityRanking,
                                  universitySize: _universitySize,
                                  specificUniversity: _specificUniversity,
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

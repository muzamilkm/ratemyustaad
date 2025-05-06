import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ratemyustaad/providers/onboarding_provider.dart';

class OnboardingGetStartedScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const OnboardingGetStartedScreen({
    Key? key,
    required this.onContinue,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<OnboardingGetStartedScreen> createState() =>
      _OnboardingGetStartedScreenState();
}

class _OnboardingGetStartedScreenState
    extends State<OnboardingGetStartedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _birthday;
  String? _gender;
  String? _country;

  // List of countries (simplified for this example)
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

  // List of gender options
  final List<String> _genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _birthday ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF01242D),
              onPrimary: Colors.white,
              onSurface: const Color(0xFF01242D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
      });
    }
  }

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
                          width: MediaQuery.of(context).size.width * 0.1,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5E17EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    "Let's get started",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      letterSpacing: -0.02,
                      color: Color(0xFF01242D),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
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

                  // First Name field
                  const Text(
                    "First Name",
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
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        hintText: "Enter First Name",
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Last Name field
                  const Text(
                    "Last Name",
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
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        hintText: "Enter Last Name",
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Birthday field
                  const Text(
                    "Birthday",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: -0.03,
                      color: Color(0xFF01242D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _birthday == null
                                  ? "When is your birthday?"
                                  : DateFormat('MMM d, yyyy')
                                      .format(_birthday!),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                letterSpacing: -0.03,
                                color: _birthday == null
                                    ? const Color(0xFF708090)
                                    : const Color(0xFF01242D),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF708090),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender field
                  const Text(
                    "Gender",
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
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        hintText: "Select Gender",
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
                      items: _genders
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _gender = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Country field
                  const Text(
                    "Where are you from?",
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
                    child: DropdownButtonFormField<String>(
                      value: _country,
                      decoration: const InputDecoration(
                        hintText: "Select Country",
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
                      items: _countries
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _country = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Continue button
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
                          // Update the data in provider
                          final onboardingProvider =
                              Provider.of<OnboardingProvider>(context,
                                  listen: false);
                          onboardingProvider.updateUserData(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            birthday: _birthday,
                            gender: _gender,
                            country: _country,
                          );

                          // Proceed to next screen
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
}

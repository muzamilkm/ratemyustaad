import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ratemyustaad/providers/onboarding_provider.dart';
import 'package:ratemyustaad/providers/auth_provider.dart';

class OnboardingGetStartedScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const OnboardingGetStartedScreen({
    Key? key,
    required this.onContinue,
    required this.onSkip,
    required this.onBack,
  }) : super(key: key);

  @override
  State<OnboardingGetStartedScreen> createState() =>
      _OnboardingGetStartedScreenState();
}

class _OnboardingGetStartedScreenState
    extends State<OnboardingGetStartedScreen> {  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _birthday;
  String? _gender;
  String? _country;
  // ValueNotifier to control the validation message visibility
  final ValueNotifier<bool> _showValidationMessage = ValueNotifier<bool>(false);

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
    _showValidationMessage.dispose();
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5E17EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF01242D),
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
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade200),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        errorStyle: const TextStyle(
          height: 0, // Hide error text but keep the space
        ),
      ),
      style: inputTextStyle,
      validator: validator,
    );
  }  Widget _buildDropdown({
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade200),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        errorStyle: const TextStyle(
          height: 0, // Hide error text but keep the space
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: hintTextColor,
      ),
      style: inputTextStyle,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return ' '; // Non-null but empty message
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,        leading: IconButton(
          icon: const Icon(Icons.logout,
              color: darkTextColor, size: 20),
          tooltip: 'Sign Out',
          onPressed: () async {
            // Show confirmation dialog
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ) ?? false;
            
            if (confirmed && context.mounted) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/landing');
              }
            }
          },
        ),
        // Skip button removed for mandatory first screen
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
                              0.2, // Changed from 0.1 to 0.2 (1/5)
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),                  // Title and subtitle
                  const Text("Let's get started", style: headingStyle),
                  const SizedBox(height: 8),
                  const Text(
                    "We'll ask you a few questions to tailor your experience",
                    style: subheadingStyle,
                  ),
                  
                  // Validation message container - initially hidden
                  ValueListenableBuilder<bool>(
                    valueListenable: _showValidationMessage,
                    builder: (context, showMessage, child) {
                      return showMessage
                          ? Container(
                              margin: const EdgeInsets.only(top: 16, bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.red),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Please fill all the fields below to continue",
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(height: 32);
                    },
                  ),

                  // First Name field
                  _buildInputField(
                    label: "First Name",
                    child: _buildTextField(
                      controller: _firstNameController,
                      hintText: "Enter First Name",                      validator: (value) {
                        // Just return null or non-null to indicate validation state
                        // without showing a message
                        if (value == null || value.isEmpty) {
                          return ' '; // Non-null but empty message
                        }
                        return null;
                      },
                    ),
                  ),

                  // Last Name field
                  _buildInputField(
                    label: "Last Name",
                    child: _buildTextField(
                      controller: _lastNameController,
                      hintText: "Enter Last Name",                      validator: (value) {
                        // Just return null or non-null to indicate validation state
                        // without showing a message
                        if (value == null || value.isEmpty) {
                          return ' '; // Non-null but empty message
                        }
                        return null;
                      },
                    ),
                  ),                  // Birthday field
                  _buildInputField(
                    label: "Birthday",
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _formKey.currentState?.validate() == false && _birthday == null ? Colors.red.shade200 : borderColor),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _birthday == null
                                    ? "When is your birthday?"
                                    : DateFormat('MMM d, yyyy')
                                        .format(_birthday!),
                                style: _birthday == null
                                    ? hintStyle
                                    : inputTextStyle,
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: hintTextColor,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Gender field
                  _buildInputField(
                    label: "Gender",
                    child: _buildDropdown(
                      hintText: "Select Gender",
                      value: _gender,
                      items: _genders,
                      onChanged: (String? newValue) {
                        setState(() {
                          _gender = newValue!;
                        });
                      },
                    ),
                  ),

                  // Country field
                  _buildInputField(
                    label: "Where are you from?",
                    bottomPadding: 36.0,
                    child: _buildDropdown(
                      hintText: "Select Country",
                      value: _country,
                      items: _countries,
                      onChanged: (String? newValue) {
                        setState(() {
                          _country = newValue!;
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
                    ),                    child: ElevatedButton(                      onPressed: () {
                        if (_formKey.currentState!.validate() && _birthday != null && _gender != null && _country != null) {
                          // All fields are valid, hide validation message if it was showing
                          _showValidationMessage.value = false;
                          
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
                        } else {
                          // Show validation message
                          _showValidationMessage.value = true;
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

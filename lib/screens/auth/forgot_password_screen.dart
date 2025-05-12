import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isResetting = false;
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Light blue background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF5E17EB), // Purple color
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Heading
                  const SizedBox(height: 32),
                  const Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      letterSpacing: -0.02,
                      color: Color(0xFF01242D),
                    ),
                  ),

                  // Subheading
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your email address and we'll send you a link to reset your password",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: -0.03,
                      color: Color(0xFF708090),
                    ),
                  ),

                  // Email field
                  const SizedBox(height: 32),
                  const Text(
                    "Email address",
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Enter your email address",
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
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Success message (shown only after reset email is sent)
                  if (_resetEmailSent)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Password reset email sent to ${_emailController.text}. Please check your inbox.",
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Reset password button
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (authProvider.error != null && !_resetEmailSent)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        authProvider.error!,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5E17EB), // Purple theme
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
                              onPressed: (authProvider.isLoading ||
                                      _isResetting || _resetEmailSent)
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        // Set local loading state immediately
                                        setState(() {
                                          _isResetting = true;
                                        });

                                        // Hide keyboard
                                        FocusScope.of(context).unfocus();

                                        final success = await authProvider
                                            .resetPassword(
                                                _emailController.text.trim());

                                        // Reset local loading state if mounted
                                        if (mounted) {
                                          setState(() {
                                            _isResetting = false;
                                            if (success) {
                                              _resetEmailSent = true;
                                            }
                                          });
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor:
                                    Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _resetEmailSent
                                    ? "Email Sent"
                                    : authProvider.isLoading || _isResetting
                                        ? "Sending..."
                                        : "Reset Password",
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: -0.03,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Go back to login text button (only shown after email is sent)
                  if (_resetEmailSent)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Back to Login",
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: -0.03,
                              color: Color(0xFF5E17EB), // Purple theme
                            ),
                          ),
                        ),
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

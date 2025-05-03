import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';

class EmailSignupScreen extends StatefulWidget {
  const EmailSignupScreen({super.key});

  @override
  State<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends State<EmailSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // Add a local loading state to track button press before authProvider updates
  bool _isCreatingAccount = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Light blue background from CSS
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
                            color: Color(0xFF5E17EB),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Step indicator text
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        "Step 1 of 2",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          letterSpacing: -0.03,
                          color: Color(0xFF708090),
                        ),
                      ),
                    ),
                  ),
                  
                  // Heading
                  const SizedBox(height: 24),
                  const Text(
                    "Create account",
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
                    "Enter your details to get started",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: -0.03,
                      color: Color(0xFF708090),
                    ),
                  ),
                  
                  // Form fields
                  const SizedBox(height: 24),
                  
                  // Email field
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  
                  // Password field
                  const SizedBox(height: 20),
                  const Text(
                    "Password",
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
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Create a password",
                        hintStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          letterSpacing: -0.03,
                          color: Color(0xFF708090),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: InputBorder.none,
                        isDense: true,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF708090),
                              size: 18,
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        letterSpacing: -0.03,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  // Confirm Password field
                  const SizedBox(height: 20),
                  const Text(
                    "Confirm Password",
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
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: "Confirm your password",
                        hintStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          letterSpacing: -0.03,
                          color: Color(0xFF708090),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: InputBorder.none,
                        isDense: true,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF708090),
                              size: 18,
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        letterSpacing: -0.03,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  // Sign Up button
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (authProvider.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                authProvider.error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                          Container(
                            height: 52,
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
                              onPressed: (authProvider.isLoading || _isCreatingAccount)
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        // Set local loading state to true immediately
                                        setState(() {
                                          _isCreatingAccount = true;
                                        });
                                        
                                        // Hide keyboard
                                        FocusScope.of(context).unfocus();
                                        
                                        final success = await authProvider.createAccount(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        );

                                        // Reset local loading state if mounted
                                        if (mounted) {
                                          setState(() {
                                            _isCreatingAccount = false;
                                          });
                                        }

                                        if (success && context.mounted) {
                                          // Show success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Account created successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          
                                          // Navigate to home
                                          Navigator.of(context).pushReplacementNamed('/home');
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: (authProvider.isLoading || _isCreatingAccount)
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Creating Account",
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.04,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      "Sign up",
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
                        ],
                      );
                    },
                  ),
                  
                  // Terms and conditions text
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "By signing up, you agree to our Terms of Service\nand Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: -0.03,
                        color: Color(0xFF708090),
                      ),
                    ),
                  ),
                  
                  // OR divider
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            letterSpacing: -0.03,
                            color: Color(0xFF01242D),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                  
                  // Google sign up button
                  const SizedBox(height: 24),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 15,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        // No functionality yet as per requirements
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Using a colored container for Google logo colors
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Stack(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Container(color: Color(0xFF4285F4)),
                                              ),
                                              Expanded(
                                                child: Container(color: Color(0xFF34A853)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Container(color: Color(0xFFEA4335)),
                                              ),
                                              Expanded(
                                                child: Container(color: Color(0xFFFBBC05)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            "Continue with Google",
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.04,
                              color: Color(0xFF01242D),
                            ),
                          ),
                        ],
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
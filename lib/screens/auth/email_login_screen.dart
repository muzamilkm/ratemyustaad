import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'email_signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/onboarding_helper.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  // Add a local loading state for immediate UI feedback
  bool _isLoggingIn = false;
  // Add remember me state
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF0F8FF), // Light blue background from CSS
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
                            color: Color(
                                0xFF5E17EB), // Using purple color to match signup page
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Step indicator text (top right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        "Welcome back",
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
                    "Login",
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
                    "Enter your credentials to access your account",
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
                        hintText: "Enter your password",
                        hintStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          letterSpacing: -0.03,
                          color: Color(0xFF708090),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
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
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Remember me & Forgot password row
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember me checkbox with text
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _rememberMe
                                      ? const Color(0xFF5E17EB)
                                      : const Color(0xFFCBD5E1),
                                  width: 0.75,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                color: _rememberMe
                                    ? const Color(0xFF5E17EB)
                                    : Colors.white,
                              ),
                              child: _rememberMe
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: const Text(
                              "Remember me",
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: -0.03,
                                color: Color(0xFF708090),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Forgot password link
                      GestureDetector(
                        onTap: () {
                          _showForgotPasswordDialog(context);
                        },
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            letterSpacing: -0.03,
                            color: Color(
                                0xFF5E17EB), // Changed to match purple theme
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Login button
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
                              color: const Color(
                                  0xFF5E17EB), // Changed color to match purple theme
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
                                      _isLoggingIn)
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        // Set local loading state immediately
                                        setState(() {
                                          _isLoggingIn = true;
                                        });

                                        // Hide keyboard
                                        FocusScope.of(context).unfocus();

                                        final success =
                                            await authProvider.signInWithEmail(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        );

                                        // Save credentials if remember me is checked
                                        if (success && _rememberMe) {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          await prefs.setString('email',
                                              _emailController.text.trim());
                                          await prefs.setString('password',
                                              _passwordController.text);
                                          await prefs.setBool(
                                              'rememberMe', true);
                                        }

                                        // Reset local loading state if mounted
                                        if (mounted) {
                                          setState(() {
                                            _isLoggingIn = false;
                                          });
                                        }

                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Successfully signed in!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          final completed =
                                              await OnboardingHelper
                                                  .isOnboardingCompleted();
                                          if (!completed) {
                                            Navigator.of(context)
                                                .pushReplacementNamed(
                                                    '/onboarding');
                                          } else {
                                            Navigator.of(context)
                                                .pushReplacementNamed('/home');
                                          }
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
                              child: (authProvider.isLoading || _isLoggingIn)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          "Logging In",
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
                                      "Login",
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

                  // Google sign in button (non-functional for now)
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
                      onPressed: () async {
                        // Show loading state
                        setState(() {
                          _isLoggingIn = true;
                        });                        try {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          final success = await authProvider.signInWithGoogle();                          if (success && mounted) {
                            // Reset loading state
                            setState(() {
                              _isLoggingIn = false;
                            });
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Successfully signed in with Google!'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Check if onboarding is completed
                            final completed = await OnboardingHelper.isOnboardingCompleted();
                            if (!completed) {
                              // If onboarding not completed, navigate to onboarding flow
                              Navigator.of(context).pushReplacementNamed('/onboarding');
                            } else {
                              // If onboarding completed, navigate to home screen
                              Navigator.of(context).pushReplacementNamed('/home');
                            }
                          } else if (mounted) {
                            // Reset loading state if sign-in was unsuccessful or canceled
                            setState(() {
                              _isLoggingIn = false;
                            });

                            if (authProvider.error != null) {
                              // Show error if there was one
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authProvider.error!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              _isLoggingIn = false;
                            });

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Google sign-in failed: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
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
                          // Using a styled container for Google logo colors
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
                                                child: Container(
                                                    color: Color(0xFF4285F4)),
                                              ),
                                              Expanded(
                                                child: Container(
                                                    color: Color(0xFF34A853)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                    color: Color(0xFFEA4335)),
                                              ),
                                              Expanded(
                                                child: Container(
                                                    color: Color(0xFFFBBC05)),
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

                  // No account text with sign up link
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF708090),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmailSignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF5E17EB), // Match brand color
                          ),
                        ),
                      ),
                    ],
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

  // Existing dialog for password reset
  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await authProvider
                          .resetPassword(emailController.text.trim());
                      if (context.mounted) {
                        Navigator.of(context).pop();

                        // Show message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              authProvider.error != null
                                  ? authProvider.error!
                                  : 'Password reset email sent. Check your inbox.',
                            ),
                            backgroundColor: authProvider.error != null
                                ? Colors.red
                                : Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Send Reset Link'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

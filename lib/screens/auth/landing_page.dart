import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F8FF), // Light blue background from CSS
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Stack(
          children: [
            // Logo at the top center portion
            Positioned(
              left: (MediaQuery.of(context).size.width - 292) / 2,
              top: MediaQuery.of(context).size.height * 0.2,
              child: Image.asset(
                'assets/images/Logo.png',
                width: 292,
                height: 218,
              ),
            ),
            
            // Bottom white container with text and buttons
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 292,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 16,
                      spreadRadius: 4,
                      offset: Offset(0, -4),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title text
                      const Text(
                        "Welcome to RateMyUstaad",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 26,
                          letterSpacing: -0.02,
                          color: Color(0xFF01242D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle text
                      const Text(
                        "Find the Right Ustaad for You.",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          letterSpacing: -0.03,
                          color: Color(0xFF708090),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Join Now button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E17EB),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color.fromRGBO(0, 0, 0, 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to signup screen
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            "Join Now",
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.04,
                            ),
                          ),
                        ),
                      ),
                      
                      // Added login button for existing users
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF5E17EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFF5E17EB)),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to login screen
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
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
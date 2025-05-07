import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratemyustaad/providers/onboarding_provider.dart';
import 'dart:math' as math;

class WelcomeAboardScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  // No skip option for final screen
  const WelcomeAboardScreen({
    Key? key,
    required this.onContinue,
    required this.onBack,
  }) : super(key: key);

  // Constants for consistent styling - matching with other screens
  static const primaryColor = Color(0xFF5E17EB);
  static const darkTextColor = Color(0xFF01242D);
  static const backgroundColor = Color(0xFFF0F8FF);

  // Text styles for reuse
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.3,
    letterSpacing: -0.02,
    color: darkTextColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: darkTextColor, size: 20),
          onPressed: onBack,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Enhanced confetti decoration
            _buildEnhancedConfettiBackground(),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Progress indicator - showing completed
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
                              1.0, // Full width (5/5)
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Heading
                  const Text(
                    "Welcome Aboard!",
                    style: headingStyle,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 1),

                  // Centered illustration card
                  _buildSingleIllustrationCard(
                    'assets/images/onboarding.png',
                    color: Colors.teal.withOpacity(0.2),
                  ),

                  const Spacer(flex: 1),

                  // Continue button
                  Container(
                    height: 56,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 32),
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
                      onPressed: onContinue,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSingleIllustrationCard(String imagePath,
      {required Color color}) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          height: 200,
        ),
      ),
    );
  }

  Widget _buildEnhancedConfettiBackground() {
    // List of festive confetti colors
    final List<Color> confettiColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
    ];

    // Create a random number generator
    final random = math.Random();

    // Generate 30 confetti pieces
    return Stack(
      children: List.generate(30, (index) {
        // Randomize position, color, size and opacity
        final top = random.nextDouble() * 700;
        final left = random.nextDouble() * 400;
        final color = confettiColors[random.nextInt(confettiColors.length)]
            .withOpacity(0.3 + random.nextDouble() * 0.7);
        final size = 4 + random.nextDouble() * 10;

        // Alternate between circles and rectangles for variety
        final isCircle = random.nextBool();

        return Positioned(
          top: top,
          left: left,
          child: isCircle
              ? _confettiDot(color, size)
              : _confettiRect(color, size, size * (1 + random.nextDouble()),
                  random.nextDouble() * math.pi / 2),
        );
      }),
    );
  }

  Widget _confettiDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _confettiRect(
      Color color, double width, double height, double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

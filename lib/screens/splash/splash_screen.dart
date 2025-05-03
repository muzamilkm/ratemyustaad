import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set system UI to match our splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Navigate to the next screen after a delay
    Timer(const Duration(seconds: 3), () {
      // Restore system UI
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E17EB),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF5E17EB), // Using the exact color from your CSS (#5E17EB)
        ),
        child: Stack(
          children: [
            // Centered Logo
            Center(
              child: Image.asset(
                'assets/images/Logo.png',
                width: 311,
                height: 233,
                fit: BoxFit.contain,
              ),
            ),
            
            // Design elements from your CSS
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 40,
                height: 65,
                color: const Color(0xFF5E17EB),
              ),
            ),
            
            Positioned(
              left: 6,
              bottom: 0,
              child: Container(
                width: 30,
                height: 80,
                color: const Color(0xFF5E17EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
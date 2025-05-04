import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';

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
    
    // Initialize authentication and navigation
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    try {
      // Check for saved credentials
      final prefs = await SharedPreferences.getInstance();
      final bool rememberMe = prefs.getBool('rememberMe') ?? false;
      
      if (rememberMe) {
        final String? email = prefs.getString('email');
        final String? password = prefs.getString('password');
        
        if (email != null && password != null) {
          // Try to log in with saved credentials
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.signInWithEmail(email, password);
        }
      }
    } catch (e) {
      print('Error during auto-login: $e');
    } finally {
      // Restore system UI
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
          
      // Navigate to appropriate screen after a delay
      Timer(const Duration(seconds: 3), () {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isAuthenticated) {
          // Navigate to home screen if user is logged in
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Navigate to landing page if user is not logged in
          Navigator.pushReplacementNamed(context, '/landing');
        }
      });
    }
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
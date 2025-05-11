import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/landing_page.dart';
import 'screens/auth/email_login_screen.dart';
import 'screens/auth/email_signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/reviews/review_submit_screen.dart';
import 'screens/search/teacher_search_screen.dart';
import 'screens/search/advanced_search_screen.dart';
import 'screens/search/departments_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/onboarding_flow.dart';
import 'utils/onboarding_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RateMyUstaadApp());
}

class RateMyUstaadApp extends StatelessWidget {
  const RateMyUstaadApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => OnboardingProvider()),  // Add this provider
  ],
  child: MaterialApp(
    title: 'Rate My Ustaad',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5E17EB)),
      useMaterial3: true,
      fontFamily: 'Manrope',
    ),
    home: const SplashScreen(),    routes: {
      '/landing': (context) => const LandingPage(),      
      '/login': (context) => const EmailLoginScreen(),
      '/signup': (context) => const EmailSignupScreen(),
      '/forgot-password': (context) => const ForgotPasswordScreen(),
      '/home': (context) => const HomeScreen(),
      '/search': (context) => const TeacherSearchScreen(),
      '/search/advanced': (context) => const AdvancedSearchScreen(),
      '/search/departments': (context) => const DepartmentsScreen(),
      '/review/new': (context) => const ReviewSubmitScreen(),
      '/profile': (context) => const ProfileScreen(),
      '/onboarding': (context) => OnboardingFlow(
        onComplete: () {
          Navigator.of(context).pushReplacementNamed('/home');
        },
      ),
    },
    debugShowCheckedModeBanner: false,
  ),
);
  }
}

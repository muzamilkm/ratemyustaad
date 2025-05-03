import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/landing_page.dart';
import 'screens/auth/email_login_screen.dart';
import 'screens/auth/email_signup_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'Rate My Ustaad',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5E17EB)),
          useMaterial3: true,
          fontFamily: 'Manrope',
        ),
        home: const SplashScreen(),
        routes: {
          '/landing': (context) => const LandingPage(),
          '/login': (context) => const EmailLoginScreen(),
          '/signup': (context) => const EmailSignupScreen(),
          '/home': (context) => const HomeScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

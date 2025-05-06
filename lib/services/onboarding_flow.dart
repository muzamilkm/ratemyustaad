import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/onboarding/onboarding_get_started_screen.dart';
import '../screens/onboarding/onboarding_academic_background_screen.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingFlow({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleSkip() {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    onboardingProvider.skipOnboarding().then((success) {
      if (success) {
        widget.onComplete();
      }
    });
  }

  void _handleContinue() {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    
    // If this is the last step, save data and complete onboarding
    if (onboardingProvider.currentStep >= 6) {
      onboardingProvider.saveUserData().then((success) {
        if (success) {
          widget.onComplete();
        }
      });
    } else {
      // Move to next step and page
      onboardingProvider.nextStep();
      _pageController.animateToPage(
        onboardingProvider.currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleGetStartedContinue() {
    final onboardingProvider = Provider.of<OnboardingProvider>(context, listen: false);
    
    // Update the data in provider from the first screen
    // This would ideally capture values from the first screen's controllers
    onboardingProvider.updateUserData(
      firstName: "User's First Name", // Replace with actual values from the form
      lastName: "User's Last Name",
      // Add other fields from first screen
    );
    
    _handleContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, _) {
        if (onboardingProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Step 1: Get Started
              OnboardingGetStartedScreen(
                onContinue: _handleGetStartedContinue,
                onSkip: _handleSkip,
              ),
              
              // Step 2: Academic Background
              OnboardingAcademicBackgroundScreen(
                onContinue: _handleContinue,
                onSkip: _handleSkip,
              ),
              
              // Add other onboarding screens here
              // For example:
              // UniversityPreferencesScreen(...),
              // CareerGoalsScreen(...),
              // etc.
              
              // Placeholder for remaining screens
              // You'll replace these with actual screens
              const Scaffold(body: Center(child: Text("University Preferences"))),
              const Scaffold(body: Center(child: Text("Career Goals"))),
              const Scaffold(body: Center(child: Text("Financial Preferences"))),
              const Scaffold(body: Center(child: Text("Living/Lifestyle Preferences"))),
              const Scaffold(body: Center(child: Text("Almost There!"))),
            ],
          ),
        );
      },
    );
  }
}
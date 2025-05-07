import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratemyustaad/providers/onboarding_provider.dart';
import 'package:ratemyustaad/screens/onboarding/get_started_screen.dart';
import 'package:ratemyustaad/screens/onboarding/academic_background_screen.dart';
import 'package:ratemyustaad/screens/onboarding/university_preferences_screen.dart';
import 'package:ratemyustaad/screens/onboarding/career_goals_screen.dart';
import 'package:ratemyustaad/screens/onboarding/welcome_aboard_screen.dart'; // Add this import

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
    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);
    onboardingProvider.skipOnboarding().then((success) {
      if (success) {
        widget.onComplete();
      }
    });
  }

  void _handleContinue() {
    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);

    // If this is the last step, save data and complete onboarding
    if (onboardingProvider.currentStep >= 4) {
      // This is correct for 5 screens (0-4)
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

  void _handleBack() {
    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);

    if (onboardingProvider.currentStep > 0) {
      // Move to previous step
      onboardingProvider.previousStep();
      _pageController.animateToPage(
        onboardingProvider.currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If on first step, exit onboarding flow
      Navigator.of(context).pop();
    }
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
              OnboardingGetStartedScreen(
                onContinue: _handleContinue,
                onSkip: _handleSkip,
                onBack: _handleBack,
              ),
              OnboardingAcademicBackgroundScreen(
                onContinue: _handleContinue,
                onSkip: _handleSkip,
                onBack: _handleBack,
              ),
              OnboardingUniversityPreferencesScreen(
                onContinue: _handleContinue,
                onSkip: _handleSkip,
                onBack: _handleBack,
              ),
              OnboardingCareerGoalsScreen(
                onContinue: _handleContinue,
                onSkip: _handleSkip,
                onBack: _handleBack,
              ),
              WelcomeAboardScreen(
                onContinue: _handleContinue,
                onBack: _handleBack,
              ),
            ],
          ),
        );
      },
    );
  }
}

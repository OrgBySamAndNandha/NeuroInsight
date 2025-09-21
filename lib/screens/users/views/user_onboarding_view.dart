// lib/screens/views/user_onboarding_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:neuroinsight/screens/users/views/user_login_view.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  // --- MODIFICATION: Logic to save the flag and then navigate ---
  void _onIntroEnd(BuildContext context) async {
    // Set the flag to true
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasOnboarded', true);

    // Navigate to the LoginView
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTextStyle = GoogleFonts.lora(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    // ... (rest of the build method is unchanged) ...
    final bodyTextStyle = GoogleFonts.lora(
      fontSize: 16.0,
      color: Colors.black87.withOpacity(0.8),
    );

    const pageDecoration = PageDecoration(
      pageColor: Color(0xFFE1F7F5),
      imagePadding: EdgeInsets.only(top: 60),
      bodyPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      pages: [
        PageViewModel(
          image: Center(
            child: Lottie.asset(
              'assets/animations/splash.json',
              height: 3000,
              width: 3000,
              fit: BoxFit.contain,
            ),
          ),
          titleWidget: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 10),
              Text("Neural Insight", style: pageTextStyle),
              const SizedBox(height: 10),
              Text(
                "AI-powered analysis for early Alzheimer's detection.",
                textAlign: TextAlign.center,
                style: bodyTextStyle,
              ),
              const SizedBox(height: 60),
            ],
          ),
          body: "",
          decoration: pageDecoration,
        ),
        PageViewModel(
          image: Center(
            child: Lottie.asset(
              'assets/animations/Body Scan.json',
              height: 3000,
              width: 3000,
              fit: BoxFit.contain,
            ),
          ),
          titleWidget: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 10),
              Text("Alzheimer's MRI Analysis", style: pageTextStyle),
              const SizedBox(height: 10),
              Text(
                "Upload your brain MRI scans for powerful, AI-driven analysis to detect early signs of Alzheimer's.",
                textAlign: TextAlign.center,
                style: bodyTextStyle,
              ),
              const SizedBox(height: 60),
            ],
          ),
          body: "",
          decoration: pageDecoration,
        ),
        PageViewModel(
          image: Center(
            child: Lottie.asset(
              'assets/animations/admin.json',
              height: 3000,
              width: 3000,
              fit: BoxFit.contain,
            ),
          ),
          titleWidget: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 10),
              Text("Doctor Collaboration", style: pageTextStyle),
              const SizedBox(height: 10),
              Text(
                "Share AI reports and scans directly with your neurologist for expert review, advice, and appointments.",
                textAlign: TextAlign.center,
                style: bodyTextStyle,
              ),
              const SizedBox(height: 60),
            ],
          ),
          body: "",
          decoration: pageDecoration,
        ),
        PageViewModel(
          image: Center(
            child: Lottie.asset(
              'assets/animations/a.json',
              height: 3000,
              width: 3000,
              fit: BoxFit.contain,
            ),
          ),
          titleWidget: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 10),
              Text("AI Insights & Tracking", style: pageTextStyle),
              const SizedBox(height: 10),
              Text(
                "Visualize your neurological health journey with monthly analytics and easy-to-understand charts.",
                textAlign: TextAlign.center,
                style: bodyTextStyle,
              ),
              const SizedBox(height: 60),
            ],
          ),
          body: "",
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
      next: const Icon(Icons.arrow_forward, color: Colors.black87),
      done: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
      controlsMargin: const EdgeInsets.all(16).copyWith(top: 50),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Colors.black87,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neuroinsight/screens/views/home_view.dart';
import 'package:neuroinsight/screens/views/login_view.dart'; // Import LoginView
import 'package:neuroinsight/screens/views/onboarding_view.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

void main() async {
  // --- MODIFICATION: Main function is now async ---
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check if the user has completed onboarding
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool hasOnboarded = prefs.getBool('hasOnboarded') ?? false;

  runApp(MyApp(hasOnboarded: hasOnboarded));
}

class MyApp extends StatelessWidget {
  // --- MODIFICATION: Accept the flag from main() ---
  final bool hasOnboarded;
  const MyApp({super.key, required this.hasOnboarded});

  @override
  Widget build(BuildContext context) {
    const Color primaryBackgroundColor = Color(0xFFE1F7F5);

    return MaterialApp(
      title: 'NeuroInsight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: primaryBackgroundColor,
        textTheme: GoogleFonts.loraTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData) {
            return const HomeView();
          } else {
            // --- MODIFICATION: Show LoginView if already onboarded, otherwise show OnboardingView ---
            return hasOnboarded ? const LoginView() : const OnboardingView();
          }
        },
      ),
    );
  }
}
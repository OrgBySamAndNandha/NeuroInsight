// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neuroinsight/screens/common_auth_check.dart'; // Import the new AuthCheck widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      // Use the AuthCheck widget as the home screen
      home: const AuthCheck(),
    );
  }
}

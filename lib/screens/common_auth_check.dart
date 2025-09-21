// lib/screens/common_auth_check.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neuroinsight/screens/admin/view/doctor_home_view.dart';
import 'package:neuroinsight/screens/users/views/user_nav_bar.dart';
import 'package:neuroinsight/screens/users/views/user_login_view.dart';
import 'package:neuroinsight/screens/users/views/user_onboarding_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  Future<Widget> _getInitialHome() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasOnboarded = prefs.getBool('hasOnboarded') ?? false;

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return hasOnboarded ? const LoginView() : const OnboardingView();
    } else {
      try {
        final doctorDoc = await FirebaseFirestore.instance
            .collection('admin')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (doctorDoc.docs.isNotEmpty) {
          return const DoctorMainView(); // ✅ CHANGED
        } else {
          return const HomeView();
        }
      } catch (e) {
        print("Error checking user role: $e");
        return const HomeView();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return FutureBuilder<Widget>(
          future: _getInitialHome(),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return futureSnapshot.data ?? const LoginView();
          },
        );
      },
    );
  }
}

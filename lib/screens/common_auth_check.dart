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
        // ✅ --- FIXED: Changed 'admin' to 'doctors' to match your database ---
        final doctorDoc = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(user.uid)
            .get();

        if (doctorDoc.exists) {
          return const DoctorMainView();
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
    return FutureBuilder<Widget>(
      future: _getInitialHome(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const LoginView();
      },
    );
  }
}
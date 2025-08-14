// lib/screens/controllers/profile_controllers.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neuroinsight/screens/models/profile_analysis_model.dart';
import 'package:neuroinsight/screens/views/home_view.dart';
import 'auth_controller.dart';

class ProfileController {
  final AuthController _authController = AuthController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Shows a confirmation dialog before logging out.
  Future<void> confirmLogout(BuildContext context) async {
    // This existing method remains unchanged.
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _authController.signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

  // --- ✅ NEW METHODS FOR PROFILE ANALYSIS ---

  /// Checks if a profile analysis document exists for the current user.
  Future<bool> checkProfileExists() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('Profile_Analysis').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      // If there's an error, assume profile doesn't exist to be safe.
      print("Error checking profile: $e");
      return false;
    }
  }

  /// Saves the user's profile analysis data to Firestore.
  Future<void> saveProfileAnalysis(BuildContext context, ProfileAnalysisModel data) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in.");

      await _firestore.collection('Profile_Analysis').doc(user.uid).set(data.toJson());

      // On success, show a confirmation and navigate to the HomeView.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile setup complete!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Home and remove all previous routes.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
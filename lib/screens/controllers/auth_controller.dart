// lib/controllers/auth_controller.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neuroinsight/screens/views/login_view.dart'; // Import LoginView
import '../views/home_view.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ... (signUp, signIn methods are unchanged) ...
  /// ✅ Sign up with email and password
  Future<void> signUpWithEmail(
      BuildContext context,
      String email,
      String password, [
        String? displayName,
      ]) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        final name = displayName ?? email.split('@')[0];
        await user.updateDisplayName(name);
        await user.reload();

        UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email,
          displayName: name,
        );

        await _firestore.collection('users').doc(user.uid).set({
          'uid': userModel.uid,
          'email': userModel.email,
          'displayName': userModel.displayName,
          'photoURL': user.photoURL,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign-up failed')),
      );
    }
  }

  /// ✅ Sign in with email and password
  Future<void> signInWithEmail(
      BuildContext context,
      String email,
      String password,
      ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    }
  }

  /// ✅ Sign in with Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          UserModel userModel = UserModel(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
          );

          await _firestore.collection('users').doc(user.uid).set({
            'uid': userModel.uid,
            'email': userModel.email,
            'displayName': userModel.displayName,
            'photoURL': user.photoURL,
          });
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  // --- MODIFICATION: Navigate to LoginView directly on sign out ---
  /// ✅ Sign out
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    // This removes all screens and pushes the LoginView as the new base screen.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginView()),
          (Route<dynamic> route) => false,
    );
  }
  // --- END OF MODIFICATION ---

  /// ✅ Update User Profile
  Future<void> updateUserProfile(BuildContext context, String displayName, File? imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String? photoURL;
      if (imageFile != null) {
        final ref = _storage.ref().child('profile_pictures').child('${user.uid}.jpg');
        await ref.putFile(imageFile);
        photoURL = await ref.getDownloadURL();
      }

      if (displayName.isNotEmpty && displayName != user.displayName) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null && photoURL != user.photoURL) {
        await user.updatePhotoURL(photoURL);
      }

      final Map<String, dynamic> dataToUpdate = {};
      if (displayName.isNotEmpty) dataToUpdate['displayName'] = displayName;
      if (photoURL != null) dataToUpdate['photoURL'] = photoURL;

      if (dataToUpdate.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(dataToUpdate);
      }

      await user.reload();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
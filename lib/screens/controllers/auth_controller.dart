import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../views/login_view.dart';
import '../views/otp_view.dart';


class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Helper function to show a snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // Sign in with Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // User cancelled the sign-in
      }
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(context, 'Google Sign-In Failed: ${e.message}');
    } catch (e) {
      _showErrorSnackBar(context, 'An unexpected error occurred.');
    }
  }

  // --- THIS IS THE METHOD THAT WAS MISSING ---
  // Sign up with Email & Password
  Future<void> signUpWithEmail(
      BuildContext context, String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(context, 'Sign-Up Failed: ${e.message}');
    } catch (e) {
      _showErrorSnackBar(context, 'An unexpected error occurred.');
    }
  }

  // Sign in with Email & Password
  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(context, 'Sign-In Failed: ${e.message}');
    } catch (e) {
      _showErrorSnackBar(context, 'An unexpected error occurred.');
    }
  }

  // Verify Phone Number
  Future<void> verifyPhoneNumber(BuildContext context, String phoneNumber) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        Navigator.of(context).pop();
      },
      verificationFailed: (FirebaseAuthException e) {
        Navigator.of(context).pop();
        _showErrorSnackBar(context, 'Verification Failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpView(verificationId: verificationId),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Sign in with OTP
  Future<void> signInWithOtp(
      BuildContext context, String verificationId, String smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(context, 'OTP Verification Failed: ${e.message}');
    } catch (e) {
      _showErrorSnackBar(context, 'An unexpected error occurred.');
    }
  }

  // Sign Out
  Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginView()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Sign-Out Failed.');
    }
  }
}
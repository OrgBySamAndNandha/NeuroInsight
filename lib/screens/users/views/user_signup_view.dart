// lib/screens/users/views/user_signup_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:neuroinsight/screens/users/controllers/user_auth_controller.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final AuthController _authController = AuthController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  // --- ✅ NEW: State variables for password visibility ---
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Please fill all fields")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Passwords do not match!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    await _authController.signUpWithEmail(
      context,
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/User Account.json', height: 200),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: GoogleFonts.lora(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start your journey with us',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                // --- ✅ MODIFIED: Password field with visibility toggle ---
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.black87.withOpacity(0.8)),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.black87, size: 22),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(200),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // --- ✅ MODIFIED: Confirm Password field with visibility toggle ---
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(color: Colors.black87.withOpacity(0.8)),
                    prefixIcon: const Icon(Icons.lock_person_outlined, color: Colors.black87, size: 22),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(200),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.black87)
                    : _buildSignUpButton(),
                const SizedBox(height: 30),
                _buildLoginPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black87.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: Colors.black87, size: 22),
        filled: true,
        fillColor: Colors.black.withOpacity(0.20),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(200),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
        ),
        child: const Text(
          'SIGN UP',
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 5),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?",
            style: TextStyle(color: Colors.black87)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Login',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}

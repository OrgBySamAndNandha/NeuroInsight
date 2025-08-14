import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Lottie package for animations
import '../controllers/auth_controller.dart';
import 'signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = AuthController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }
    setState(() => _isLoading = true);
    await _authController.signInWithEmail(
      context,
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);
    await _authController.signInWithGoogle(context);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5), // Main background color
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LOTTIE ANIMATION ---
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset('assets/animations/Login animation.json'),
                  ),
                  const SizedBox(height: 20),

                  // --- MAIN FORM CONTAINER (CARD) ---

                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- RE-ADDED HEADER TEXT ---
                        Text(
                          'Neural Insight',
                          style: GoogleFonts.lora(
                            color: Colors.black87,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- FORM FIELDS AND BUTTONS ---
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 40),
                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : _buildLoginButton(),
                        const SizedBox(height: 20),
                        const Text('OR', style: TextStyle(color: Colors.black87)),
                        const SizedBox(height: 20),
                        _buildGoogleButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSignUpPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

  // --- HELPER WIDGETS STYLED FOR THE BLUE UI ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(200),
          borderSide: BorderSide(color: Colors.black87.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(200),
          borderSide: const BorderSide(color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: const Color(0xFF3D5A80),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
          elevation: 1,
        ),
        child: const Text(
          'LOGIN',
          style: TextStyle(fontSize: 16, color:Colors.white, fontWeight: FontWeight.bold, letterSpacing: 5),
        ),
      ),
    );
  }

  Widget _buildSocialDivider() { // This was in your code but not used in the blue design, keeping it here just in case.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ... (Divider logic if needed)
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loginWithGoogle,
        icon: const FaIcon(FontAwesomeIcons.google, size: 18, color: Colors.black87),
        label: const Text(
          'Sign In with Google',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.black87.withOpacity(0.7)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?", style: TextStyle(color: Colors.black87)),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SignUpView()),
            );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
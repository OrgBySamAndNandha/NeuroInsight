import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// --- IMPORTANT: FIXING IMPORTS BASED ON YOUR FOLDER STRUCTURE ---
// The path in your screenshot is 'lib\screens\views'.
// These imports are adjusted for that structure.
import '../controllers/auth_controller.dart';
import '../widgets/glass_morphism.dart';
import 'signup_view.dart';

// The LoginView class definition starts here
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}
// The LoginView class definition ends here

// The _LoginViewState class definition starts here. ALL the code below belongs inside this class.
class _LoginViewState extends State<LoginView> {
  // --- All variables and controllers are defined INSIDE the state class ---
  final AuthController _authController = AuthController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
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

  void _showPhoneAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.9),
        title: const Text('Enter Phone Number', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '+91 12345 67890',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: const Icon(Icons.phone, color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _authController.verifyPhoneNumber(context, _phoneController.text.trim());
            },
            child: const Text('Send OTP'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- The main build method for the UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: GlassmorphicContainer(
              borderRadius: 20,
              blur: 10,
              child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : _buildLoginButton(),
                  const SizedBox(height: 16),
                  _buildSocialDivider(),
                  const SizedBox(height: 16),
                  _buildGoogleButton(),
                  const SizedBox(height: 12),
                  _buildPhoneButton(),
                      SizedBox(height: 24),
              _buildSignUpPrompt(),
              ],
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }

  // --- All helper methods are also INSIDE the state class ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E3A8A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text('OR', style: TextStyle(color: Colors.white.withOpacity(0.7))),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loginWithGoogle,
        icon: const FaIcon(FontAwesomeIcons.google, size: 18),
        label: const Text('Sign In with Google'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showPhoneAuthDialog,
        icon: const Icon(Icons.phone_android, size: 20),
        label: const Text('Sign In with Phone'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?", style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SignUpView()),
            );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
// The _LoginViewState class definition ends here.
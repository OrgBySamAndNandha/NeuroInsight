// lib/screens/views/edit_profile_view.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neuroinsight/screens/controllers/auth_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final AuthController _authController = AuthController();
  final User? _user = FirebaseAuth.instance.currentUser;
  late final TextEditingController _nameController;

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    await _authController.updateUserProfile(
      context,
      _nameController.text.trim(),
      _imageFile,
    );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      // --- MODIFICATION: Updated AppBar style ---
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        // Changed color to match the background
        backgroundColor: const Color(0xFFE1F7F5),
        foregroundColor: Colors.black,
        // Removed shadow for a seamless look
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Picture Editor
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_user?.photoURL != null ? NetworkImage(_user!.photoURL!) : null) as ImageProvider?,
                  child: _imageFile == null && _user?.photoURL == null
                      ? const Icon(Icons.person, size: 60, color: Colors.black54)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black87,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _pickImage,
              child: const Text('Change Photo', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),

            // Name Text Field
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Display Name'),
            ),
            const SizedBox(height: 24),

            // Email Text Field (disabled)
            TextFormField(
              initialValue: _user?.email ?? 'No email available',
              enabled: false,
              decoration: _inputDecoration('Email'),
            ),
            const SizedBox(height: 40),

            // Save Button
            // Save Button
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text(
                  'SAVE CHANGES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  // --- MODIFICATION: Changed button color to black ---
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
        )
    );
  }
}
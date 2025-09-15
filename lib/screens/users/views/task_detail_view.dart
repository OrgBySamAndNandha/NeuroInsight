import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../models/user_task_model.dart';

class TaskDetailView extends StatefulWidget {
  final TaskModel task;
  const TaskDetailView({super.key, required this.task});

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final String _geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE'; // WARNING: NOT FOR PRODUCTION

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _verifyWithGemini() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload a photo first.")));
      return;
    }
    setState(() => _isLoading = true);

    try {
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_geminiApiKey');

      final payload = jsonEncode({
        "contents": [{
          "parts": [
            {"text": widget.task.verificationPrompt},
            {"inline_data": {"mime_type": "image/jpeg", "data": base64Image}}
          ]
        }]
      });

      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: payload);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultText = data['candidates'][0]['content']['parts'][0]['text'].toString().toLowerCase();

        // Simple check if Gemini's response contains "yes"
        if (resultText.contains('yes')) {
          // In a real app, update the task status in Firestore here
          // FirebaseFirestore.instance.collection('users').doc(uid).collection('daily_tasks').doc(widget.task.id).update({'status': 'completed'});
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Task Verified! Great job!"), backgroundColor: Colors.green));
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification failed. Please try a clearer photo."), backgroundColor: Colors.red));
        }
      } else {
        throw Exception('Failed to verify with server.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      appBar: AppBar(
        title: Text(widget.task.title, style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.task.icon, size: 60, color: Colors.black54),
            const SizedBox(height: 24),
            Text(
              widget.task.title,
              style: GoogleFonts.lora(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              widget.task.description,
              style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
            ),
            const Spacer(),
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Upload Photo Proof"),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _imageFile == null || _isLoading ? null : _verifyWithGemini,
                icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.check_circle),
                label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Verify & Complete Task"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
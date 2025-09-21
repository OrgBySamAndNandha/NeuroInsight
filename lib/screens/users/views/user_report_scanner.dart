import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

// --- ✅ NEW: Import for the chat screen ---
import 'user_chat_neuro_insight.dart';

class ReportScannerView extends StatefulWidget {
  const ReportScannerView({super.key});

  @override
  State<ReportScannerView> createState() => _ReportScannerViewState();
}

class _ReportScannerViewState extends State<ReportScannerView> {
  File? _imageFile;
  bool _isLoading = false;
  String? _lastSavedReportId;
  final ImagePicker _picker = ImagePicker();

  final String _geminiApiKey = 'AIzaSyCcYtHpJ_R4t64USIX862ZZWG8edzUgNlk';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _lastSavedReportId = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<String?> _showReportTypeBottomSheet() async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.computer),
                title: const Text('AI Report'),
                onTap: () => Navigator.of(context).pop('AI'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Doctor's Report"),
                onTap: () => Navigator.of(context).pop("Doctor's"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _analyzeAndSaveReport() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image first.')));
      return;
    }

    final reportType = await _showReportTypeBottomSheet();
    if (reportType == null) return;

    setState(() => _isLoading = true);

    try {
      final analysisText = await _getGeminiAnalysis();
      await _saveReportToFirestore(reportType, analysisText);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report saved to your profile!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _getGeminiAnalysis() async {
    if (_geminiApiKey.isEmpty) {
      throw Exception('Gemini API Key not set.');
    }
    final bytes = await _imageFile!.readAsBytes();
    final base64Image = base64Encode(bytes);
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_geminiApiKey');
    const newPrompt = "You are an AI assistant specialized in analyzing medical images...";
    final payload = jsonEncode({"contents": [{"parts": [{"text": newPrompt}, {"inline_data": {"mime_type": "image/jpeg", "data": base64Image}}]}]});
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: payload);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to get analysis from server.');
    }
  }

  Future<void> _saveReportToFirestore(String reportType, String analysisText) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in.");

    final reportId = const Uuid().v4();
    await _firestore.collection('scan_reports').doc(reportId).set({
      'id': reportId,
      'patientId': user.uid,
      'analysisResultText': analysisText,
      'reportType': reportType,
      'createdAt': Timestamp.now(),
      'isAttachedToAppointment': false,
    });
    setState(() {
      _lastSavedReportId = reportId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      appBar: AppBar(
        title: Text('Analyze Scan & Save Report', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      // --- ✅ MODIFIED: Added FloatingActionButton ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatWithNeuroInsightView()),
          );
        },
        backgroundColor: const Color(0xFF2DB8A1),
        tooltip: 'Chat with AI',
        child: const Icon(Icons.wechat_sharp, color: Colors.white),
      ),
      // --- End of modification ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                child: _imageFile != null ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_search, size: 60, color: Colors.grey), SizedBox(height: 8), Text('Tap to select an image')]),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Gallery'))),
                const SizedBox(width: 16),
                Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Camera'))),
              ],
            ),
            const SizedBox(height: 24),
            if (_imageFile != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _analyzeAndSaveReport,
                  icon: const Icon(Icons.save_alt_outlined, color: Colors.white),
                  label: const Text('ANALYZE & SAVE REPORT'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18)),
                ),
              ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_lastSavedReportId != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 40),
                      SizedBox(height: 10),
                      Text('Report Saved Successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('You can now view this in your profile or attach it to an appointment.', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
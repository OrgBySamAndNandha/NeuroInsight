import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ReportScannerView extends StatefulWidget {
  const ReportScannerView({super.key});

  @override
  State<ReportScannerView> createState() => _ReportScannerViewState();
}

class _ReportScannerViewState extends State<ReportScannerView> {
  // --- State Variables ---
  File? _imageFile;
  bool _isLoading = false;
  String _analysisResult = '';
  final ImagePicker _picker = ImagePicker();

  // --- IMPORTANT: Replace with your Google Gemini API Key ---
  final String _geminiApiKey = '';

  /// Picks an image from the gallery or takes a photo with the camera.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _analysisResult = ''; // Clear previous results
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  /// Encodes the image and sends it to the Google Gemini Vision API.
  Future<void> _analyzeReport() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY' || _geminiApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text('Gemini API Key not set. Please update the code.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = '';
    });

    try {
      // 1. Encode image to Base64
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Prepare the Gemini API endpoint and the NEW, more flexible prompt
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_geminiApiKey');

      // --- MODIFICATION START: The prompt now accepts medical diagrams and illustrations ---
      const newPrompt = """
      You are an AI assistant specialized in analyzing medical images for signs of neurological conditions.

      First, determine if the uploaded image is related to human medicine or biology, such as a brain MRI scan, a medical report, or an anatomical diagram. If the image is clearly unrelated (e.g., a car, a landscape, a non-medical object), you must respond with only one sentence: 'Please upload a relevant medical image or report to get an analysis.'

      If the image IS medically relevant, analyze it for key indicators of Alzheimer's disease or other neurological conditions. Present your findings as short, crisp bullet points, highlighting only the most critical information. Specifically mention any visible changes in the ventricles, hippocampus, or cortex if they are depicted. If signs of a condition other than Alzheimer's are present, state what they are.

      IMPORTANT: Do not provide a diagnosis or medical advice. Your role is to summarize the information presented in the image or report only.
      """;
      // --- MODIFICATION END ---


      final payload = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": newPrompt}, // Using the new flexible prompt here
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      });

      // 3. Make the HTTP POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      // 4. Parse the Gemini API response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          setState(() {
            _analysisResult = data['candidates'][0]['content']['parts'][0]['text'];
          });
        } else {
          setState(() {
            _analysisResult = 'Analysis could not be completed. The content may have been blocked due to safety settings.';
          });
        }
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          _analysisResult = 'Error: ${response.statusCode}\n${error['error']['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = 'An unexpected error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      appBar: AppBar(
        title: Text('Analyze Medical Report', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image display area
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_search, size: 60, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tap to select an image', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons for image selection
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Analyze button
            if (_imageFile != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _analyzeReport,
                  icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                  label: const Text('ANALYZE REPORT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Result display area
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.black87))
            else if (_analysisResult.isNotEmpty)
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analysis Result:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20),
                      SelectableText(
                        _analysisResult,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
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
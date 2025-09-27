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
// --- ✅ NEW: Import for CNN service ---
import '../../../services/cnn_service.dart';

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

  final String _openaiApiKey =
      'YOUR_OPENAI_API_KEY_HERE'; // Replace with your actual API key

  // Analysis type selection
  String _selectedAnalysisType = 'chatgpt'; // 'chatgpt' or 'cnn'
  bool _cnnServiceAvailable = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkCNNServiceAvailability();
  }

  Future<void> _checkCNNServiceAvailability() async {
    final isAvailable = await CNNService.checkHealth();
    setState(() {
      _cnnServiceAvailable = isAvailable;
    });
  }

  Future<void> _showModelInfo() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2DB8A1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.memory, color: Color(0xFF2DB8A1)),
            ),
            const SizedBox(width: 12),
            const Text('Vbai-DPA 2.1 Model'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Advanced CNN Model for Brain Disease Prediction',
                style: GoogleFonts.lora(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                '🎯',
                'Purpose',
                'Diagnose Alzheimer\'s, Parkinson\'s & Dementia',
              ),
              _buildInfoRow('🧠', 'Input', 'MRI/fMRI Brain Scan Images'),
              _buildInfoRow('📊', 'Classes', '6 Disease Categories'),
              _buildInfoRow('⚡', 'Speed', 'Real-time Analysis'),
              _buildInfoRow(
                '🏥',
                'Target Users',
                'Hospitals & Medical Centers',
              ),
              const SizedBox(height: 16),
              const Text(
                'Classes Detected:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._buildClassesList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  List<Widget> _buildClassesList() {
    final classes = [
      '🔴 Alzheimer Disease',
      '🟡 Moderate Alzheimer Risk',
      '🟠 Mild Alzheimer Risk',
      '🟢 Very Mild Alzheimer Risk',
      '✅ No Risk',
      '🟣 Parkinson Disease',
    ];

    return classes
        .map(
          (className) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('• $className', style: const TextStyle(fontSize: 13)),
          ),
        )
        .toList();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _lastSavedReportId = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    final reportType = await _showReportTypeBottomSheet();
    if (reportType == null) return;

    setState(() => _isLoading = true);

    try {
      String analysisText;

      if (_selectedAnalysisType == 'cnn' && _cnnServiceAvailable) {
        // Use CNN analysis
        print('🧠 Starting CNN analysis...');
        final cnnResult = await CNNService.predictFromImage(_imageFile!);
        if (cnnResult != null) {
          print('✅ CNN analysis successful!');
          analysisText = CNNService.formatPredictionResult(cnnResult);
        } else {
          print('❌ CNN analysis failed, falling back to ChatGPT');
          analysisText = await _getChatGPTAnalysis();
        }
      } else {
        // Use ChatGPT analysis (default)
        analysisText = await _getChatGPTAnalysis();
      }

      await _saveReportToFirestore(reportType, analysisText);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report saved to your profile!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _getChatGPTAnalysis() async {
    if (_openaiApiKey.isEmpty) {
      throw Exception('OpenAI API Key not set.');
    }
    final bytes = await _imageFile!.readAsBytes();
    final base64Image = base64Encode(bytes);
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    const newPrompt =
        "You are an AI assistant specialized in analyzing medical images. Analyze this brain scan image and provide a detailed medical assessment including any visible abnormalities, potential conditions, and recommendations for further evaluation. Be thorough but acknowledge the limitations of image-based analysis.";
    final payload = jsonEncode({
      "model": "gpt-4o",
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": newPrompt},
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
            },
          ],
        },
      ],
      "max_tokens": 1000,
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openaiApiKey',
      },
      body: payload,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print('❌ ChatGPT API Error: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      throw Exception(
        'Failed to get analysis from server. Status: ${response.statusCode}',
      );
    }
  }

  Future<void> _saveReportToFirestore(
    String reportType,
    String analysisText,
  ) async {
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
        title: Text(
          'Analyze Scan & Save Report',
          style: GoogleFonts.lora(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      // --- ✅ MODIFIED: Added FloatingActionButton ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatWithNeuroInsightView(),
            ),
          );
        },
        backgroundColor: const Color(0xFF2DB8A1),
        tooltip: 'Chat with AI',
        child: const Icon(Icons.chat, color: Colors.white),
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
                          Icon(
                            Icons.image_search,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('Tap to select an image'),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_imageFile != null) ...[
              // Analysis Type Selection
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.psychology_outlined,
                            color: Color(0xFF2DB8A1),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Analysis Method',
                            style: GoogleFonts.lora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('ChatGPT AI'),
                              subtitle: const Text('General analysis'),
                              value: 'chatgpt',
                              groupValue: _selectedAnalysisType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAnalysisType = value!;
                                });
                              },
                              activeColor: const Color(0xFF2DB8A1),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Row(
                                children: [
                                  const Text('CNN Model'),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2DB8A1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Vbai-DPA 2.1',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: _showModelInfo,
                                    child: const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Color(0xFF2DB8A1),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                _cnnServiceAvailable
                                    ? 'Specialized for brain diseases'
                                    : 'Service unavailable',
                                style: TextStyle(
                                  color: _cnnServiceAvailable
                                      ? null
                                      : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              value: 'cnn',
                              groupValue: _selectedAnalysisType,
                              onChanged: _cnnServiceAvailable
                                  ? (value) {
                                      setState(() {
                                        _selectedAnalysisType = value!;
                                      });
                                    }
                                  : null,
                              activeColor: const Color(0xFF2DB8A1),
                            ),
                          ),
                        ],
                      ),
                      if (!_cnnServiceAvailable) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'CNN service is offline. Using ChatGPT AI only.',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _analyzeAndSaveReport,
                  icon: Icon(
                    _selectedAnalysisType == 'cnn'
                        ? Icons.memory
                        : Icons.auto_awesome,
                    color: Colors.white,
                  ),
                  label: Text(
                    _selectedAnalysisType == 'cnn'
                        ? 'ANALYZE WITH CNN MODEL'
                        : 'ANALYZE WITH CHATGPT AI',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ],
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
                      Text(
                        'Report Saved Successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You can now view this in your profile or attach it to an appointment.',
                        textAlign: TextAlign.center,
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

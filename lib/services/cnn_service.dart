import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CNNPredictionResult {
  final String predictedClass;
  final int predictedClassIndex;
  final double confidence;
  final double confidencePercentage;
  final double inferenceTimeMs;
  final Map<String, double> allClassProbabilities;
  final String modelVersion;
  final String analysisType;

  CNNPredictionResult({
    required this.predictedClass,
    required this.predictedClassIndex,
    required this.confidence,
    required this.confidencePercentage,
    required this.inferenceTimeMs,
    required this.allClassProbabilities,
    required this.modelVersion,
    required this.analysisType,
  });

  factory CNNPredictionResult.fromJson(Map<String, dynamic> json) {
    return CNNPredictionResult(
      predictedClass: json['predicted_class'] ?? '',
      predictedClassIndex: json['predicted_class_index'] ?? 0,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      confidencePercentage: (json['confidence_percentage'] ?? 0.0).toDouble(),
      inferenceTimeMs: (json['inference_time_ms'] ?? 0.0).toDouble(),
      allClassProbabilities: Map<String, double>.from(
        (json['all_class_probabilities'] ?? {}).map(
          (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
      modelVersion: json['model_version'] ?? 'Unknown',
      analysisType: json['analysis_type'] ?? 'CNN_Prediction',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predicted_class': predictedClass,
      'predicted_class_index': predictedClassIndex,
      'confidence': confidence,
      'confidence_percentage': confidencePercentage,
      'inference_time_ms': inferenceTimeMs,
      'all_class_probabilities': allClassProbabilities,
      'model_version': modelVersion,
      'analysis_type': analysisType,
    };
  }
}

class ModelInfo {
  final String modelType;
  final double parametersMillion;
  final double flopsGillion;
  final double inferenceTimeMs;
  final String inputSize;
  final int numClasses;
  final String device;

  ModelInfo({
    required this.modelType,
    required this.parametersMillion,
    required this.flopsGillion,
    required this.inferenceTimeMs,
    required this.inputSize,
    required this.numClasses,
    required this.device,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      modelType: json['model_type'] ?? '',
      parametersMillion: (json['parameters_million'] ?? 0.0).toDouble(),
      flopsGillion: (json['flops_billion'] ?? 0.0).toDouble(),
      inferenceTimeMs: (json['inference_time_ms'] ?? 0.0).toDouble(),
      inputSize: json['input_size'] ?? '',
      numClasses: json['num_classes'] ?? 0,
      device: json['device'] ?? '',
    );
  }
}

class CNNService {
  // Service will try multiple ports automatically
  // For Android emulator, use 10.0.2.2 to access host machine
  static const List<String> possibleUrls = [
    'http://10.0.2.2:5002', // Android emulator host access - WORKING PORT
    'http://10.0.2.2:5555',
    'http://10.0.2.2:5000',
    'http://10.0.2.2:5001',
    'http://10.0.2.2:5003',
    'http://localhost:5002', // Fallback for real devices/iOS - WORKING PORT
    'http://localhost:5555',
    'http://localhost:5000',
    'http://localhost:5001',
    'http://localhost:5003',
  ];
  static String? _workingUrl;
  static const Duration timeoutDuration = Duration(seconds: 30);

  static Future<String?> _findWorkingUrl() async {
    if (_workingUrl != null) {
      // Verify the cached URL still works
      try {
        final response = await http
            .get(
              Uri.parse('$_workingUrl/health'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          return _workingUrl;
        } else {
          _workingUrl = null; // Reset cached URL
        }
      } catch (e) {
        _workingUrl = null; // Reset cached URL
      }
    }

    // Try to find a working URL
    for (String url in possibleUrls) {
      try {
        print('🔍 Trying CNN service at: $url');
        final response = await http
            .get(
              Uri.parse('$url/health'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          print('✅ CNN service found at: $url');
          _workingUrl = url;
          return url;
        } else {
          print(
            '❌ CNN service at $url returned status: ${response.statusCode}',
          );
        }
      } catch (e) {
        print('❌ CNN service at $url failed: $e');
      }
    }

    print('🚫 No working CNN service found on any port');
    return null;
  }

  static Future<bool> checkHealth() async {
    final url = await _findWorkingUrl();
    return url != null;
  }

  static Future<ModelInfo?> getModelInfo() async {
    final baseUrl = await _findWorkingUrl();
    if (baseUrl == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/model-info'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ModelInfo.fromJson(data);
      }
    } catch (e) {
      print('Error getting model info: $e');
    }
    return null;
  }

  static Future<CNNPredictionResult?> predictFromImage(File imageFile) async {
    final baseUrl = await _findWorkingUrl();
    if (baseUrl == null) {
      print('🚫 CNN service is not available');
      return null;
    }

    try {
      print('📤 Sending image to CNN service: $baseUrl');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send().timeout(timeoutDuration);

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        print('✅ CNN prediction received successfully');
        return CNNPredictionResult.fromJson(data);
      } else {
        print('❌ CNN prediction failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error during CNN prediction: $e');
    }
    return null;
  }

  static Future<CNNPredictionResult?> predictFromImageFile(
    String imagePath,
  ) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      print('❌ Image file does not exist: $imagePath');
      return null;
    }
    return await predictFromImage(file);
  }

  /// Formats the CNN prediction result into a professional medical report
  static String formatPredictionResult(CNNPredictionResult result) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('🧠 CNN ANALYSIS RESULTS');
    buffer.writeln('=' * 50);
    buffer.writeln();

    // Main prediction
    buffer.writeln('📊 PRIMARY DIAGNOSIS');
    buffer.writeln('Disease: ${result.predictedClass}');
    buffer.writeln(
      'Confidence: ${result.confidencePercentage.toStringAsFixed(1)}%',
    );

    // Risk level based on confidence
    String riskLevel;
    String riskColor;
    if (result.confidencePercentage >= 90) {
      riskLevel = 'HIGH';
      riskColor = '🔴';
    } else if (result.confidencePercentage >= 70) {
      riskLevel = 'MODERATE';
      riskColor = '🟡';
    } else {
      riskLevel = 'LOW';
      riskColor = '🟢';
    }

    buffer.writeln('Risk Level: $riskColor $riskLevel');
    buffer.writeln();

    // Technical details
    buffer.writeln('⚙️ TECHNICAL DETAILS');
    buffer.writeln('Model: ${result.modelVersion}');
    buffer.writeln('Analysis Type: ${result.analysisType}');
    buffer.writeln(
      'Processing Time: ${result.inferenceTimeMs.toStringAsFixed(2)}ms',
    );
    buffer.writeln();

    // All probabilities
    buffer.writeln('📈 ALL CONDITION PROBABILITIES');
    final sortedProbs = result.allClassProbabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedProbs) {
      final percentage = (entry.value * 100).toStringAsFixed(1);
      buffer.writeln('${entry.key}: ${percentage}%');
    }
    buffer.writeln();

    // Medical recommendations
    buffer.writeln('🏥 RECOMMENDATIONS');
    if (result.predictedClass.toLowerCase().contains('alzheimer')) {
      buffer.writeln('• Consult a neurologist immediately');
      buffer.writeln('• Consider cognitive assessment');
      buffer.writeln('• Discuss treatment options');
    } else if (result.predictedClass.toLowerCase().contains('parkinson')) {
      buffer.writeln('• Consult a movement disorder specialist');
      buffer.writeln('• Consider DaTscan confirmation');
      buffer.writeln('• Evaluate motor symptoms');
    } else if (result.predictedClass.toLowerCase().contains('tumor')) {
      buffer.writeln('• Urgent neurosurgical consultation');
      buffer.writeln('• Consider additional imaging');
      buffer.writeln('• Discuss treatment options');
    } else if (result.predictedClass.toLowerCase().contains('normal')) {
      buffer.writeln('• Results appear normal');
      buffer.writeln('• Continue regular monitoring');
      buffer.writeln('• Maintain healthy lifestyle');
    } else {
      buffer.writeln('• Consult healthcare provider');
      buffer.writeln('• Consider additional testing');
      buffer.writeln('• Monitor symptoms');
    }
    buffer.writeln();

    // Disclaimer
    buffer.writeln('⚠️ IMPORTANT DISCLAIMER');
    buffer.writeln('This analysis is for research purposes only.');
    buffer.writeln('Always consult qualified healthcare professionals');
    buffer.writeln('for medical diagnosis and treatment decisions.');

    return buffer.toString();
  }
}

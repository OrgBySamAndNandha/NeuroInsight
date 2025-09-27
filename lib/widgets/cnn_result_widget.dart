import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cnn_service.dart';

class CNNResultWidget extends StatelessWidget {
  final CNNPredictionResult result;
  final VoidCallback? onDetailsPressed;

  const CNNResultWidget({
    super.key,
    required this.result,
    this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFF2DB8A1).withOpacity(0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildMainResult(),
              const SizedBox(height: 16),
              _buildConfidenceBar(),
              const SizedBox(height: 16),
              _buildTechnicalInfo(),
              if (onDetailsPressed != null) ...[
                const SizedBox(height: 16),
                _buildDetailsButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2DB8A1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.memory, color: Color(0xFF2DB8A1), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Neural Network Analysis',
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                result.modelVersion,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        _buildRiskBadge(),
      ],
    );
  }

  Widget _buildRiskBadge() {
    final riskColor = _getRiskColor(result.predictedClass);
    final riskIcon = _getRiskIcon(result.predictedClass);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(riskIcon, size: 14, color: riskColor),
          const SizedBox(width: 4),
          Text(
            _getRiskLevel(result.predictedClass),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: riskColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Diagnosis',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.predictedClass,
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getClassDescription(result.predictedClass),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${result.confidencePercentage.toStringAsFixed(1)}%',
              style: GoogleFonts.lora(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2DB8A1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: result.confidence,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getConfidenceColor(result.confidence),
          ),
          minHeight: 6,
        ),
        const SizedBox(height: 4),
        Text(
          _getConfidenceText(result.confidence),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTechnicalInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.speed, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            'Processing Time: ${result.inferenceTimeMs.toStringAsFixed(1)}ms',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(Icons.memory, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            'CNN Model',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onDetailsPressed,
        icon: const Icon(Icons.analytics_outlined),
        label: const Text('View Detailed Analysis'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2DB8A1),
          side: const BorderSide(color: Color(0xFF2DB8A1)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Color _getRiskColor(String className) {
    switch (className) {
      case 'Alzheimer Disease':
      case 'Parkinson Disease':
        return Colors.red;
      case 'Moderate Alzheimer Risk':
        return Colors.orange;
      case 'Mild Alzheimer Risk':
        return Colors.amber;
      case 'Very Mild Alzheimer Risk':
        return Colors.yellow[700]!;
      case 'No Risk':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String className) {
    switch (className) {
      case 'Alzheimer Disease':
      case 'Parkinson Disease':
        return Icons.warning;
      case 'Moderate Alzheimer Risk':
        return Icons.warning_amber;
      case 'Mild Alzheimer Risk':
      case 'Very Mild Alzheimer Risk':
        return Icons.info;
      case 'No Risk':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _getRiskLevel(String className) {
    switch (className) {
      case 'Alzheimer Disease':
      case 'Parkinson Disease':
        return 'HIGH';
      case 'Moderate Alzheimer Risk':
        return 'MODERATE';
      case 'Mild Alzheimer Risk':
        return 'MILD';
      case 'Very Mild Alzheimer Risk':
        return 'VERY MILD';
      case 'No Risk':
        return 'NO RISK';
      default:
        return 'UNKNOWN';
    }
  }

  String _getClassDescription(String className) {
    switch (className) {
      case 'Alzheimer Disease':
        return 'High probability of Alzheimer\'s disease detected. Immediate medical consultation recommended.';
      case 'Parkinson Disease':
        return 'Indicators of Parkinson\'s disease found. Consultation with movement disorder specialist advised.';
      case 'Moderate Alzheimer Risk':
        return 'Moderate risk factors detected. Regular monitoring and consultation recommended.';
      case 'Mild Alzheimer Risk':
        return 'Mild risk indicators present. Preventive measures and routine check-ups advised.';
      case 'Very Mild Alzheimer Risk':
        return 'Very mild risk factors detected. Lifestyle modifications may be beneficial.';
      case 'No Risk':
        return 'No significant risk indicators detected. Continue maintaining good brain health.';
      default:
        return 'Analysis completed with neural network assessment.';
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceText(double confidence) {
    if (confidence >= 0.8) return 'High confidence prediction';
    if (confidence >= 0.6) return 'Moderate confidence prediction';
    return 'Lower confidence - consider additional analysis';
  }
}

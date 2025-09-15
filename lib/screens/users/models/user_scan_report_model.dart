import 'package:cloud_firestore/cloud_firestore.dart';

class ScanReportModel {
  final String id;
  final String patientId;
  final String analysisResultText;
  final String reportType;
  final Timestamp createdAt;
  final bool isAttachedToAppointment;

  ScanReportModel({
    required this.id,
    required this.patientId,
    required this.analysisResultText,
    required this.reportType,
    required this.createdAt,
    required this.isAttachedToAppointment,
  });

  factory ScanReportModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ScanReportModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      analysisResultText: data['analysisResultText'] ?? 'No analysis available.',
      reportType: data['reportType'] ?? 'Unknown',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isAttachedToAppointment: data['isAttachedToAppointment'] ?? false,
    );
  }
}
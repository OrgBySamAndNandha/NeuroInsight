import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String problemDescription;
  final String symptomDuration;
  final String? problemPhotoURL;
  final String status;
  final String currentDoctorId;
  final String? confirmedDoctorId;
  final List<String> rejectionChain;
  final Timestamp createdAt;
  final String symptomSeverity;
  final String visitPreference;
  final GeoPoint? patientLocation;
  final Timestamp? appointmentDate;
  final String? rejectionReason;
  final String? scanReportUrl;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.problemDescription,
    required this.symptomDuration,
    this.problemPhotoURL,
    required this.status,
    required this.currentDoctorId,
    this.confirmedDoctorId,
    required this.rejectionChain,
    required this.createdAt,
    required this.symptomSeverity,
    required this.visitPreference,
    this.patientLocation,
    this.appointmentDate,
    this.rejectionReason,
    this.scanReportUrl,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      problemDescription: data['problemDescription'] ?? '',
      symptomDuration: data['symptomDuration'] ?? '',
      problemPhotoURL: data['problemPhotoURL'],
      status: data['status'] ?? 'pending',
      currentDoctorId: data['currentDoctorId'] ?? '',
      confirmedDoctorId: data['confirmedDoctorId'],
      rejectionChain: List<String>.from(data['rejectionChain'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      symptomSeverity: data['symptomSeverity'] ?? 'Low',
      visitPreference: data['visitPreference'] ?? 'Clinic Visit',
      patientLocation: data['patientLocation'],
      appointmentDate: data['appointmentDate'],
      rejectionReason: data['rejectionReason'],
      scanReportUrl: data['scanReportUrl'],
    );
  }
}
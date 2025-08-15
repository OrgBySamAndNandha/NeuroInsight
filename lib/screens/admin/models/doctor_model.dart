// lib/screens/admin/models/doctor_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String uid;
  final String doctorName;
  final String email;
  final String specialty;
  final String hospitalName;
  final String address;
  final String? photoURL;
  final GeoPoint location;

  DoctorModel({
    required this.uid,
    required this.doctorName,
    required this.email,
    required this.specialty,
    required this.hospitalName,
    required this.address,
    this.photoURL,
    required this.location,
  });

  // A factory constructor to create a DoctorModel from a Firestore document
  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      uid: doc.id,
      doctorName: data['doctorName'] ?? 'N/A',
      email: data['email'] ?? 'N/A',
      specialty: data['specialty'] ?? 'N/A',
      hospitalName: data['hospitalName'] ?? 'N/A',
      address: data['address'] ?? 'N/A',
      photoURL: data['photoURL'],
      location: data['location'] ?? const GeoPoint(0, 0),
    );
  }
}

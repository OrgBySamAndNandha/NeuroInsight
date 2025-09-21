import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';
import 'package:neuroinsight/screens/admin/view/doctor_home_view.dart';
import 'package:neuroinsight/screens/users/views/user_login_view.dart';

class AdminAuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- UNCHANGED: createDoctorAccountAndProfile, signInDoctor, signOut, getDoctorProfile ---
  Future<void> createDoctorAccountAndProfile(BuildContext context) async {
    final List<Map<String, dynamic>> doctorsToCreate = [
      {'name': 'Dr. Sam', 'email': 'doctorsam@gmail.com', 'experience': 12, 'location': const GeoPoint(11.0168, 76.9558), 'address': '123 Medical Plaza, Coimbatore'},
      {'name': 'Dr. Nandha', 'email': 'doctornandha@gmail.com', 'experience': 8, 'location': const GeoPoint(11.1085, 77.3411), 'address': '456 Health Hub, Tirupur'},
      {'name': 'Dr. Thanu', 'email': 'doctorthanu@gmail.com', 'experience': 15, 'location': const GeoPoint(11.3410, 77.7172), 'address': '789 Wellness Center, Erode'},
      {'name': 'Dr. Vel', 'email': 'doctorvel@gmail.com', 'experience': 10, 'location': const GeoPoint(11.6643, 78.1460), 'address': '101 Cure Avenue, Salem'},
      {'name': 'Dr. Abi', 'email': 'doctorabi@gmail.com', 'experience': 7, 'location': const GeoPoint(10.9596, 78.0880), 'address': '212 Care Point, Karur'},
    ];

    const String password = '123456';
    int successCount = 0;

    for (var doctorData in doctorsToCreate) {
      try {
        final email = doctorData['email']!;
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        User? user = userCredential.user;
        if (user == null) continue;

        await user.updateDisplayName(doctorData['name']!);
        await _firestore.collection('admin').doc(user.uid).set({
          'uid': user.uid,
          'doctorName': doctorData['name'],
          'email': email,
          'specialty': 'Neurologist',
          'hospitalName': 'NeuroInsight Partner Clinic',
          'address': doctorData['address'],
          'photoURL': null,
          'location': doctorData['location'],
          'experience': doctorData['experience'],
        });
        successCount++;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          successCount++;
        }
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$successCount out of 5 doctor accounts are set up!'),
          backgroundColor: Colors.green));
    }
  }

  Future<void> signInDoctor(BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      if (context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DoctorMainView()));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginView()), (route) => false);
    }
  }

  Future<DoctorModel?> getDoctorProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;
      final docSnapshot = await _firestore.collection('admin').doc(user.uid).get();
      if (docSnapshot.exists) {
        return DoctorModel.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      print("Error fetching doctor profile: $e");
      return null;
    }
  }
  // --- ✅ MODIFIED: Renamed from confirmAppointmentDate to acceptAppointment ---
  /// Accepts an appointment by setting the date and time.
  Future<void> acceptAppointment(BuildContext context, String appointmentId, DateTime appointmentDate) async {
    final User? doctor = _auth.currentUser;
    if (doctor == null) return;

    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'confirmed',
        'confirmedDoctorId': doctor.uid,
        'appointmentDate': Timestamp.fromDate(appointmentDate),
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment accepted and scheduled!"), backgroundColor: Colors.green)
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to accept: $e"))
      );
    }
  }

  // --- ✅ MODIFIED: Replaced rejectAndRerouteAppointment with this new logic ---
  /// Rejects an appointment with a mandatory reason.
  Future<void> rejectAppointment(BuildContext context, String appointmentId, String reason) async {
    final User? currentDoctorUser = _auth.currentUser;
    if (currentDoctorUser == null) return;

    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'rejected',
        'rejectionReason': reason,
        // Add current doctor to rejection chain for historical purposes
        'rejectionChain': FieldValue.arrayUnion([currentDoctorUser.uid]),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request has been rejected."), backgroundColor: Colors.orange));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Operation failed: $e")));
    }
  }
}

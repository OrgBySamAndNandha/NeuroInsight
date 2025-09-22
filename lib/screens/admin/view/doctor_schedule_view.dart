import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:neuroinsight/screens/admin/controllers/doctors_auth_controller.dart';
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';
import 'package:neuroinsight/screens/admin/models/doctor_appointment_model.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ --- ADDED: For launching maps ---

class DoctorScheduleView extends StatefulWidget {
  const DoctorScheduleView({super.key});

  @override
  State<DoctorScheduleView> createState() => _DoctorScheduleViewState();
}

class _DoctorScheduleViewState extends State<DoctorScheduleView> {
  Stream<List<AppointmentModel>>? _appointmentsStream;
  // ✅ --- ADDED: To store the current doctor's profile data ---
  Future<DoctorModel?>? _doctorProfileFuture;
  final AdminAuthController _authController = AdminAuthController();


  @override
  void initState() {
    super.initState();
    final User? doctor = FirebaseAuth.instance.currentUser;
    if (doctor != null) {
      // ✅ --- ADDED: Fetch the doctor's profile to get their location ---
      _doctorProfileFuture = _authController.getDoctorProfile();

      // Query for appointments pending for this doctor
      Stream<QuerySnapshot> pendingStream = FirebaseFirestore.instance
          .collection('appointments')
          .where('currentDoctorId', isEqualTo: doctor.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots();

      // Query for appointments confirmed by this doctor
      Stream<QuerySnapshot> confirmedStream = FirebaseFirestore.instance
          .collection('appointments')
          .where('confirmedDoctorId', isEqualTo: doctor.uid)
          .snapshots();

      // Combine the two streams into one
      _appointmentsStream = StreamZip([pendingStream, confirmedStream]).map((results) {
        final pendingDocs = results[0].docs;
        final confirmedDocs = results[1].docs;

        final allDocs = [...pendingDocs, ...confirmedDocs];
        final uniqueDocs = { for (var doc in allDocs) doc.id : doc }.values.toList();

        final appointments = uniqueDocs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
        appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return appointments;
      });
    }
  }

  // ✅ --- NEW: Function to launch Google Maps with directions ---
  Future<void> _launchMapsUrl(LatLng origin, LatLng destination) async {
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&travelmode=driving';
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps application.')),
        );
      }
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps. Please ensure a maps application is installed.')),
      );
    }
  }

  // ✅ --- NEW: Dialog to confirm navigation ---
  void _showDirectionsDialog(BuildContext context, AppointmentModel appointment, DoctorModel doctor) {
    // Don't show for clinic visits or if patient location is missing
    if (appointment.visitPreference != 'Home Visit' || appointment.patientLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Directions are only available for confirmed home visits.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Get Directions'),
          content: Text('Would you like to open maps to navigate to ${appointment.patientName}\'s location?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final doctorLocation = LatLng(doctor.location.latitude, doctor.location.longitude);
                final patientLocation = LatLng(appointment.patientLocation!.latitude, appointment.patientLocation!.longitude);
                _launchMapsUrl(doctorLocation, patientLocation);
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFEFFF8E8),
      appBar: AppBar(
        title: Text('My Schedule', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // ✅ --- MODIFIED: Wrapped StreamBuilder with a FutureBuilder to get doctor's profile first ---
      body: FutureBuilder<DoctorModel?>(
        future: _doctorProfileFuture,
        builder: (context, doctorSnapshot) {
          if (!doctorSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final doctor = doctorSnapshot.data!;

          return StreamBuilder<List<AppointmentModel>>(
            stream: _appointmentsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No appointments found in your schedule."));
              }

              final appointments = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];

                  Color statusColor;
                  switch (appointment.status) {
                    case 'confirmed': statusColor = Colors.green.shade100; break;
                    case 'rejected': statusColor = Colors.red.shade100; break;
                    default: statusColor = Colors.orange.shade100;
                  }

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(appointment.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(appointment.appointmentDate != null
                          ? DateFormat('EEE, MMM d, yyyy @ h:mm a').format(appointment.appointmentDate!.toDate()) // Show time
                          : 'Awaiting Confirmation', style: TextStyle(color: Colors.grey.shade700)),
                      trailing: Chip(
                        label: Text(appointment.status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        backgroundColor: statusColor,
                      ),
                      // ✅ --- ADDED: onTap logic for confirmed appointments ---
                      onTap: () {
                        if (appointment.status == 'confirmed') {
                          _showDirectionsDialog(context, appointment, doctor);
                        }
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
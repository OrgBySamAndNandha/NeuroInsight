import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:neuroinsight/screens/admin/models/doctor_appointment_model.dart'; // Import the async package

class DoctorScheduleView extends StatefulWidget {
  const DoctorScheduleView({super.key});

  @override
  State<DoctorScheduleView> createState() => _DoctorScheduleViewState();
}

class _DoctorScheduleViewState extends State<DoctorScheduleView> {
  Stream<List<AppointmentModel>>? _appointmentsStream;

  @override
  void initState() {
    super.initState();
    final User? doctor = FirebaseAuth.instance.currentUser;
    if (doctor != null) {
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
        // Remove duplicates in case an appointment is somehow in both
        final uniqueDocs = { for (var doc in allDocs) doc.id : doc }.values.toList();

        final appointments = uniqueDocs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
        // Sort by creation date
        appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return appointments;
      });
    }
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
      body: StreamBuilder<List<AppointmentModel>>(
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
                      ? DateFormat('EEE, MMM d, yyyy').format(appointment.appointmentDate!.toDate())
                      : 'Awaiting Confirmation', style: TextStyle(color: Colors.grey.shade700)),
                  trailing: Chip(
                    label: Text(appointment.status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    backgroundColor: statusColor,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neuroinsight/screens/admin/models/doctor_appointment_model.dart' show AppointmentModel;
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';

class MyAppointmentsView extends StatefulWidget {
  const MyAppointmentsView({super.key});

  @override
  State<MyAppointmentsView> createState() => _MyAppointmentsViewState();
}

class _MyAppointmentsViewState extends State<MyAppointmentsView> {
  late Future<Map<String, DoctorModel>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _fetchAllDoctors();
  }

  Future<Map<String, DoctorModel>> _fetchAllDoctors() async {
    final snapshot = await FirebaseFirestore.instance.collection('doctors').get();
    return {for (var doc in snapshot.docs) doc.id: DoctorModel.fromFirestore(doc)};
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Scaffold(body: Center(child: Text("Please log in.")));

    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      appBar: AppBar(
        title: Text('My Appointments', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, DoctorModel>>(
        future: _doctorsFuture,
        builder: (context, doctorsSnapshot) {
          if (!doctorsSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final doctorsMap = doctorsSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('patientId', isEqualTo: currentUser.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("You have no appointment requests."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final appointment = AppointmentModel.fromFirestore(snapshot.data!.docs[index]);
                  return _buildAppointmentCard(appointment, doctorsMap);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, Map<String, DoctorModel> doctorsMap) {
    switch (appointment.status) {
      case 'pending':
        final currentDoctorName = doctorsMap[appointment.currentDoctorId]?.doctorName ?? 'a doctor';
        return _buildStatusCard(
          icon: Icons.hourglass_top_rounded,
          color: Colors.orange,
          title: "Request Pending",
          body: "Your request is currently being reviewed by Dr. $currentDoctorName. We will notify you of any updates.",
        );
      case 'confirmed':
        final confirmedDoctorName = doctorsMap[appointment.confirmedDoctorId]?.doctorName ?? 'a doctor';
        return _buildStatusCard(
          icon: Icons.check_circle_rounded,
          color: Colors.green,
          title: "Appointment Confirmed!",
          body: "Your appointment with Dr. $confirmedDoctorName has been confirmed.",
          actions: [ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.directions), label: const Text("Get Directions"))],
        );
      case 'rejected':
        return _buildStatusCard(
          icon: Icons.cancel_rounded,
          color: Colors.red,
          title: "Request Not Fulfilled",
          body: "We're sorry, all available doctors were busy and your request could not be fulfilled. Please try again later.",
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    List<Widget>? actions,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 12),
            Text(body, style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7), height: 1.4)),
            if (actions != null && actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
            ]
          ],
        ),
      ),
    );
  }
}
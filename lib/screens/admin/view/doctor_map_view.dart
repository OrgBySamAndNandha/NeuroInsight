import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neuroinsight/screens/admin/controllers/doctors_auth_controller.dart';
import 'package:neuroinsight/screens/admin/models/doctor_appointment_model.dart';
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';

class DoctorMapView extends StatefulWidget {
  const DoctorMapView({super.key});

  @override
  State<DoctorMapView> createState() => _DoctorMapViewState();
}

class _DoctorMapViewState extends State<DoctorMapView> {
  final AdminAuthController _authController = AdminAuthController();
  Future<DoctorModel?>? _doctorProfileFuture;

  @override
  void initState() {
    super.initState();
    _doctorProfileFuture = _authController.getDoctorProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E8),
      appBar: AppBar(
        title: Text('My Patient Map', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<DoctorModel?>(
        future: _doctorProfileFuture,
        builder: (context, doctorSnapshot) {
          if (doctorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!doctorSnapshot.hasData || doctorSnapshot.data == null) {
            return const Center(child: Text('Could not load location data.'));
          }

          final doctor = doctorSnapshot.data!;
          final doctorLocation = LatLng(doctor.location.latitude, doctor.location.longitude);

          // This StreamBuilder fetches and displays confirmed home visits in real-time.
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('appointments')
                .where('confirmedDoctorId', isEqualTo: doctor.uid)
                .where('visitPreference', isEqualTo: 'Home Visit')
                .snapshots(),
            builder: (context, appointmentsSnapshot) {
              final Set<Marker> markers = {};

              // Marker for the doctor's own clinic
              markers.add(Marker(
                markerId: MarkerId(doctor.uid),
                position: doctorLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: InfoWindow(
                  title: doctor.doctorName,
                  snippet: "My Clinic",
                ),
              ));

              // Markers for patients with confirmed home visits
              if (appointmentsSnapshot.hasData) {
                for (var doc in appointmentsSnapshot.data!.docs) {
                  final appointment = AppointmentModel.fromFirestore(doc);
                  if (appointment.patientLocation != null) {
                    markers.add(Marker(
                      markerId: MarkerId(appointment.id),
                      position: LatLng(appointment.patientLocation!.latitude, appointment.patientLocation!.longitude),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      infoWindow: InfoWindow(
                        title: appointment.patientName,
                        snippet: "Patient Home Visit",
                      ),
                    ));
                  }
                }
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: doctorLocation,
                  zoom: 12.0,
                ),
                markers: markers,
              );
            },
          );
        },
      ),
    );
  }
}
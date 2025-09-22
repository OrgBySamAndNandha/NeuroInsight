import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:neuroinsight/screens/admin/controllers/doctors_auth_controller.dart';
import 'package:neuroinsight/screens/admin/models/doctor_appointment_model.dart';
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorMapView extends StatefulWidget {
  const DoctorMapView({super.key});

  @override
  State<DoctorMapView> createState() => _DoctorMapViewState();
}

class _DoctorMapViewState extends State<DoctorMapView> {
  final AdminAuthController _authController = AdminAuthController();
  Future<DoctorModel?>? _doctorProfileFuture;

  BitmapDescriptor? _patientPendingIcon;
  BitmapDescriptor? _patientConfirmedIcon;

  Future<BitmapDescriptor> _bitmapDescriptorFromIconData(IconData iconData, Color color, double size) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;

    // ✅ --- FIXED: Added the required 'ui.' prefix to TextDirection ---
    final TextPainter textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: iconData.fontFamily,
        color: Colors.white,
      ),
    );

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    textPainter.layout();
    textPainter.paint(canvas, Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));

    final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  void _setupCustomMarkers() async {
    _patientPendingIcon = await _bitmapDescriptorFromIconData(Icons.person_pin_circle, Colors.red, 120);
    _patientConfirmedIcon = await _bitmapDescriptorFromIconData(Icons.person_pin_circle, Colors.green, 120);

    if (mounted) {
      setState(() {});
    }
  }

  void _showPatientDetails(BuildContext context, AppointmentModel appointment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appointment.patientName, style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.sick_outlined, appointment.problemDescription),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                appointment.appointmentDate != null
                    ? DateFormat('EEE, MMM d, yyyy @ h:mm a').format(appointment.appointmentDate!.toDate())
                    : 'Not Scheduled',
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _doctorProfileFuture = _authController.getDoctorProfile();
    _setupCustomMarkers();
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
            return const Center(child: Text('Could not load your location data.'));
          }

          final doctor = doctorSnapshot.data!;
          final doctorLocation = LatLng(doctor.location.latitude, doctor.location.longitude);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('appointments')
                .where('currentDoctorId', isEqualTo: doctor.uid)
                .snapshots(),
            builder: (context, appointmentsSnapshot) {
              if (appointmentsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final Set<Marker> markers = {};

              markers.add(Marker(
                markerId: MarkerId(doctor.uid),
                position: doctorLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                infoWindow: InfoWindow(
                  title: doctor.doctorName,
                  snippet: "My Clinic",
                ),
              ));

              if (appointmentsSnapshot.hasData) {
                for (var doc in appointmentsSnapshot.data!.docs) {
                  final appointment = AppointmentModel.fromFirestore(doc);

                  if (appointment.patientLocation != null && appointment.visitPreference == 'Home Visit') {

                    BitmapDescriptor markerIcon;
                    if (appointment.status == 'confirmed') {
                      markerIcon = _patientConfirmedIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
                    } else {
                      markerIcon = _patientPendingIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
                    }

                    markers.add(Marker(
                      markerId: MarkerId(appointment.id),
                      position: LatLng(appointment.patientLocation!.latitude, appointment.patientLocation!.longitude),
                      icon: markerIcon,
                      infoWindow: InfoWindow(
                        title: appointment.patientName,
                        snippet: "Status: ${appointment.status}",
                      ),
                      onTap: () {
                        if (appointment.status == 'confirmed') {
                          _showPatientDetails(context, appointment);
                        }
                      },
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
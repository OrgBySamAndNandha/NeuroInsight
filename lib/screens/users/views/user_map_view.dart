import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // --- ✅ NEW: For catching PlatformException ---
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';
import 'package:neuroinsight/screens/users/views/user_booking_view.dart';
import 'package:neuroinsight/screens/admin/models/doctor_appointment_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _currentPosition;
  List<DoctorModel> _doctors = [];
  final Map<String, Marker> _markers = {};
  StreamSubscription? _appointmentStreamSubscription;
  AppointmentModel? _userAppointment;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _appointmentStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _requestLocationPermission();
    await _getLocation();
    await _fetchDoctors();
    _listenToAppointmentStatus();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }
    PermissionStatus permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }
  }

  Future<void> _getLocation() async {
    try {
      var locationData = await _locationController.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
          });
        }
      }
    } catch (e) {
      print("Could not get location: $e");
    }
  }

  Future<void> _fetchDoctors() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('doctors').get();
      if (mounted) {
        _doctors = snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
        _updateDoctorMarkers();
        _animateCameraToBounds();
      }
    } catch (e) {
      print("Error fetching doctors: $e");
    }
  }

  void _listenToAppointmentStatus() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _appointmentStreamSubscription = FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final appointment = AppointmentModel.fromFirestore(snapshot.docs.first);
        if (appointment.status == 'confirmed' || appointment.status == 'pending') {
          _userAppointment = appointment;
        } else {
          _userAppointment = null;
        }
      } else {
        _userAppointment = null;
      }
      if (mounted) {
        _updateDoctorMarkers();
      }
    });
  }

  void _updateDoctorMarkers() {
    if (!mounted) return;

    for (final doctor in _doctors) {
      BitmapDescriptor markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

      if (_userAppointment != null && _userAppointment!.status == 'confirmed') {
        if (_userAppointment!.confirmedDoctorId == doctor.uid) {
          markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        }
      }

      _markers[doctor.uid] = Marker(
        markerId: MarkerId(doctor.uid),
        position: LatLng(doctor.location.latitude, doctor.location.longitude),
        icon: markerColor,
        infoWindow: InfoWindow(title: doctor.doctorName, snippet: doctor.specialty),
        onTap: () => _onMarkerTapped(doctor),
      );
    }
    _updateUserMarker();
  }

  void _updateUserMarker() {
    if (_currentPosition == null || !mounted) return;

    _markers["current_location"] = Marker(
      markerId: const MarkerId("current_location"),
      position: _currentPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: "My Location"),
    );
    setState(() {});
  }

  void _animateCameraToBounds() async {
    if (_doctors.isEmpty || !mounted) return;

    final GoogleMapController controller = await _mapController.future;

    final allPoints = _doctors.map((d) => LatLng(d.location.latitude, d.location.longitude)).toList();
    if (_currentPosition != null) {
      allPoints.add(_currentPosition!);
    }

    LatLngBounds bounds = _boundsFromLatLngList(allPoints);

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  void _onMarkerTapped(DoctorModel doctor) {
    _showDoctorDetailsSheet(context, doctor);
  }

  void _showDoctorDetailsSheet(BuildContext context, DoctorModel doctor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bool isConfirmedWithThisDoctor = _userAppointment != null &&
            _userAppointment!.status == 'confirmed' &&
            _userAppointment!.confirmedDoctorId == doctor.uid;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.doctorName,
                style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.medical_services_outlined, doctor.specialty),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.business_outlined, doctor.hospitalName),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on_outlined, doctor.address),
              const SizedBox(height: 24),

              if (isConfirmedWithThisDoctor)
                _buildScheduledAppointmentInfo(doctor)
              else
                _buildRequestAppointmentButton(doctor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduledAppointmentInfo(DoctorModel doctor) {
    final appointmentTime = _userAppointment!.appointmentDate != null
        ? DateFormat('EEE, MMM d, yyyy @ h:mm a').format(_userAppointment!.appointmentDate!.toDate())
        : 'Not Scheduled';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Appointment is Confirmed!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.calendar_today_outlined, appointmentTime),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.directions, color: Colors.white),
            label: const Text(
              'Get Directions',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              if (_currentPosition != null) {
                _launchMapsUrl(
                  _currentPosition!,
                  LatLng(doctor.location.latitude, doctor.location.longitude),
                );
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
            ),
          ),
        ),
      ],
    );
  }

  // --- ✅ MODIFIED: Added a try-catch block to handle the PlatformException ---
  Future<void> _launchMapsUrl(LatLng origin, LatLng destination) async {
    final String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&travelmode=driving";
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
      // This exception is thrown on Android 11+ if the required <queries> are not in AndroidManifest.xml
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps. Please ensure a maps application is installed.')),
      );
    }
  }

  Widget _buildRequestAppointmentButton(DoctorModel doctor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => BookingView(doctor: doctor)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
        ),
        child: const Text(
          'Request Appointment',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find a Doctor', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: const LatLng(11.0168, 76.9558),
          zoom: 9,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
        markers: _markers.values.toSet(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

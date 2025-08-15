import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';
import 'package:neuroinsight/screens/users/views/user_booking_view.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';


class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer();
  final ScrollController _scrollController = ScrollController();

  LatLng? _currentPosition;
  List<DoctorModel> _doctors = [];
  final Map<String, Marker> _markers = {};
  String? _selectedDoctorId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _requestLocationPermission();
    await _fetchDoctors();
    _listenToLocationChanges();
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

  void _listenToLocationChanges() {
    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        if(mounted) {
          setState(() {
            _currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            _updateUserMarker();
          });
        }
      }
    });
  }

  Future<void> _fetchDoctors() async {
    final snapshot = await FirebaseFirestore.instance.collection('doctors').get();
    if(mounted) {
      setState(() {
        _doctors = snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
        _updateMarkers();
      });
    }
  }

  void _updateMarkers() {
    for (final doctor in _doctors) {
      _markers[doctor.uid] = Marker(
        markerId: MarkerId(doctor.uid),
        position: LatLng(doctor.location.latitude, doctor.location.longitude),
        onTap: () => _onMarkerTapped(doctor),
      );
    }
    _updateUserMarker();
  }

  void _updateUserMarker() {
    if (_currentPosition == null) return;
    _markers["current_location"] = Marker(
      markerId: const MarkerId("current_location"),
      position: _currentPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    setState(() {});
  }

  void _onMarkerTapped(DoctorModel doctor) {
    _showDoctorDetailsSheet(context, doctor);
    final index = _doctors.indexWhere((d) => d.uid == doctor.uid);
    if (index != -1) {
      // Each card is ~120px high (108 card + 12 vertical margin)
      _scrollController.animateTo(index * 120.0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
    setState(() {
      _selectedDoctorId = doctor.uid;
    });
  }

  void _onCardTapped(DoctorModel doctor) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(doctor.location.latitude, doctor.location.longitude), zoom: 14.0, bearing: 0, tilt: 0),
    ));
    setState(() {
      _selectedDoctorId = doctor.uid;
    });
  }

  /// --- NEW: LOGIC FOR SINGLE PENDING REQUEST ---
  Future<void> _handleRequest(DoctorModel doctor) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 1. Check for existing pending requests
    final pendingAppointments = await FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (mounted && pendingAppointments.docs.isNotEmpty) {
      // 2. If one exists, show an alert
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Request Already Pending"),
          content: const Text("You already have a pending appointment request. Please wait for it to be resolved before making a new one."),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))],
        ),
      );
    } else if (mounted) {
      // 3. If none exist, proceed to booking
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => BookingView(doctor: doctor)),
      );
    }
  }

  void _showDoctorDetailsSheet(BuildContext context, DoctorModel doctor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor.doctorName, style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.medical_services_outlined, doctor.specialty),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.business_outlined, doctor.hospitalName),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.star_outline, "${doctor.experience} years of experience"),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the sheet
                    _handleRequest(doctor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
                  ),
                  child: const Text('Request Appointment', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find a Doctor', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? const LatLng(11.2, 77.5),
                zoom: _currentPosition != null ? 14 : 9,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              markers: _markers.values.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: _doctors.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildDoctorList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doctor = _doctors[index];
        final isSelected = _selectedDoctorId == doctor.uid;
        return SizedBox(
          height: 120,
          child: GestureDetector(
            onTap: () => _onCardTapped(doctor),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              elevation: isSelected ? 8 : 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: 2)
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(doctor.doctorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("${doctor.specialty} • ${doctor.hospitalName}", style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('${doctor.experience} years experience', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _handleRequest(doctor),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                      ),
                      child: const Text('Request'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension on DoctorModel {
  get experience => null;
}
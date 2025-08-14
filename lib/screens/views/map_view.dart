// lib/screens/views/map_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location_pkg;
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _allDoctors = [];

  bool _isMapLoading = true;
  bool _isFetchingDoctors = false;
  String? _errorMessage;

  final location_pkg.Location _location = location_pkg.Location();
  StreamSubscription<location_pkg.LocationData>? _locationSubscription;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      await _setupLocationPermissions();
      await _getCurrentLocation();
      _startLocationTracking();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Initialization failed: ${e.toString()}";
          _isMapLoading = false;
        });
      }
    }
  }

  Future<void> _setupLocationPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('GPS service is not enabled.');
      }
    }

    var permission = await _location.hasPermission();
    if (permission == location_pkg.PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != location_pkg.PermissionStatus.granted) {
        throw Exception('Location permission was denied.');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isMapLoading = true;
      _errorMessage = null;
    });

    try {
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
            _isMapLoading = false;
          });
          _fetchNearbyDoctors();
        }
      } else {
        throw Exception('Could not get location coordinates.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error getting location: ${e.toString()}";
          _isMapLoading = false;
        });
      }
    }
  }

  void _startLocationTracking() {
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null && mounted) {
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          _updateMarkers();
        });
      }
    });
  }

  Future<void> _fetchNearbyDoctors() async {
    if (_currentLocation == null) return;

    setState(() {
      _isFetchingDoctors = true;
      _errorMessage = null; // Clear previous errors on a new attempt
    });

    // --- MODIFICATION: Optimized query for better performance ---
    // This query is more focused on official healthcare facilities.
    final query = """
      [out:json];
      (
        node(around:5000,${_currentLocation!.latitude},${_currentLocation!.longitude})["amenity"~"clinic|doctors"];
        node(around:5000,${_currentLocation!.latitude},${_currentLocation!.longitude})["healthcare"="clinic"];
      );
      out center;
    """;

    try {
      // --- MODIFICATION: Increased timeout from 20 to 30 seconds ---
      final response = await http.post(
        Uri.parse("https://overpass-api.de/api/interpreter"),
        body: {"data": query},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> doctors = [];
        for (var element in data['elements']) {
          final tags = element['tags'];
          String name = tags?['name'] ?? 'Doctor/Clinic';
          String specialty = tags?['speciality'] ?? tags?['healthcare:speciality'] ?? 'General';
          double lat = element['lat'] ?? element['center']['lat'];
          double lon = element['lon'] ?? element['center']['lon'];
          doctors.add({"name": name, "specialty": specialty, "location": LatLng(lat, lon)});
        }
        if (mounted) {
          setState(() {
            _allDoctors = doctors;
            _updateMarkers();
          });
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error fetching doctors: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingDoctors = false);
      }
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};
    for (var doctor in _allDoctors) {
      markers.add(Marker(
        markerId: MarkerId(doctor["name"] + doctor["location"].toString()),
        position: doctor["location"],
        infoWindow: InfoWindow(title: doctor["name"], snippet: doctor["specialty"]),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }
    if (_currentLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId("current_location"),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
    setState(() => _markers = markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- MODIFICATION: Moved Refresh button to AppBar's actions ---
      appBar: AppBar(
        title: Text('Find a Doctor Nearby', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Show a loading indicator in the AppBar while fetching doctors
          if (_isFetchingDoctors)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black54))),
            )
          else
          // Show the refresh button when not loading
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Doctors',
              onPressed: _fetchNearbyDoctors,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Main content: Map, Loading, or Error
          if (_isMapLoading)
            const Center(child: CircularProgressIndicator())
          else if (_currentLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 13.0,
              ),
              markers: _markers,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
            )
          else
            const Center(child: Text("Could not determine location.")),

          // Display error message on top of the map if it exists
          if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white.withOpacity(0.8),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      // --- MODIFICATION: Removed the FloatingActionButton ---
      // floatingActionButton: FloatingActionButton(...)
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
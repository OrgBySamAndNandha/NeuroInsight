import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';
import 'package:uuid/uuid.dart';

class BookingView extends StatefulWidget {
  final DoctorModel doctor;
  const BookingView({super.key, required this.doctor});

  @override
  State<BookingView> createState() => _BookingViewState();
}

enum VisitPreference { clinic, home }
enum SymptomSeverity { Low, Medium, High }

class _BookingViewState extends State<BookingView> {
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  bool _isLoading = false;
  SymptomSeverity _severity = SymptomSeverity.Low;
  VisitPreference _preference = VisitPreference.clinic;

  Future<String?> _uploadPhoto(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = const Uuid().v4();
      final imageRef = storageRef.child('appointment_photos/$fileName.jpg');
      await imageRef.putFile(image);
      return await imageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo upload failed: $e")),
      );
      return null;
    }
  }

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    GeoPoint? patientLocation;
    if (_preference == VisitPreference.home) {
      final locationData = await Location().getLocation();
      if(locationData.latitude != null && locationData.longitude != null) {
        patientLocation = GeoPoint(locationData.latitude!, locationData.longitude!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not get your location for a home visit.'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
        return;
      }
    }

    String? photoUrl;
    if (_imageFile != null) {
      photoUrl = await _uploadPhoto(_imageFile!);
      if (photoUrl == null) {
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      final appointmentsCollection = FirebaseFirestore.instance.collection('appointments');
      final newAppointmentId = appointmentsCollection.doc().id;

      await appointmentsCollection.doc(newAppointmentId).set({
        'appointmentId': newAppointmentId,
        'patientId': currentUser.uid,
        'patientName': currentUser.displayName ?? 'N/A',
        'problemDescription': _descriptionController.text.trim(),
        'symptomDuration': _durationController.text.trim(),
        'problemPhotoURL': photoUrl,
        'status': 'pending',
        'currentDoctorId': widget.doctor.uid,
        'confirmedDoctorId': null,
        'rejectionChain': [],
        'createdAt': Timestamp.now(),
        // --- NEW FIELDS ---
        'appointmentDate': null,
        'symptomSeverity': _severity.name,
        'visitPreference': _preference == VisitPreference.clinic ? 'Clinic Visit' : 'Home Visit',
        'patientLocation': patientLocation,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your request has been submitted.'), backgroundColor: Colors.green)
      );
      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit request: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      appBar: AppBar(
        title: Text('New Appointment Request', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request to ${widget.doctor.doctorName}', style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Describe your problem in detail',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Please describe your problem' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'How long have you had these symptoms?',
                  hintText: 'e.g., "3 days", "1 week"',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Please provide a duration' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Symptom Severity"),
              DropdownButtonFormField<SymptomSeverity>(
                value: _severity,
                items: SymptomSeverity.values.map((SymptomSeverity severity) {
                  return DropdownMenuItem<SymptomSeverity>(
                    value: severity,
                    child: Text(severity.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _severity = value!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Visit Preference"),
              SegmentedButton<VisitPreference>(
                segments: const <ButtonSegment<VisitPreference>>[
                  ButtonSegment<VisitPreference>(value: VisitPreference.clinic, label: Text('Visit Clinic'), icon: Icon(Icons.local_hospital)),
                  ButtonSegment<VisitPreference>(value: VisitPreference.home, label: Text('Home Visit'), icon: Icon(Icons.home)),
                ],
                selected: <VisitPreference>{_preference},
                onSelectionChanged: (Set<VisitPreference> newSelection) {
                  setState(() => _preference = newSelection.first);
                },
              ),
              const SizedBox(height: 20),
              _buildPhotoUploadSection(),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
                  ),
                  child: const Text('SUBMIT REQUEST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPhotoUploadSection() {
    var _pickImage;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _imageFile == null
              ? const Icon(Icons.image_outlined, color: Colors.grey, size: 40)
              : Image.file(_imageFile!, width: 40, height: 40, fit: BoxFit.cover),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _imageFile == null ? 'No photo selected' : 'Photo selected!',
              style: TextStyle(color: _imageFile == null ? Colors.grey : Colors.black),
            ),
          ),
          TextButton(
            onPressed:_pickImage,
            child: const Text('Upload Photo'),
          ),
        ],
      ),
    );
  }
}
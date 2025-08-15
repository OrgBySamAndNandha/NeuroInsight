// lib/screens/admin/views/doctor_profile_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neuroinsight/screens/admin/controllers/doctors_auth_controller.dart';
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  final AdminAuthController _authController = AdminAuthController();
  Future<DoctorModel?>? _doctorProfileFuture;

  @override
  void initState() {
    super.initState();
    _doctorProfileFuture = _authController.getDoctorProfile();
  }

  @override
  Widget build(BuildContext context) {
    // This is now the content of the "Profile" tab
    return FutureBuilder<DoctorModel?>(
      future: _doctorProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Could not load profile data.'));
        }

        final doctor = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: doctor.photoURL != null ? NetworkImage(doctor.photoURL!) : null,
                child: doctor.photoURL == null
                    ? const Icon(Icons.person, size: 60, color: Colors.black54)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                doctor.doctorName,
                style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.email,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),
              _buildInfoCard(
                icon: Icons.local_hospital_outlined,
                title: 'Specialty',
                subtitle: doctor.specialty,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.business_outlined,
                title: 'Hospital / Clinic',
                subtitle: doctor.hospitalName,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.location_on_outlined,
                title: 'Address',
                subtitle: doctor.address,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 3)),
                  onPressed: () => _authController.signOut(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(200),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String subtitle}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
      ),
    );
  }
}

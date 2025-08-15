// lib/screens/admin/views/doctor_records_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorRecordsView extends StatelessWidget {
  const DoctorRecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E8),
      appBar: AppBar(
        title: Text('Patient Records', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFFFF8E8),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_copy_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Patient records will appear here.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

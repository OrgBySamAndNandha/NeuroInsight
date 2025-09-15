import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/user_scan_report_model.dart';

class UserReportsListView extends StatelessWidget {
  const UserReportsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      appBar: AppBar(
        title: Text('My Saved Reports', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scan_reports')
            .where('patientId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no saved reports.'));
          }

          final reports = snapshot.data!.docs
              .map((doc) => ScanReportModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text('${report.reportType} Report'),
                  subtitle: Text('Saved on: ${DateFormat.yMMMd().format(report.createdAt.toDate())}'),
                  trailing: report.isAttachedToAppointment
                      ? const Tooltip(message: 'Attached to an appointment', child: Icon(Icons.check_circle, color: Colors.green))
                      : const Tooltip(message: 'Available to attach', child: Icon(Icons.hourglass_bottom, color: Colors.orange)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('${report.reportType} Report Details'),
                        content: SingleChildScrollView(child: SelectableText(report.analysisResultText)),
                        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
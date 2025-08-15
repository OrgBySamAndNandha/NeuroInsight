import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:neuroinsight/screens/admin/controllers/doctors_auth_controller.dart';
import 'package:neuroinsight/screens/admin/models/doctor_appointment_model.dart';
import 'package:neuroinsight/screens/admin/models/doctor_model.dart';
import 'package:neuroinsight/screens/admin/models/doctor_weather_model.dart';
import 'package:neuroinsight/screens/admin/services/doctor_weather_service.dart';


class DoctorDashboardView extends StatefulWidget {
  const DoctorDashboardView({super.key});

  @override
  State<DoctorDashboardView> createState() => _DoctorDashboardViewState();
}

class _DoctorDashboardViewState extends State<DoctorDashboardView> {
  final User? doctor = FirebaseAuth.instance.currentUser;
  final AdminAuthController _authController = AdminAuthController();
  final WeatherService _weatherService = WeatherService();
  Future<WeatherModel?>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  void _fetchWeatherData() async {
    final doctorProfile = await _authController.getDoctorProfile();
    if (doctorProfile != null && mounted) {
      setState(() {
        _weatherFuture = _weatherService.getWeather(
          doctorProfile.location.latitude,
          doctorProfile.location.longitude,
        );
      });
    }
  }

  Future<void> _showConfirmDialog(BuildContext context, AppointmentModel appointment) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate == null || !context.mounted) return;

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
    );

    if (selectedTime == null || !context.mounted) return;

    final finalDateTime = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day,
        selectedTime.hour, selectedTime.minute
    );

    _authController.confirmAppointmentDate(context, appointment.id, finalDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFEFFF8E8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Welcome, ${doctor?.displayName ?? 'Doctor'}!',
              style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildWeatherSection(),
            const SizedBox(height: 32),
            Text(
              'New Appointment Requests',
              style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildPendingAppointments(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSection() {
    return FutureBuilder<WeatherModel?>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Could not load weather data.'));
        }
        final weather = snapshot.data!;
        return _buildWeatherCard(weather);
      },
    );
  }

  Widget _buildWeatherCard(WeatherModel weather) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF42A5F5), // Restored blue color
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.cityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Image.network(
                      'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                      width: 35,
                      height: 35,
                      errorBuilder: (c, o, s) => const Icon(Icons.cloud_off, color: Colors.white70),
                    ),
                  ),
                  Text(
                    '${weather.temperature.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white30, thickness: 1, height: 32),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weather.hourlyForecast.length,
              itemBuilder: (context, index) {
                final hourly = weather.hourlyForecast[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('ha').format(hourly.time).toLowerCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        'https://openweathermap.org/img/wn/${hourly.iconCode}@2x.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (c, o, s) => const Icon(Icons.cloud_off, color: Colors.white70, size: 40),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${hourly.temperature.round()}°',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPendingAppointments() {
    if (doctor == null) return const Center(child: Text("Not logged in."));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('currentDoctorId', isEqualTo: doctor!.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('No new appointment requests.'),
            ),
          );
        }

        final appointments = snapshot.data!.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    _buildInfoRow('Severity:', appointment.symptomSeverity),
                    const SizedBox(height: 8),
                    _buildInfoRow('Visit Type:', appointment.visitPreference),
                    const SizedBox(height: 8),
                    _buildInfoRow('Symptoms Duration:', appointment.symptomDuration),
                    const SizedBox(height: 8),
                    _buildInfoRow('Problem:', appointment.problemDescription),
                    if (appointment.problemPhotoURL != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(appointment.problemPhotoURL!, height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _authController.rejectAndRerouteAppointment(context, appointment.id),
                          child: const Text('Reject', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showConfirmDialog(context, appointment),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Accept', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 15),
        children: [
          TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ' '),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

extension on AdminAuthController {
  void confirmAppointmentDate(BuildContext context, String id, DateTime finalDateTime) {}
}
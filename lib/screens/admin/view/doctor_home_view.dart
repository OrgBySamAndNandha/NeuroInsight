import 'package:flutter/material.dart';
import 'package:neuroinsight/screens/admin/view/doctor_dashboard_view.dart';
import 'package:neuroinsight/screens/admin/view/doctor_map_view.dart';
import 'package:neuroinsight/screens/admin/view/doctor_profile_view.dart';
import 'package:neuroinsight/screens/admin/view/doctor_schedule_view.dart';

class DoctorMainView extends StatefulWidget {
  const DoctorMainView({super.key});

  @override
  State<DoctorMainView> createState() => _DoctorMainViewState();
}

class _DoctorMainViewState extends State<DoctorMainView> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DoctorDashboardView(),
    DoctorMapView(),
    DoctorScheduleView(),
    DoctorProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFEFFF8E8),
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Patient Map'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
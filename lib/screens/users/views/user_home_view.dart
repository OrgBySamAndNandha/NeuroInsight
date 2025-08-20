import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neuroinsight/screens/admin/view/report_scanner.dart';
import 'package:neuroinsight/screens/users/controllers/user_profile_controllers.dart';
import 'package:neuroinsight/screens/users/views/user_appointments_view.dart';
import 'package:neuroinsight/screens/users/views/user_map_view.dart';
import 'user_profile_view.dart';

class UploadScanPage extends StatelessWidget {
  const UploadScanPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Upload MRI Scan Page',
            style: TextStyle(color: Colors.black, fontSize: 24)));
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final ProfileController _profileController = ProfileController();

  // MODIFIED: The 'Chat' tab at index 4 now points to ReportScannerView()
  static const List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    UploadScanPage(),
    MapView(),
    MyAppointmentsView(),
    ReportScannerView(), // Navigation set to the new screen
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfNewUser());
  }

  void _checkIfNewUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.metadata.creationTime != null && user.metadata.lastSignInTime != null) {
      final creationTime = user.metadata.creationTime!;
      final lastSignInTime = user.metadata.lastSignInTime!;
      final isNewUser = lastSignInTime.difference(creationTime).inSeconds < 5;
      final bool profileExists = await _profileController.checkProfileExists();
      if (isNewUser && !profileExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome! Let\'s start by setting up your profile.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileView()),
          );
        }
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file_rounded), label: 'files'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_rounded), label: 'Scanner'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1B1211),
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        iconSize: 30,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Home',
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neuroinsight/screens/users/views/user_home_view.dart';
import 'package:neuroinsight/screens/users/views/user_report_scanner.dart';
import 'package:neuroinsight/screens/users/controllers/user_profile_controllers.dart';
import 'package:neuroinsight/screens/users/views/user_appointments_view.dart';
import 'package:neuroinsight/screens/users/views/user_map_view.dart';
import 'user_profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final ProfileController _profileController = ProfileController();

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeContent(),
      const MapView(),
      const ReportScannerView(),
      const MyAppointmentsView(),
      const ProfileView(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfNewUser());
  }

  void _checkIfNewUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.metadata.creationTime != null &&
        user.metadata.lastSignInTime != null) {
      final creationTime = user.metadata.creationTime!;
      final lastSignInTime = user.metadata.lastSignInTime!;
      final isNewUser = lastSignInTime.difference(creationTime).inSeconds < 5;
      final bool profileExists = await _profileController.checkProfileExists();
      if (isNewUser && !profileExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
              Text('Welcome! Let\'s start by setting up your profile.'),
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
    const accentColor = Color(0xFF2DB8A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Match the new background
      body: SafeArea(
        bottom: false,
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner_outlined),
                activeIcon: Icon(Icons.document_scanner),
                label: 'Scanner',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                activeIcon: Icon(Icons.article),
                label: 'Reports',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: accentColor,
            unselectedItemColor: Colors.grey.shade500,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0, // Elevation is handled by the container's shadow
          ),
        ),
      ),
    );
  }
}

// The HomeContent widget remains unchanged
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FA), // Match the new background
      body: MemoryMatchGame(),
    );
  }
}
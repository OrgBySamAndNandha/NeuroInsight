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
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      body: SafeArea(
        bottom: false, // Ensure body content does not go behind the floating bar
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: Icons.home_outlined,
              isSelected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            _NavBarItem(
              icon: Icons.map_outlined,
              isSelected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            _NavBarItem(
              icon: Icons.document_scanner_outlined,
              isSelected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            _NavBarItem(
              icon: Icons.article_outlined,
              isSelected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            _NavBarItem(
              icon: Icons.person_outline,
              isSelected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}

// A custom widget for each navigation bar item
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white,
          size: 28,
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
      backgroundColor: Color(0xFFE1F7F5),
      body: MemoryMatchGame(),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class ViewReportsPage extends StatelessWidget {
  const ViewReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('View My Reports Page',
            style: TextStyle(color: Colors.black, fontSize: 24)));
  }
}

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Chat with AI Bot Page',
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

  static const List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    UploadScanPage(),
    MapView(),
    ViewReportsPage(),
    ChatBotPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.upload_file_rounded), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_rounded), label: 'Chat'),
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
    final User? _user = FirebaseAuth.instance.currentUser;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildWelcomeHeader(context, _user),
          const SizedBox(height: 28),
          _buildActionGrid(context),
          const SizedBox(height: 28),
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, User? _user) {
    String displayName =
        _user?.displayName?.split(' ')[0] ?? _user?.email ?? 'User';
    if (displayName.contains('@')) {
      displayName = displayName.split('@')[0];
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Welcome back,\n$displayName!',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileView()),
            );
          },
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _user?.photoURL != null
                ? NetworkImage(_user!.photoURL!)
                : null,
            child: _user?.photoURL == null
                ? const Icon(Icons.person, size: 35, color: Colors.black54)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          context: context,
          icon: Icons.upload_file_rounded,
          title: 'Upload MRI Scan',
          color: Colors.blue,
          onTap: () {},
        ),
        _buildDashboardCard(
          context: context,
          icon: Icons.calendar_month_rounded,
          title: 'My Appointments',
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyAppointmentsView()),
            );
          },
        ),
        _buildDashboardCard(
          context: context,
          icon: Icons.bar_chart_rounded,
          title: 'Health Analytics',
          color: Colors.orange,
          onTap: () {},
        ),
        _buildDashboardCard(
          context: context,
          icon: Icons.support_agent_rounded,
          title: 'Chat with AI Bot',
          color: Colors.purple,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: color,
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4.0,
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.info_outline_rounded,
                  color: Colors.black54, size: 30),
            ),
            title: const Text('No recent activity',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold)),
            subtitle: Text('Upload a scan to get started.',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
        ),
      ],
    );
  }
}
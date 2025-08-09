import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Corrected import for your folder structure
import '../controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  // Get the current user and an instance of the AuthController
  final User? _user = FirebaseAuth.instance.currentUser;
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroInsight Dashboard'),
        backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authController.signOut(context);
            },
          ),
        ],
      ),
      // Use the same gradient as the login screens for a consistent theme
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 32),
              _buildActionGrid(context),
              const SizedBox(height: 32),
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  // A widget to display a personalized welcome message
  Widget _buildWelcomeHeader() {
    // Use the user's display name if available (from Google), otherwise use the email
    String displayName = _user?.displayName?.split(' ')[0] ?? _user?.email ?? 'User';
    if (displayName.contains('@')) {
      displayName = displayName.split('@')[0];
    }

    return Text(
      'Welcome back,\n$displayName!',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // A grid of cards for the main application features
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
          onTap: () {
            // Placeholder action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload feature coming soon!')),
            );
          },
        ),
        _buildDashboardCard(
          context: context,
          icon: Icons.article_rounded,
          title: 'View My Reports',
          color: Colors.green,
          onTap: () {
            // Placeholder action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reports feature coming soon!')),
            );
          },
        ),
        _buildDashboardCard(
          context: context,
          icon: Icons.bar_chart_rounded,
          title: 'Health Analytics',
          color: Colors.orange,
          onTap: () {
            // Placeholder action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Analytics feature coming soon!')),
            );
          },
        ),
        _buildDashboardCard(
          context: context,
          icon: Icons.support_agent_rounded,
          title: 'Chat with AI Bot',
          color: Colors.purple,
          onTap: () {
            // Placeholder action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI Chat feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  // A reusable card widget for the dashboard grid
  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A placeholder section for recent activity
  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.white.withOpacity(0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
          child: const ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.info_outline_rounded, color: Colors.white),
            ),
            title: Text('No recent activity', style: TextStyle(color: Colors.white)),
            subtitle: Text('Upload a scan to get started.', style: TextStyle(color: Colors.white70)),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profile'),
        actions: [
          // Logout button
          IconButton(
            onPressed: () => _showLogoutDialog(context, authNotifier),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(context, authState),
              const SizedBox(height: 32),

              // Profile Options
              _buildProfileOptions(context),
              const SizedBox(height: 32),

              // App Info
              _buildAppInfo(context),
              const SizedBox(height: 100), // Extra space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthState authState) {
    String userEmail = 'Not logged in';
    String userName = 'Guest User';

    if (authState is AuthAuthenticated) {
      userEmail = authState.user.email ?? 'No email';
      userName = authState.user.displayName ??
          authState.user.email?.split('@').first ??
          'Healthcare User';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF1565C0),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              userName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1565C0),
                  ),
            ),
            const SizedBox(height: 8),

            // User Email
            Text(
              userEmail,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),

            // User Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Verified Patient',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    final options = [
      {
        'icon': Icons.medical_information,
        'title': 'Medical History',
        'subtitle': 'View your health records',
        'onTap': () => _showComingSoon(context, 'Medical History'),
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Manage your alerts',
        'onTap': () => _showComingSoon(context, 'Notifications'),
      },
      {
        'icon': Icons.security,
        'title': 'Privacy & Security',
        'subtitle': 'Manage your data privacy',
        'onTap': () => _showComingSoon(context, 'Privacy Settings'),
      },
      {
        'icon': Icons.support_agent,
        'title': 'Help & Support',
        'subtitle': 'Get help and contact support',
        'onTap': () => _showComingSoon(context, 'Support'),
      },
      {
        'icon': Icons.info_outline,
        'title': 'About',
        'subtitle': 'App version and legal info',
        'onTap': () => _showAboutDialog(context),
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: options.map((option) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                option['icon'] as IconData,
                color: const Color(0xFF1565C0),
              ),
            ),
            title: Text(
              option['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(option['subtitle'] as String),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: option['onTap'] as VoidCallback,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.medical_services, size: 40, color: Colors.blue[700]),
          const SizedBox(height: 8),
          Text(
            '🏆 HackTheBrain 2025',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Healthcare AI - Competition Winner\n'
            'AI-Powered Medical Triage System\n'
            'Real-time Healthcare Coordination',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Version 1.0.0 • Built with Firebase',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthNotifier authNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              authNotifier.signOut();
              context.go('/auth/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon! 🚀'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Healthcare AI',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.medical_services,
        size: 48,
        color: Color(0xFF1565C0),
      ),
      children: [
        const Text(
          'HackTheBrain 2025 Healthcare AI System\n\n'
          '🎯 Features:\n'
          '• AI-Powered Medical Triage\n'
          '• Real-time Clinic Availability\n'
          '• GTA Healthcare Coordination\n'
          '• Evidence-based Wait Times\n\n'
          'Built with Flutter & Firebase\n'
          'Powered by Google Gemini AI',
        ),
      ],
    );
  }
}

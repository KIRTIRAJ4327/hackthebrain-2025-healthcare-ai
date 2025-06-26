import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/triage/screens/triage_screen.dart';
import '../../features/appointments/screens/appointments_screen.dart';
import '../../features/providers/screens/providers_screen.dart';
import '../../features/providers/screens/gta_map_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/dashboard/screens/healthcare_coordination_dashboard.dart';
import '../../features/emergency/screens/emergency_screen.dart';
import '../../shared/screens/splash_screen.dart';
import '../../shared/screens/not_found_screen.dart';

/// 🏥 Healthcare AI App Router with Firebase Authentication
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // 🔐 Authentication-aware redirect logic
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isGoingToAuth = state.uri.path.startsWith('/auth');
      final isGoingToEmergency = state.uri.path == '/emergency';

      // Allow emergency access without authentication
      if (isGoingToEmergency) return null;

      // Handle authentication states
      if (authState is AuthLoading) {
        return '/splash';
      } else if (authState is AuthUnauthenticated) {
        return isGoingToAuth ? null : '/auth/login';
      } else if (authState is AuthAuthenticated) {
        // If authenticated and going to auth pages, redirect to home
        if (isGoingToAuth || state.uri.path == '/splash') {
          return '/home';
        }
      }

      // Redirect root to appropriate location
      if (state.uri.path == '/') {
        return authState is AuthAuthenticated ? '/home' : '/auth/login';
      }

      return null;
    },

    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Emergency Route (No Auth Required)
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),

      // Main App Routes (Authentication Required)
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationWrapper(child: child);
        },
        routes: [
          // Home Dashboard
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Medical Triage System
          GoRoute(
            path: '/triage',
            name: 'triage',
            builder: (context, state) => const TriageScreen(),
          ),

          // Appointments Management
          GoRoute(
            path: '/appointments',
            name: 'appointments',
            builder: (context, state) => const AppointmentsScreen(),
          ),

          // Healthcare Providers
          GoRoute(
            path: '/providers',
            name: 'providers',
            builder: (context, state) => const ProvidersScreen(),
          ),

          // 🗺️ GTA Healthcare Coordination Map
          GoRoute(
            path: '/gta-map',
            name: 'gta-map',
            builder: (context, state) => const GTAMapScreen(),
          ),

          // 🏆 Healthcare Coordination Dashboard (Competition Demo)
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) =>
                const HealthcareCoordinationDashboard(),
          ),

          // User Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // 404 Not Found
      GoRoute(
        path: '/404',
        name: 'not-found',
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],

    // Handle unknown routes
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});

/// 🧭 Main Navigation Wrapper with Firebase User Context
class MainNavigationWrapper extends ConsumerWidget {
  final Widget child;

  const MainNavigationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: authState is AuthAuthenticated
          ? child
          : const Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: authState is AuthAuthenticated
          ? _buildBottomNavigation(context, ref)
          : null,
    );
  }

  Widget _buildBottomNavigation(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).uri.path;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1565C0),
      unselectedItemColor: Colors.grey,
      currentIndex: _getCurrentIndex(currentLocation),
      onTap: (index) => _onBottomNavTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.health_and_safety_outlined),
          activeIcon: Icon(Icons.health_and_safety),
          label: 'Triage',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital_outlined),
          activeIcon: Icon(Icons.local_hospital),
          label: 'Providers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/triage')) return 1;
    if (location.startsWith('/appointments')) return 2;
    if (location.startsWith('/providers')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/triage');
        break;
      case 2:
        context.go('/appointments');
        break;
      case 3:
        context.go('/providers');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

// Placeholder screens for missing implementations
class TriageResultScreen extends StatelessWidget {
  final String sessionId;
  const TriageResultScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Triage Result: $sessionId')),
      body: const Center(child: Text('Triage result details coming soon')),
    );
  }
}

class BookAppointmentScreen extends StatelessWidget {
  final String? providerId;
  final String? specialty;
  const BookAppointmentScreen({super.key, this.providerId, this.specialty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: const Center(child: Text('Appointment booking coming soon')),
    );
  }
}

class AppointmentDetailsScreen extends StatelessWidget {
  final String appointmentId;
  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointment: $appointmentId')),
      body: const Center(child: Text('Appointment details coming soon')),
    );
  }
}

class ProviderDetailsScreen extends StatelessWidget {
  final String providerId;
  const ProviderDetailsScreen({super.key, required this.providerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Provider: $providerId')),
      body: const Center(child: Text('Provider details coming soon')),
    );
  }
}

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical History')),
      body: const Center(child: Text('Medical history coming soon')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings coming soon')),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Analytics dashboard coming soon')),
    );
  }
}

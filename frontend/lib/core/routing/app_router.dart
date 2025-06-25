import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/triage/screens/triage_screen.dart';
import '../../features/appointments/screens/appointments_screen.dart';
import '../../features/providers/screens/providers_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/emergency/screens/emergency_screen.dart';
import '../../shared/screens/splash_screen.dart';
import '../../shared/screens/not_found_screen.dart';
import '../providers/auth_provider.dart';

/// 🏥 Healthcare AI App Router
/// Handles navigation and route protection for the medical application
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // Redirect logic for authentication - DEMO MODE: Skip auth for hackathon
    redirect: (context, state) {
      // Skip authentication for demo - allow all routes
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
        path: '/auth',
        redirect: (context, state) => '/auth/login',
      ),

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
            routes: [
              // Quick Triage from Home
              GoRoute(
                path: 'quick-triage',
                name: 'quick-triage',
                builder: (context, state) =>
                    const TriageScreen(isQuickAccess: true),
              ),
            ],
          ),

          // Medical Triage System
          GoRoute(
            path: '/triage',
            name: 'triage',
            builder: (context, state) => const TriageScreen(),
            routes: [
              GoRoute(
                path: 'result/:sessionId',
                name: 'triage-result',
                builder: (context, state) {
                  final sessionId = state.pathParameters['sessionId']!;
                  return TriageResultScreen(sessionId: sessionId);
                },
              ),
            ],
          ),

          // Appointments Management
          GoRoute(
            path: '/appointments',
            name: 'appointments',
            builder: (context, state) => const AppointmentsScreen(),
            routes: [
              GoRoute(
                path: 'book',
                name: 'book-appointment',
                builder: (context, state) {
                  final providerId = state.uri.queryParameters['providerId'];
                  final specialty = state.uri.queryParameters['specialty'];
                  return BookAppointmentScreen(
                    providerId: providerId,
                    specialty: specialty,
                  );
                },
              ),
              GoRoute(
                path: ':appointmentId',
                name: 'appointment-details',
                builder: (context, state) {
                  final appointmentId = state.pathParameters['appointmentId']!;
                  return AppointmentDetailsScreen(appointmentId: appointmentId);
                },
              ),
            ],
          ),

          // Healthcare Providers
          GoRoute(
            path: '/providers',
            name: 'providers',
            builder: (context, state) => const ProvidersScreen(),
            routes: [
              GoRoute(
                path: ':providerId',
                name: 'provider-details',
                builder: (context, state) {
                  final providerId = state.pathParameters['providerId']!;
                  return ProviderDetailsScreen(providerId: providerId);
                },
              ),
            ],
          ),

          // User Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'medical-history',
                name: 'medical-history',
                builder: (context, state) => const MedicalHistoryScreen(),
              ),
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),

          // Analytics Dashboard (for providers)
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => NotFoundScreen(
      error: state.error?.toString() ?? 'Page not found',
    ),
  );
});

/// Main Navigation Wrapper with Bottom Navigation
class MainNavigationWrapper extends StatelessWidget {
  final Widget child;

  const MainNavigationWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const HealthcareBottomNavigation(),
    );
  }
}

/// Healthcare-themed Bottom Navigation
class HealthcareBottomNavigation extends StatelessWidget {
  const HealthcareBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    int getCurrentIndex() {
      if (location.startsWith('/home')) return 0;
      if (location.startsWith('/triage')) return 1;
      if (location.startsWith('/appointments')) return 2;
      if (location.startsWith('/providers')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: Colors.grey,
      currentIndex: getCurrentIndex(),
      onTap: (index) {
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
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services_outlined),
          activeIcon: Icon(Icons.medical_services),
          label: 'AI Triage',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
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
}

// Placeholder screens - will be implemented in their respective feature folders
class TriageResultScreen extends StatelessWidget {
  final String sessionId;
  const TriageResultScreen({super.key, required this.sessionId});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class BookAppointmentScreen extends StatelessWidget {
  final String? providerId;
  final String? specialty;
  const BookAppointmentScreen({super.key, this.providerId, this.specialty});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AppointmentDetailsScreen extends StatelessWidget {
  final String appointmentId;
  const AppointmentDetailsScreen({super.key, required this.appointmentId});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class ProviderDetailsScreen extends StatelessWidget {
  final String providerId;
  const ProviderDetailsScreen({super.key, required this.providerId});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('❌ Error loading .env file: $e');
  }

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Clear any potentially expired authentication state
    try {
      await FirebaseAuth.instance.signOut();
      print('🔄 Cleared existing authentication state');
    } catch (e) {
      print('ℹ️ No existing authentication state to clear: $e');
    }
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  runApp(const ProviderScope(child: HealthcareAIApp()));
}

class HealthcareAIApp extends ConsumerWidget {
  const HealthcareAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Healthcare AI - HackTheBrain 2025',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Global error handling wrapper
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler:
                const TextScaler.linear(1.0), // Prevent text scaling issues
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

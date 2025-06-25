import 'package:flutter/material.dart';

/// Splash Screen for Healthcare AI App
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // App Title
            const Text(
              'Healthcare AI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Reducing Wait Times',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontFamily: 'Inter',
              ),
            ),

            const SizedBox(height: 48),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),

            const SizedBox(height: 24),

            // HackTheBrain Badge
            const Text(
              '🚀 Built for HackTheBrain 2025',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

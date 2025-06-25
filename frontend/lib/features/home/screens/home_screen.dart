import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏥 Healthcare AI Dashboard')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 80, color: Color(0xFF2563EB)),
            SizedBox(height: 32),
            Text('Healthcare Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            Text('🚧 Dashboard coming soon', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

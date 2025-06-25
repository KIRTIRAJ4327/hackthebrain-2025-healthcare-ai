import 'package:flutter/material.dart';

class ProvidersScreen extends StatelessWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏥 Healthcare Providers')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 80, color: Color(0xFF2563EB)),
            SizedBox(height: 32),
            Text('Healthcare Providers',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            Text('🚧 Provider directory coming soon',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

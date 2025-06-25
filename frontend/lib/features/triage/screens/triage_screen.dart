import 'package:flutter/material.dart';

class TriageScreen extends StatelessWidget {
  final bool isQuickAccess;

  const TriageScreen({super.key, this.isQuickAccess = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              isQuickAccess ? '🚀 Quick AI Triage' : '🏥 AI Triage System')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 80, color: Color(0xFF059669)),
            SizedBox(height: 32),
            Text('AI Medical Triage',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            Text('🚧 AI Triage system coming soon',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

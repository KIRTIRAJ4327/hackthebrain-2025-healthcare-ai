import 'package:flutter/material.dart';

class ProvidersScreen extends StatelessWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏥 Healthcare Providers')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_hospital,
                size: 80, color: Color(0xFF2563EB)),
            const SizedBox(height: 32),
            const Text('Healthcare Providers',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2563EB),
                  child: Icon(Icons.local_hospital, color: Colors.white),
                ),
                title: const Text('Toronto General Hospital'),
                subtitle: const Text('15 min wait • Cardiology, Emergency'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('View'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2563EB),
                      foregroundColor: Colors.white),
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.local_hospital, color: Colors.white),
                ),
                title: Text('Mount Sinai Hospital'),
                subtitle: Text('8 min wait • General Medicine'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('View'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2563EB),
                      foregroundColor: Colors.white),
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.local_hospital, color: Colors.white),
                ),
                title: Text('Sunnybrook Health Centre'),
                subtitle: Text('25 min wait • Specialized Care'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('View'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2563EB),
                      foregroundColor: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.map),
                label: Text('View on GTA Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

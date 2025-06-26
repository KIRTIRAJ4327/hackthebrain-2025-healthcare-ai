import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👤 Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, size: 80, color: Color(0xFF2563EB)),
              const SizedBox(height: 32),
              const Text('User Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF2563EB),
                        child: Text('JD',
                            style:
                                TextStyle(fontSize: 24, color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      const Text('John Doe',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('john.doe@email.com',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Column(
                            children: [
                              Text('3',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB))),
                              Text('Appointments'),
                            ],
                          ),
                          const Column(
                            children: [
                              Text('12',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB))),
                              Text('AI Analyses'),
                            ],
                          ),
                          const Column(
                            children: [
                              Text('98%',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB))),
                              Text('Health Score'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.medical_services, color: Color(0xFF2563EB)),
                title: Text('Medical History'),
                trailing: Icon(Icons.chevron_right),
              ),
              const ListTile(
                leading: Icon(Icons.notifications, color: Color(0xFF2563EB)),
                title: Text('Notifications'),
                trailing: Icon(Icons.chevron_right),
              ),
              const ListTile(
                leading: Icon(Icons.settings, color: Color(0xFF2563EB)),
                title: Text('Settings'),
                trailing: Icon(Icons.chevron_right),
              ),
              // Add extra padding at bottom to ensure scrollability
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

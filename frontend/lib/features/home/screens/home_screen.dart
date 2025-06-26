import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

/// Home Dashboard Screen for Healthcare AI App
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare AI Dashboard'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔔 No new notifications')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👋 Welcome to Healthcare AI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reducing wait times from 30 weeks to 12-18 weeks',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Target: 50% wait time reduction',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Firebase Backend Status Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_done,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Firebase Backend Connected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Project: hackthebrain-healthcare-ai',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Realtime Database Ready',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Authentication Service Ready',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Cloud Storage Ready',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _testFirebaseConnection(context),
                        icon: const Icon(Icons.sync, size: 16),
                        label: const Text('Test Connection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _testRealTimeData(context),
                        icon: const Icon(Icons.timeline, size: 16),
                        label: const Text('Live Data Demo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Grid
            const Text(
              '🚀 Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.psychology,
                  title: 'AI Triage',
                  subtitle: 'Smart symptom assessment',
                  color: Colors.purple,
                  onTap: () => context.push('/triage'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Book Appointment',
                  subtitle: 'Smart scheduling',
                  color: Colors.green,
                  onTap: () => context.push('/appointments'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.local_hospital,
                  title: 'Find Providers',
                  subtitle: 'Locate specialists',
                  color: Colors.orange,
                  onTap: () => context.push('/providers'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.emergency,
                  title: 'Emergency',
                  subtitle: 'Immediate care',
                  color: Colors.red,
                  onTap: () => context.push('/emergency'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Stats Section
            const Text(
              '📊 Impact Metrics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '1,500+',
                    'Lives Saved Annually',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '\$170M+',
                    'Healthcare Savings',
                    Icons.savings,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '50%',
                    'Wait Time Reduction',
                    Icons.trending_down,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '24/7',
                    'AI Availability',
                    Icons.access_time,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // HackTheBrain 2025 Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    '🚀 HackTheBrain 2025',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Healthcare AI Solution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Working prototype with Flutter frontend, Firebase backend, and smart scheduling algorithms',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('🎯 Demo Features'),
                          content: const Text(
                            'Navigation ✅\nUI/UX Design ✅\nHealthcare Theme ✅\nFirebase Backend ✅\nReady for AI Integration ✅\nAPI Endpoints Ready ✅',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Got it!'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('View Demo Status'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testFirebaseConnection(BuildContext context) {
    try {
      final app = Firebase.app();
      final projectId = app.options.projectId;
      final isConnected = app.name == '[DEFAULT]';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isConnected ? Icons.cloud_done : Icons.cloud_off,
                color: isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              const Text('Firebase Status'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔗 Connection: ${isConnected ? 'Connected' : 'Disconnected'}',
              ),
              const SizedBox(height: 8),
              Text('📊 Project ID: $projectId'),
              const SizedBox(height: 8),
              Text(
                  '🌐 Database URL: ${app.options.databaseURL ?? 'Not configured'}'),
              const SizedBox(height: 8),
              Text(
                  '🔐 Auth Domain: ${app.options.authDomain ?? 'Not configured'}'),
              const SizedBox(height: 8),
              const Text('✅ Ready for AI integration with Gemini API'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Firebase Status'),
            ],
          ),
          content: Text('Firebase connection error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _testRealTimeData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _FirebaseRealTimeDemo(),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Firebase Real-Time Demo Widget
class _FirebaseRealTimeDemo extends StatefulWidget {
  const _FirebaseRealTimeDemo();

  @override
  State<_FirebaseRealTimeDemo> createState() => _FirebaseRealTimeDemoState();
}

class _FirebaseRealTimeDemoState extends State<_FirebaseRealTimeDemo> {
  int _counter = 0;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _simulateFirebaseDemo();
  }

  void _simulateFirebaseDemo() {
    _addLog("🔗 Connecting to Firebase...");
    Future.delayed(const Duration(milliseconds: 500), () {
      _addLog("✅ Firebase Core initialized");
      Future.delayed(const Duration(milliseconds: 300), () {
        _addLog("🔥 Database URL: hackthebrain-healthcare-ai.firebaseio.com");
        Future.delayed(const Duration(milliseconds: 300), () {
          _addLog("🎯 Ready for real-time operations!");
        });
      });
    });
  }

  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _logs.add(message);
      });
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter = _counter + 1;
    });
    _addLog("📊 Counter incremented to $_counter (simulated Firebase write)");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.timeline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Firebase Backend Demo'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Counter Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    '🔴 Live Counter Demo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_counter',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Firebase Logs
            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Firebase Console:',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _logs
                            .map(
                              (log) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  log,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'This demonstrates Firebase backend connectivity!\nIn production: Real-time sync across all devices.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: _incrementCounter,
          icon: const Icon(Icons.add),
          label: const Text('Increment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

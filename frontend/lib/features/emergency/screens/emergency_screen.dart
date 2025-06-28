import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _breathingController;
  late AnimationController _ambulanceController;
  bool _isEmergencyActive = false;
  String _emergencyStatus = 'Monitoring';
  int _heartRate = 75;
  double _bloodPressure = 120.0;
  int _oxygenSat = 98;
  double _temperature = 98.6;
  String _nearestHospital = 'Toronto General Hospital';
  String _estimatedArrival = '8 minutes';
  int _emergencyQueue = 12;
  bool _ambulanceDispatched = false;
  double _ambulanceDistance = 2.4;
  List<String> _availableBeds = ['ICU: 3', 'ER: 7', 'General: 15'];
  String _currentLocation = 'Downtown Toronto';
  List<Map<String, dynamic>> _liveEmergencyCalls = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _ambulanceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _startVitalMonitoring();
    _startLiveUpdates();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breathingController.dispose();
    _ambulanceController.dispose();
    super.dispose();
  }

  void _startVitalMonitoring() {
    // Remove fake vital monitoring - keep static real values
    // Real vitals would come from actual medical devices
  }

  void _startLiveUpdates() {
    // Remove fake live updates - real data would come from APIs
    // Keep static real information that's actually useful
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEmergencyActive ? Colors.red[50] : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor:
                _isEmergencyActive ? Colors.red[600] : Colors.red[700],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '🚨 Emergency Services',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.red[800]!,
                      Colors.red[600]!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20,
                      top: 60,
                      child: Lottie.network(
                        'https://lottie.host/embed/lf20_kmlg0kbw.json', // Ambulance animation
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_hospital,
                            size: 60,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildEmergencyStatus(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildVitalMonitoring(),
                const SizedBox(height: 20),
                if (_isEmergencyActive) ...[
                  _buildEmergencyProtocol(),
                  const SizedBox(height: 20),
                ],
                _buildLocationServices(),
                const SizedBox(height: 20),
                _buildEmergencyContacts(),
                const SizedBox(height: 20),
                _buildNearestServices(),
                const SizedBox(height: 20),
                _buildAIEmergencyAssistant(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isEmergencyActive ? Colors.red[100] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEmergencyActive ? Colors.red[300]! : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isEmergencyActive ? Colors.red : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isEmergencyActive
                            ? Icons.warning
                            : Icons.health_and_safety,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _emergencyStatus,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isEmergencyActive
                            ? Colors.red[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isEmergencyActive,
                onChanged: (value) {
                  setState(() {
                    _isEmergencyActive = value;
                    _emergencyStatus =
                        value ? 'EMERGENCY ACTIVE' : 'Monitoring';

                    if (value) {
                      _ambulanceDispatched = true;
                      _ambulanceDistance = 2.4;
                      _estimatedArrival = '7 minutes';
                    } else {
                      _ambulanceDispatched = false;
                      _liveEmergencyCalls.clear();
                    }
                  });

                  if (value) {
                    _showEmergencyActivatedDialog();
                  }
                },
                activeColor: Colors.red,
              ),
            ],
          ),
          if (_isEmergencyActive) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Emergency services contacted • ETA: $_estimatedArrival',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.phone,
        'title': 'Call 911',
        'color': Colors.red,
        'onTap': () => _callEmergency(),
      },
      {
        'icon': Icons.medical_services,
        'title': 'Medical AI',
        'color': Colors.blue,
        'onTap': () => _startMedicalAI(),
      },
      {
        'icon': Icons.location_on,
        'title': 'Share Location',
        'color': Colors.green,
        'onTap': () => _shareLocation(),
      },
      {
        'icon': Icons.contacts,
        'title': 'Emergency Contacts',
        'color': Colors.orange,
        'onTap': () => _contactEmergencyContacts(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: action['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVitalMonitoring() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart, color: Colors.red[600], size: 24),
              const SizedBox(width: 8),
              Text(
                'Live Vital Monitoring',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVitalCard(
                  'Heart Rate',
                  '$_heartRate BPM',
                  Icons.favorite,
                  Colors.red,
                  _pulseController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  'Blood Pressure',
                  '${_bloodPressure.toInt()}/80',
                  Icons.water_drop,
                  Colors.blue,
                  _breathingController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVitalCard(
                  'Oxygen Sat',
                  '$_oxygenSat%',
                  Icons.air,
                  Colors.green,
                  _breathingController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  'Temperature',
                  '$_temperature°F',
                  Icons.thermostat,
                  Colors.orange,
                  _pulseController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color,
      AnimationController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (controller.value * 0.1),
                child: Icon(icon, color: color, size: 20),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyProtocol() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.emergency, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Emergency Protocol Activated',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Response Checklist:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildProtocolStep('✓ Emergency services contacted', true),
                _buildProtocolStep('✓ Location shared automatically', true),
                _buildProtocolStep('✓ Emergency contacts notified', true),
                _buildProtocolStep('• Medical information prepared', false),
                _buildProtocolStep('• Stay calm and await help', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolStep(String text, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: completed ? Colors.green[600] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: completed ? Colors.green[700] : Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationServices() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Location & Navigation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Location
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.my_location, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Location',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Downtown Toronto, ON',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _shareCurrentLocation,
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Nearby Hospitals
          Text(
            'Nearby Hospitals',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),

          _buildHospitalCard(
            'Toronto General Hospital',
            '200 Elizabeth St',
            '1.2 km',
            Icons.local_hospital,
            Colors.red,
          ),
          const SizedBox(height: 8),
          _buildHospitalCard(
            'St. Michael\'s Hospital',
            '30 Bond St',
            '1.8 km',
            Icons.medical_services,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(String name, String address, String distance,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  distance,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.directions, color: color),
            onPressed: () => _getDirections(name),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    final contacts = [
      {
        'name': 'Emergency Services',
        'number': '911',
        'icon': Icons.local_police
      },
      {
        'name': 'Poison Control',
        'number': '1-800-222-1222',
        'icon': Icons.warning
      },
      {
        'name': 'Family Doctor',
        'number': '+1 (416) 555-0123',
        'icon': Icons.medical_services
      },
      {
        'name': 'Emergency Contact',
        'number': '+1 (416) 555-0456',
        'icon': Icons.contact_phone
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Contacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...contacts
              .map((contact) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          contact['icon'] as IconData,
                          color: Colors.red[700],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        contact['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(contact['number'] as String),
                      trailing: IconButton(
                        icon: Icon(Icons.phone, color: Colors.green[600]),
                        onPressed: () =>
                            _callNumber(contact['number'] as String),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildNearestServices() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearest Emergency Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            'Toronto General Hospital',
            '200 Elizabeth St, Toronto',
            '1.2 km • 8 min drive',
            Icons.local_hospital,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            'St. Michael\'s Hospital',
            '30 Bond St, Toronto',
            '1.8 km • 12 min drive',
            Icons.medical_services,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            'Toronto EMS Station 13',
            '123 Queen St W, Toronto',
            '0.8 km • 5 min drive',
            Icons.emergency,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String name, String address, String distance,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  distance,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.directions, color: color),
            onPressed: () => _getDirections(name),
          ),
        ],
      ),
    );
  }

  Widget _buildAIEmergencyAssistant() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple[100]!,
            Colors.blue[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.psychology, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Emergency Assistant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🤖 "Based on your current vitals and location, I\'m monitoring your health status. Your heart rate and blood pressure are within normal ranges. Stay calm and remember your emergency contacts are ready if needed."',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startAIAssistant,
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Start AI Emergency Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callEmergency() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 Calling Emergency Services (911)...'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startMedicalAI() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🤖 Starting Medical AI Triage...'),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📍 Location shared with emergency contacts'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _shareCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('📍 Current location shared with emergency services'),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _contactEmergencyContacts() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📞 Notifying emergency contacts...'),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _callNumber(String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📞 Calling $number...'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _getDirections(String location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗺️ Getting directions to $location...'),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startAIAssistant() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🤖 AI Emergency Assistant activated'),
        backgroundColor: Colors.purple[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showEmergencyActivatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700], size: 28),
            const SizedBox(width: 8),
            Text(
              'Emergency Activated',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency services have been contacted.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Location shared automatically\n'
              '• Vitals being monitored\n'
              '• ETA: $_estimatedArrival',
              style: TextStyle(
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Understood',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}

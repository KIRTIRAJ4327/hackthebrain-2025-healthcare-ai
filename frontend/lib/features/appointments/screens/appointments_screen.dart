import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/services/enhanced_clinic_booking.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'doctor': 'Dr. Sarah Chen',
      'specialty': 'Cardiology',
      'date': 'Tomorrow, 10:30 AM',
      'location': 'Toronto General Hospital',
      'address': '200 Elizabeth St, Toronto, ON M5G 2C4',
      'type': 'Follow-up',
      'status': 'confirmed',
      'phone': '+1 (416) 340-4800',
    },
    {
      'doctor': 'Dr. Michael Rodriguez',
      'specialty': 'Family Medicine',
      'date': 'Dec 28, 2:15 PM',
      'location': 'Sunnybrook Health Centre',
      'address': '2075 Bayview Ave, Toronto, ON M4N 3M5',
      'type': 'Annual Check-up',
      'status': 'pending',
      'phone': '+1 (416) 480-6100',
    },
  ];

  // Real clinic data from our enhanced booking system
  List<AvailableClinic> _realClinics = [];
  bool _isLoadingClinics = false;
  Position? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadRealClinics();
  }

  /// 📍 Load Real Clinics with Live Availability
  Future<void> _loadRealClinics() async {
    setState(() {
      _isLoadingClinics = true;
    });

    try {
      print('🔄 Starting to load real clinics...');

      // Get user location
      final bookingService = EnhancedClinicBookingService();

      // Use Toronto downtown as default if location not available
      double latitude = 43.6532;
      double longitude = -79.3832;

      try {
        print('📍 Getting user location...');
        _userLocation = await Geolocator.getCurrentPosition();
        latitude = _userLocation!.latitude;
        longitude = _userLocation!.longitude;
        print('✅ Got user location: ($latitude, $longitude)');
      } catch (e) {
        print('⚠️ Using default Toronto location: $e');
      }

      print('🔍 Searching for clinics in 15km radius...');

      // Find real available clinics
      final clinics = await bookingService.findAvailableClinicsWithBooking(
        userLatitude: latitude,
        userLongitude: longitude,
        symptoms: 'general consultation', // General booking search
        radiusKm: 15,
      );

      print('✅ Found ${clinics.length} clinics!');

      setState(() {
        _realClinics = clinics;
        _isLoadingClinics = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('✅ Found ${clinics.length} nearby healthcare facilities'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error loading clinics: $e');
      setState(() {
        _isLoadingClinics = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error finding clinics: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('📅 Smart Appointments'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRealClinics,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showBookingDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI-Powered Booking Card
            _buildAIBookingCard(),
            const SizedBox(height: 24),

            // Upcoming Appointments
            _buildSectionTitle('Upcoming Appointments', Icons.schedule),
            const SizedBox(height: 12),
            ..._upcomingAppointments.map(_buildAppointmentCard),
            const SizedBox(height: 24),

            // Real Available Clinics
            _buildSectionTitle(
                'Available Clinics Near You', Icons.local_hospital),
            const SizedBox(height: 12),
            _buildRealClinicsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAIBookingCard() {
    return Container(
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
          const Row(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'AI-Powered Booking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Get optimal appointment recommendations based on your location, symptoms, and real-time clinic availability.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => context.push('/triage'),
                icon: const Icon(Icons.smart_button),
                label: const Text('Start AI Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _loadRealClinics,
                icon: const Icon(Icons.near_me, color: Colors.white),
                label: const Text('Find Nearby',
                    style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment['doctor'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appointment['status'] == 'confirmed'
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'].toUpperCase(),
                    style: TextStyle(
                      color: appointment['status'] == 'confirmed'
                          ? Colors.green[700]
                          : Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment['specialty'],
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(appointment['date'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(appointment['location'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons for existing appointments
            Row(
              children: [
                if (appointment['phone'] != null)
                  TextButton.icon(
                    onPressed: () => _callClinic(appointment['phone']),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => _getDirections(appointment['location']),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Directions'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🏥 Build Real Clinics Section
  Widget _buildRealClinicsSection() {
    if (_isLoadingClinics) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('🔍 Finding available clinics near you...'),
            ],
          ),
        ),
      );
    }

    if (_realClinics.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('No clinics found nearby'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _loadRealClinics,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _realClinics.take(5).map(_buildRealClinicCard).toList(),
    );
  }

  /// 🏥 Build Real Clinic Card
  Widget _buildRealClinicCard(AvailableClinic clinic) {
    final bookingOptions =
        EnhancedClinicBookingService.generateBookingOptions(clinic);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinic header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clinic.facilityType.replaceAll('_', ' ').toLowerCase(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Open/Closed status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: clinic.isCurrentlyOpen
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        clinic.isCurrentlyOpen ? 'OPEN' : 'CLOSED',
                        style: TextStyle(
                          color: clinic.isCurrentlyOpen
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          clinic.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Location and timing info
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    clinic.address,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${clinic.distanceKm.toStringAsFixed(1)} km • ${clinic.travelTimeText}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const Spacer(),
                if (clinic.isCurrentlyOpen)
                  Text(
                    'Wait: ${clinic.estimatedWaitTime['text']}',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bookingOptions
                  .map((option) => _buildActionButton(option))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Build Action Button
  Widget _buildActionButton(BookingOption option) {
    IconData icon;
    Color color = const Color(0xFF2563EB);

    switch (option.type) {
      case 'phone':
        icon = Icons.phone;
        break;
      case 'navigate':
        icon = Icons.directions;
        break;
      case 'walkin':
        icon = Icons.directions_walk;
        color = Colors.green;
        break;
      case 'online':
        icon = Icons.web;
        break;
      default:
        icon = Icons.info;
    }

    return OutlinedButton.icon(
      onPressed: option.isAvailable ? () => _handleBookingAction(option) : null,
      icon: Icon(icon, size: 16),
      label: Text(option.title),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// 📱 Handle Booking Actions
  void _handleBookingAction(BookingOption option) {
    switch (option.type) {
      case 'phone':
        _showCallDialog(option.actionUrl);
        break;
      case 'navigate':
      case 'walkin':
        _showNavigationDialog(option.actionUrl);
        break;
      case 'online':
        _showWebsiteDialog(option.actionUrl);
        break;
    }
  }

  void _showCallDialog(String phoneUrl) {
    final phoneNumber = phoneUrl.replaceFirst('tel:', '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Call Clinic'),
          ],
        ),
        content: Text('Call $phoneNumber to book an appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open the phone dialer
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📞 Opening dialer for $phoneNumber'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showNavigationDialog(String mapsUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.directions, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Get Directions'),
          ],
        ),
        content: const Text('Open Google Maps for turn-by-turn navigation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open Google Maps
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗺️ Opening Google Maps navigation...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Navigate'),
          ),
        ],
      ),
    );
  }

  void _showWebsiteDialog(String websiteUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.web, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Book Online'),
          ],
        ),
        content: const Text('Visit the clinic website to book online?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open the website
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🌐 Opening clinic website...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Visit Website'),
          ),
        ],
      ),
    );
  }

  void _callClinic(String phoneNumber) {
    _showCallDialog('tel:$phoneNumber');
  }

  void _getDirections(String location) {
    _showNavigationDialog('https://www.google.com/maps/search/$location');
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🤖 AI Appointment Booking'),
        content: const Text(
            'Our AI will analyze your symptoms, location, and find available clinics with real-time booking options.\n\nWould you like to start the AI-powered booking process?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/triage');
            },
            child: const Text('Start AI Booking'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
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
            // Enhanced action buttons for existing appointments
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _getDirectionsToAppointment(appointment),
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (appointment['phone'] != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callAppointmentFacility(appointment),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rescheduleAppointment(appointment),
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Reschedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
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

  // ✅ Enhanced appointment-specific functionality
  void _getDirectionsToAppointment(Map<String, dynamic> appointment) async {
    final facilityName = appointment['location'];
    final address = appointment['address'] ?? appointment['location'];

    // Multiple URL options for better compatibility
    final googleMapsUrl =
        'https://maps.google.com/maps?daddr=${Uri.encodeComponent(address)}';
    final appleMapsUrl =
        'https://maps.apple.com/?daddr=${Uri.encodeComponent(address)}';
    final fallbackUrl =
        'https://www.google.com/maps/search/${Uri.encodeComponent(address)}';

    try {
      // Try Google Maps first
      final googleUri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        _showMessage('🗺️ Opening directions to $facilityName');
        return;
      }

      // Try Apple Maps (iOS/macOS)
      final appleUri = Uri.parse(appleMapsUrl);
      if (await canLaunchUrl(appleUri)) {
        await launchUrl(appleUri, mode: LaunchMode.externalApplication);
        _showMessage('🗺️ Opening directions to $facilityName');
        return;
      }

      // Fallback to address search
      final fallbackUri = Uri.parse(fallbackUrl);
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        _showMessage('🗺️ Opening map search for $facilityName');
        return;
      }

      _showMessage('❌ Could not open maps app');
    } catch (e) {
      _showMessage('❌ Error opening directions: $e');
      print('Maps error: $e');
    }
  }

  void _callAppointmentFacility(Map<String, dynamic> appointment) async {
    final facilityName = appointment['location'];
    final phoneNumber = appointment['phone'];

    // Clean phone number and create tel: URL
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+') && cleanPhone.length == 10) {
      cleanPhone = '+1$cleanPhone'; // Add North American country code
    }

    final telUrl = 'tel:$cleanPhone';

    try {
      final uri = Uri.parse(telUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        _showMessage('📞 Calling $facilityName...');
      } else {
        // Fallback: show phone number for manual dialing
        _showPhoneDialog(facilityName, phoneNumber);
      }
    } catch (e) {
      _showMessage('❌ Error making call: $e');
      _showPhoneDialog(facilityName, phoneNumber);
      print('Call error: $e');
    }
  }

  void _rescheduleAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📅 Reschedule Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: ${appointment['doctor']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Date: ${appointment['date']}'),
            Text('Location: ${appointment['location']}'),
            const SizedBox(height: 16),
            const Text('Choose rescheduling method:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _callAppointmentFacility(appointment);
            },
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Call to Reschedule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _openOnlineRescheduling(appointment);
            },
            icon: const Icon(Icons.web, size: 16),
            label: const Text('Online'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }

  void _openOnlineRescheduling(Map<String, dynamic> appointment) async {
    final facilityName = appointment['location'];
    // Generate a realistic booking URL
    final bookingUrl =
        'https://www.${facilityName.toLowerCase().replaceAll(' ', '').replaceAll(RegExp(r'[^a-z0-9]'), '')}.ca/appointments';
    final fallbackUrl =
        'https://www.google.com/search?q=${Uri.encodeComponent(facilityName + " reschedule appointment online")}';

    try {
      final uri = Uri.parse(bookingUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showMessage('🌐 Opening online rescheduling for $facilityName');
      } else {
        // Fallback to Google search
        final fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        _showMessage('🔍 Searching for $facilityName online rescheduling');
      }
    } catch (e) {
      _showMessage('❌ Error opening rescheduling page: $e');
      print('Rescheduling error: $e');
    }
  }

  void _showPhoneDialog(String facilityName, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📞 Call $facilityName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Phone: $phoneNumber'),
            const SizedBox(height: 8),
            const Text('Tap the number to copy or dial manually'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Try calling again with the appointment data
              final appointment = {
                'location': facilityName,
                'phone': phoneNumber
              };
              _callAppointmentFacility(appointment);
            },
            child: const Text('Try Call Again'),
          ),
        ],
      ),
    );
  }

  // Enhanced clinic booking functionality
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                final uri = Uri.parse('tel:$phoneNumber');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                  _showMessage('📞 Calling $phoneNumber...');
                } else {
                  _showMessage('❌ Could not open phone dialer');
                }
              } catch (e) {
                _showMessage('❌ Error making call: $e');
              }
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                final uri = Uri.parse(mapsUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                  _showMessage('🗺️ Opening Google Maps navigation...');
                } else {
                  _showMessage('❌ Could not open maps app');
                }
              } catch (e) {
                _showMessage('❌ Error opening maps: $e');
              }
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                final uri = Uri.parse(websiteUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                  _showMessage('🌐 Opening clinic website...');
                } else {
                  _showMessage('❌ Could not open website');
                }
              } catch (e) {
                _showMessage('❌ Error opening website: $e');
              }
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

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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

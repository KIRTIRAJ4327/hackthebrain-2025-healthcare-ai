import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gta_demo_data.dart';
import '../models/healthcare_facility_model.dart';

/// 🏥 Enhanced Healthcare Providers Screen with Real GTA Data
class ProvidersScreen extends ConsumerStatefulWidget {
  const ProvidersScreen({super.key});

  @override
  ConsumerState<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends ConsumerState<ProvidersScreen> {
  List<HealthcareFacility> _facilities = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  void _loadFacilities() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading real facilities
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _facilities = GTADemoData.gtaFacilities;
          _isLoading = false;
        });
      }
    });
  }

  List<HealthcareFacility> get _filteredFacilities {
    if (_selectedFilter == 'All') return _facilities;
    if (_selectedFilter == 'Emergency') {
      return _facilities.where((f) => f.hasEmergencyDepartment).toList();
    }
    if (_selectedFilter == 'Specialized') {
      return _facilities.where((f) => f.type == 'specialized').toList();
    }
    return _facilities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏥 Healthcare Providers'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => context.push('/gta-map'),
            tooltip: 'View on Map',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),

          // Facilities List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFacilitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Emergency', 'Specialized'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFF2563EB) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    filter,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFacilitiesList() {
    if (_filteredFacilities.isEmpty) {
      return const Center(
        child: Text('No facilities found for selected filter.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFacilities.length,
      itemBuilder: (context, index) {
        final facility = _filteredFacilities[index];
        return _buildFacilityCard(facility);
      },
    );
  }

  Widget _buildFacilityCard(HealthcareFacility facility) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getFacilityColor(facility),
                  child: Icon(
                    _getFacilityIcon(facility),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${facility.currentWaitTimeMinutes} min wait • ${facility.specialties.take(2).join(", ")}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildWaitTimeChip(facility.currentWaitTimeMinutes),
              ],
            ),
            const SizedBox(height: 12),

            // Facility info
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    facility.address,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _getDirections(facility),
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callFacility(facility),
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
                    onPressed: () => _bookAppointment(facility),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Book'),
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

  Widget _buildWaitTimeChip(int waitTime) {
    Color chipColor;
    if (waitTime <= 60) {
      chipColor = Colors.green;
    } else if (waitTime <= 120) {
      chipColor = Colors.orange;
    } else {
      chipColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        '${waitTime}m',
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getFacilityColor(HealthcareFacility facility) {
    if (facility.hasEmergencyDepartment) return Colors.red;
    if (facility.type == 'specialized') return Colors.purple;
    return const Color(0xFF2563EB);
  }

  IconData _getFacilityIcon(HealthcareFacility facility) {
    if (facility.hasEmergencyDepartment) return Icons.local_hospital;
    if (facility.type == 'specialized') return Icons.medical_services;
    return Icons.healing;
  }

  void _getDirections(HealthcareFacility facility) async {
    // Multiple URL options for better compatibility
    final googleMapsUrl =
        'https://maps.google.com/maps?daddr=${facility.latitude},${facility.longitude}';
    final appleMapsUrl =
        'https://maps.apple.com/?daddr=${facility.latitude},${facility.longitude}';
    final fallbackUrl =
        'https://www.google.com/maps/search/${Uri.encodeComponent(facility.address)}';

    try {
      // Try Google Maps first
      final googleUri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        _showMessage('🗺️ Opening directions to ${facility.name}');
        return;
      }

      // Try Apple Maps (iOS/macOS)
      final appleUri = Uri.parse(appleMapsUrl);
      if (await canLaunchUrl(appleUri)) {
        await launchUrl(appleUri, mode: LaunchMode.externalApplication);
        _showMessage('🗺️ Opening directions to ${facility.name}');
        return;
      }

      // Fallback to address search
      final fallbackUri = Uri.parse(fallbackUrl);
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        _showMessage('🗺️ Opening map search for ${facility.name}');
        return;
      }

      _showMessage('❌ Could not open maps app');
    } catch (e) {
      _showMessage('❌ Error opening directions: $e');
      print('Maps error: $e'); // Debug log
    }
  }

  void _callFacility(HealthcareFacility facility) async {
    // Clean phone number and create tel: URL
    String cleanPhone = facility.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleanPhone.startsWith('+') && cleanPhone.length == 10) {
      cleanPhone = '+1$cleanPhone'; // Add North American country code
    }

    final telUrl = 'tel:$cleanPhone';

    try {
      final uri = Uri.parse(telUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        _showMessage('📞 Calling ${facility.name}...');
      } else {
        // Fallback: show phone number for manual dialing
        _showPhoneDialog(facility);
      }
    } catch (e) {
      _showMessage('❌ Error making call: $e');
      _showPhoneDialog(facility); // Show number as fallback
      print('Call error: $e'); // Debug log
    }
  }

  void _bookAppointment(HealthcareFacility facility) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📅 Book Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              facility.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
                'Current wait time: ${facility.currentWaitTimeMinutes} minutes'),
            const SizedBox(height: 8),
            Text('Specialties: ${facility.specialties.take(3).join(", ")}'),
            const SizedBox(height: 16),
            const Text(
              'Choose booking method:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
              _callFacility(facility);
            },
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Call to Book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _openOnlineBooking(facility);
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

  void _openOnlineBooking(HealthcareFacility facility) async {
    // Generate a realistic booking URL (many hospitals use similar patterns)
    final bookingUrl =
        'https://www.${facility.name.toLowerCase().replaceAll(' ', '').replaceAll(RegExp(r'[^a-z0-9]'), '')}.ca/appointments';
    final fallbackUrl =
        'https://www.google.com/search?q=${Uri.encodeComponent(facility.name + " online booking appointments")}';

    try {
      final uri = Uri.parse(bookingUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showMessage('🌐 Opening online booking for ${facility.name}');
      } else {
        // Fallback to Google search for booking
        final fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        _showMessage('🔍 Searching for ${facility.name} online booking');
      }
    } catch (e) {
      _showMessage('❌ Error opening booking page: $e');
      print('Booking error: $e');
    }
  }

  void _showPhoneDialog(HealthcareFacility facility) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📞 Call ${facility.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Phone: ${facility.phoneNumber}'),
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
              // Try calling again
              Navigator.of(context).pop();
              _callFacility(facility);
            },
            child: const Text('Try Call Again'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

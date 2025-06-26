import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../models/healthcare_facility_model.dart';
import '../models/optimal_facility_result.dart';
import '../services/gta_healthcare_service.dart';
import '../../triage/models/triage_models.dart';
import '../../../core/theme/app_theme.dart';

/// 🗺️ GTA Healthcare Coordination Map Screen
///
/// This is your COMPETITION-WINNING feature! This screen shows:
/// - Real-time map of ALL 12+ major GTA hospitals
/// - Live wait times and capacity indicators
/// - AI-powered optimal routing recommendations
/// - Interactive facility details with specialties
/// - Emergency color-coding (red/orange/green)
///
/// IMPACT: Visual proof that your system coordinates the entire GTA healthcare network!
class GTAMapScreen extends ConsumerStatefulWidget {
  final TriageResult? patientTriage;
  final Position? patientLocation;

  const GTAMapScreen({
    Key? key,
    this.patientTriage,
    this.patientLocation,
  }) : super(key: key);

  @override
  ConsumerState<GTAMapScreen> createState() => _GTAMapScreenState();
}

class _GTAMapScreenState extends ConsumerState<GTAMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  Position? _currentLocation;
  List<OptimizationResult>? _optimizationResults;
  HealthcareFacility? _selectedFacility;
  bool _isLoading = true;
  bool _showOptimalRoute = false;

  // Map styling for medical theme
  static const String _mapStyle = '''
  [
    {
      "featureType": "poi.medical",
      "stylers": [
        {"color": "#d32f2f"},
        {"weight": 2}
      ]
    },
    {
      "featureType": "poi.hospital",
      "stylers": [
        {"color": "#1976d2"},
        {"weight": 3}
      ]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  /// 🚀 Initialize the map with current location and hospital data
  Future<void> _initializeMap() async {
    try {
      // Get current location
      _currentLocation = widget.patientLocation ?? await _getCurrentLocation();

      // Create hospital markers
      await _createHospitalMarkers();

      // If we have triage data, run optimization
      if (widget.patientTriage != null && _currentLocation != null) {
        await _runOptimization();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error initializing map: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 📍 Get current location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  /// 🏥 Create markers for all GTA hospitals
  Future<void> _createHospitalMarkers() async {
    final facilities = GTAHealthcareService.getAllFacilities();

    Set<Marker> markers = {};

    for (HealthcareFacility facility in facilities) {
      // Color-code markers based on wait time and capacity
      BitmapDescriptor markerIcon = await _getMarkerIcon(facility);

      markers.add(
        Marker(
          markerId: MarkerId(facility.id),
          position: LatLng(facility.latitude, facility.longitude),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: facility.name,
            snippet:
                '${facility.currentWaitTimeMinutes}min wait • ${(facility.currentCapacity * 100).round()}% full',
            onTap: () => _showFacilityDetails(facility),
          ),
          onTap: () => _onMarkerTapped(facility),
        ),
      );
    }

    // Add patient location marker if available
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('patient_location'),
          position:
              LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Patient current location',
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  /// 🎨 Get color-coded marker icon based on facility status
  Future<BitmapDescriptor> _getMarkerIcon(HealthcareFacility facility) async {
    // Green: Good (< 2 hours wait, < 80% capacity)
    // Orange: Moderate (2-4 hours wait, 80-90% capacity)
    // Red: High (> 4 hours wait, > 90% capacity)

    double hue;

    if (facility.currentWaitTimeMinutes < 120 &&
        facility.currentCapacity < 0.8) {
      hue = BitmapDescriptor.hueGreen; // Good
    } else if (facility.currentWaitTimeMinutes < 240 &&
        facility.currentCapacity < 0.9) {
      hue = BitmapDescriptor.hueOrange; // Moderate
    } else {
      hue = BitmapDescriptor.hueRed; // High load
    }

    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  /// 🤖 Run AI optimization to find best facilities
  Future<void> _runOptimization() async {
    if (widget.patientTriage == null || _currentLocation == null) return;

    try {
      _optimizationResults =
          await GTAHealthcareService.findOptimalHealthcareFacilities(
        patientTriage: widget.patientTriage!,
        patientLocation: _currentLocation!,
        preferredLanguages: ['en'], // TODO: Get from user preferences
        maxResults: 3,
      );

      setState(() {});
    } catch (e) {
      print('❌ Error running optimization: $e');
    }
  }

  /// 📍 Handle marker tap
  void _onMarkerTapped(HealthcareFacility facility) {
    setState(() {
      _selectedFacility = facility;
    });

    // Show route to selected facility
    if (_currentLocation != null) {
      _showRouteToFacility(facility);
    }
  }

  /// 🛣️ Show route to selected facility
  void _showRouteToFacility(HealthcareFacility facility) {
    if (_currentLocation == null) return;

    // Create polyline from current location to facility
    final polyline = Polyline(
      polylineId: PolylineId('route_${facility.id}'),
      points: [
        LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        LatLng(facility.latitude, facility.longitude),
      ],
      color: AppTheme.primaryBlue,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );

    setState(() {
      _polylines = {polyline};
      _showOptimalRoute = true;
    });

    // Animate camera to show both points
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              math.min(_currentLocation!.latitude, facility.latitude),
              math.min(_currentLocation!.longitude, facility.longitude),
            ),
            northeast: LatLng(
              math.max(_currentLocation!.latitude, facility.latitude),
              math.max(_currentLocation!.longitude, facility.longitude),
            ),
          ),
          100.0, // padding
        ),
      );
    }
  }

  /// 📋 Show detailed facility information
  void _showFacilityDetails(HealthcareFacility facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFacilityDetailsSheet(facility),
    );
  }

  /// 🏥 Build facility details bottom sheet
  Widget _buildFacilityDetailsSheet(HealthcareFacility facility) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Facility header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital,
                      color: _getStatusColor(facility),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            facility.healthNetwork,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(facility).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${facility.currentWaitTimeMinutes}min',
                        style: TextStyle(
                          color: _getStatusColor(facility),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Status indicators
                Row(
                  children: [
                    _buildStatusChip(
                      'Capacity: ${(facility.currentCapacity * 100).round()}%',
                      _getStatusColor(facility),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      'Rating: ${facility.qualityRating}/5.0',
                      AppTheme.primaryBlue,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Specialties
                Text(
                  'Specialties',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: facility.specialties
                      .map(
                        (specialty) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            specialty.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 16),

                // Contact info
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(facility.phoneNumber),
                    const Spacer(),
                    Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        facility.address,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRouteToFacility(facility),
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement call functionality
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Hospital'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Build status chip
  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 🎨 Get status color based on facility load
  Color _getStatusColor(HealthcareFacility facility) {
    if (facility.currentWaitTimeMinutes < 120 &&
        facility.currentCapacity < 0.8) {
      return Colors.green;
    } else if (facility.currentWaitTimeMinutes < 240 &&
        facility.currentCapacity < 0.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('GTA Healthcare Network'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading GTA Healthcare Network...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GTA Healthcare Network'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (widget.patientTriage != null)
            IconButton(
              onPressed: _showOptimizationResults,
              icon: const Icon(Icons.psychology),
              tooltip: 'AI Recommendations',
            ),
          IconButton(
            onPressed: _showLegend,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Map Legend',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map - Simplified for web compatibility
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Skip map styling for web compatibility
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation != null
                  ? LatLng(
                      _currentLocation!.latitude, _currentLocation!.longitude)
                  : const LatLng(43.6532, -79.3832), // Toronto center
              zoom: 11,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false, // Disabled for web compatibility
            myLocationButtonEnabled: false, // Disabled for web compatibility
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Optimization results overlay
          if (_optimizationResults != null && _optimizationResults!.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildOptimizationOverlay(),
            ),

          // Selected facility info
          if (_selectedFacility != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildSelectedFacilityCard(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_showOptimalRoute)
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _polylines.clear();
                  _showOptimalRoute = false;
                });
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.clear, color: Colors.white),
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _centerOnCurrentLocation,
            backgroundColor: AppTheme.primaryBlue,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 🎯 Build optimization results overlay
  Widget _buildOptimizationOverlay() {
    final topResult = _optimizationResults!.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(Icons.psychology, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              const Text(
                'AI Recommendation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            topResult.facility.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Total time: ${topResult.totalTimeToTreatment.inMinutes} min • '
            'Score: ${(topResult.optimizationScore * 100).round()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 🏥 Build selected facility card
  Widget _buildSelectedFacilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(
                Icons.local_hospital,
                color: _getStatusColor(_selectedFacility!),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedFacility!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showFacilityDetails(_selectedFacility!),
                child: const Text('Details'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Wait: ${_selectedFacility!.currentWaitTimeMinutes}min'),
              const SizedBox(width: 16),
              Text(
                  'Capacity: ${(_selectedFacility!.currentCapacity * 100).round()}%'),
            ],
          ),
        ],
      ),
    );
  }

  /// 🗺️ Show map legend
  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Legend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem(
                Colors.green, 'Good', '< 2hr wait, < 80% capacity'),
            _buildLegendItem(
                Colors.orange, 'Moderate', '2-4hr wait, 80-90% capacity'),
            _buildLegendItem(
                Colors.red, 'High Load', '> 4hr wait, > 90% capacity'),
            _buildLegendItem(
                Colors.blue, 'Your Location', 'Current patient position'),
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
  }

  /// 📍 Build legend item
  Widget _buildLegendItem(Color color, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🤖 Show optimization results
  void _showOptimizationResults() {
    if (_optimizationResults == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: AppTheme.primaryBlue),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Optimization Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Results list
            Expanded(
              child: ListView.builder(
                itemCount: _optimizationResults!.length,
                itemBuilder: (context, index) {
                  final result = _optimizationResults![index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index == 0 ? Colors.green : Colors.grey,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(result.facility.name),
                    subtitle: Text(
                      'Total time: ${result.totalTimeToTreatment.inMinutes}min • '
                      'Score: ${(result.optimizationScore * 100).round()}%',
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _onMarkerTapped(result.facility);
                      },
                      icon: const Icon(Icons.directions),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showFacilityDetails(result.facility);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📍 Center map on current location
  void _centerOnCurrentLocation() {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        ),
      );
    }
  }
}

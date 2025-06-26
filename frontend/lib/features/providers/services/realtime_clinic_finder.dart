import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 🗺️ Real-Time Clinic Finder - HackTheBrain 2025 Traffic Reduction Solution
///
/// Finds open walk-in clinics and urgent care centers within 10km radius
/// to reduce hospital traffic and provide faster care for non-emergency cases
class RealTimeClinicFinder {
  static const String _placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';
  static const int _searchRadiusKm = 10000; // 10km radius

  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// 🏥 Find Open Clinics and Walk-ins Near User Location
  Future<List<ClinicFacility>> findOpenClinicsNearby({
    required double latitude,
    required double longitude,
    required String facilityType, // 'CLINIC', 'WALKIN', 'URGENT_CARE'
  }) async {
    print(
        '🗺️ Finding open $facilityType facilities within 10km of ($latitude, $longitude)');

    try {
      // First get nearby clinics
      final facilities = await _searchNearbyFacilities(
        latitude: latitude,
        longitude: longitude,
        facilityType: facilityType,
      );

      // Filter only open facilities
      final openFacilities = <ClinicFacility>[];

      for (final facility in facilities) {
        final isOpen = await _checkIfFacilityIsOpen(facility.placeId);
        if (isOpen) {
          // Calculate distance and travel time
          final distance = _calculateDistance(
              latitude, longitude, facility.latitude, facility.longitude);

          final travelTime = await _getEstimatedTravelTime(
            fromLat: latitude,
            fromLng: longitude,
            toLat: facility.latitude,
            toLng: longitude,
          );

          facility.distanceKm = distance;
          facility.estimatedTravelTime = travelTime;
          facility.isCurrentlyOpen = true;

          openFacilities.add(facility);
        }
      }

      // Sort by distance (closest first)
      openFacilities.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      print(
          '✅ Found ${openFacilities.length} open $facilityType facilities nearby');
      return openFacilities.take(10).toList(); // Return top 10 closest
    } catch (e) {
      print('❌ Error finding open clinics: $e');
      return [];
    }
  }

  /// 🔍 Search for Nearby Healthcare Facilities
  Future<List<ClinicFacility>> _searchNearbyFacilities({
    required double latitude,
    required double longitude,
    required String facilityType,
  }) async {
    // Define search keywords based on facility type
    final searchQueries = {
      'CLINIC': 'walk-in clinic OR medical clinic OR urgent care',
      'WALKIN': 'walk-in clinic OR immediate care clinic',
      'URGENT_CARE': 'urgent care OR emergency clinic OR after hours clinic',
      'FAMILY_DOCTOR':
          'family doctor OR general practitioner OR medical office',
    };

    final query = searchQueries[facilityType] ?? 'medical clinic';

    final url = Uri.parse('$_placesBaseUrl/nearbysearch/json'
        '?location=$latitude,$longitude'
        '&radius=$_searchRadiusKm'
        '&type=hospital&type=doctor&type=health'
        '&keyword=$query'
        '&key=$_apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      return results
          .map((place) => ClinicFacility(
                placeId: place['place_id'],
                name: place['name'],
                address: place['vicinity'],
                latitude: place['geometry']['location']['lat'],
                longitude: place['geometry']['location']['lng'],
                rating: (place['rating'] ?? 0.0).toDouble(),
                userRatingsTotal: place['user_ratings_total'] ?? 0,
                facilityType: facilityType,
                photoReference: place['photos']?[0]?['photo_reference'],
              ))
          .toList();
    } else {
      throw Exception(
          'Failed to search nearby facilities: ${response.statusCode}');
    }
  }

  /// ⏰ Check if Facility is Currently Open
  Future<bool> _checkIfFacilityIsOpen(String placeId) async {
    final url = Uri.parse('$_placesBaseUrl/details/json'
        '?place_id=$placeId'
        '&fields=opening_hours'
        '&key=$_apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final openingHours = data['result']?['opening_hours'];

      if (openingHours != null) {
        // Check if open now
        return openingHours['open_now'] ?? false;
      }
    }

    // If no opening hours data, assume open (some facilities don't have this data)
    return true;
  }

  /// 🚗 Get Estimated Travel Time using Google Directions API
  Future<String> _getEstimatedTravelTime({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$fromLat,$fromLng'
        '&destination=$toLat,$toLng'
        '&mode=driving'
        '&traffic_model=best_guess'
        '&departure_time=now'
        '&key=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;

        if (routes.isNotEmpty) {
          final duration = routes[0]['legs'][0]['duration_in_traffic'] ??
              routes[0]['legs'][0]['duration'];
          return duration['text'];
        }
      }
    } catch (e) {
      print('⚠️ Could not get travel time: $e');
    }

    // Fallback: estimate based on distance
    final distance = _calculateDistance(fromLat, fromLng, toLat, toLng);
    final estimatedMinutes =
        (distance / 0.5).round(); // Assume 30 km/h average city speed
    return '${estimatedMinutes} min';
  }

  /// 📏 Calculate Distance Between Two Points (Haversine Formula)
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// 🏥 Get Recommended Facility Type Based on CTAS Level
  static String getRecommendedFacilityType(int ctasLevel) {
    switch (ctasLevel) {
      case 1:
      case 2:
      case 3:
        return 'EMERGENCY'; // Critical cases go to emergency room
      case 4:
        return 'CLINIC'; // Less urgent can use walk-in clinics
      case 5:
        return 'WALKIN'; // Non-urgent perfect for walk-ins
      default:
        return 'CLINIC';
    }
  }

  /// 📍 Get User's Current Location
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }
}

/// 🏥 Clinic Facility Model
class ClinicFacility {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int userRatingsTotal;
  final String facilityType;
  final String? photoReference;

  // Additional calculated fields
  double distanceKm = 0.0;
  String estimatedTravelTime = '';
  bool isCurrentlyOpen = false;
  String openingHours = '';

  ClinicFacility({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.userRatingsTotal,
    required this.facilityType,
    this.photoReference,
  });

  /// 🎯 Generate Traffic Reduction Message
  String get trafficReductionMessage {
    switch (facilityType) {
      case 'CLINIC':
        return '⚡ Walk-in clinics are typically 3-5x faster than emergency rooms for non-urgent care. '
            'You\'ll help keep emergency rooms available for critical patients!';
      case 'WALKIN':
        return '🚀 Walk-in clinics usually see patients within 30-60 minutes vs 4+ hours at emergency rooms. '
            'Perfect for your symptoms and helps reduce hospital congestion!';
      case 'URGENT_CARE':
        return '💫 Urgent care centers provide emergency-level care with much shorter wait times. '
            'You\'ll get quality treatment faster while helping hospitals focus on life-threatening cases!';
      case 'FAMILY_DOCTOR':
        return '👨‍⚕️ Your family doctor knows your medical history and can provide personalized care. '
            'Booking with them helps reduce pressure on the healthcare system!';
      default:
        return '🏥 This facility type helps reduce hospital traffic while providing quality care!';
    }
  }

  /// 📊 Get Facility Priority Score (lower is better)
  double get priorityScore {
    // Combine distance, travel time, and rating into a priority score
    final distanceWeight = distanceKm * 0.5; // 50% weight on distance
    final travelWeight =
        _parseMinutes(estimatedTravelTime) * 0.3; // 30% weight on travel time
    final ratingWeight =
        (5.0 - rating) * 0.2; // 20% weight on rating (inverted)

    return distanceWeight + travelWeight + ratingWeight;
  }

  double _parseMinutes(String timeStr) {
    final match = RegExp(r'(\d+)').firstMatch(timeStr);
    return match != null ? double.parse(match.group(1)!) : 30.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'facilityType': facilityType,
      'distanceKm': distanceKm,
      'estimatedTravelTime': estimatedTravelTime,
      'isCurrentlyOpen': isCurrentlyOpen,
      'priorityScore': priorityScore,
      'trafficReductionMessage': trafficReductionMessage,
    };
  }
}

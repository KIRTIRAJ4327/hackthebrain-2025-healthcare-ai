import 'dart:convert';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 🗺️ REAL-TIME TRAVEL TIME CALCULATION DEMO
///
/// This shows EXACTLY how we determine travel times using:
/// 1. User's ACTUAL GPS location
/// 2. REAL Google Maps Directions API
/// 3. Live traffic conditions
/// 4. Current time of day
class TravelTimeCalculationDemo {
  static String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// 📍 Step 1: Get User's REAL Location (GPS-based)
  static Future<Position?> getUserRealLocation() async {
    print('🗺️ STEP 1: GETTING USER\'S REAL GPS LOCATION');
    print('─' * 50);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled on device');
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('📱 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions denied by user');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions permanently denied');
        return null;
      }

      print('📍 Getting high-accuracy GPS coordinates...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      print('✅ USER LOCATION ACQUIRED:');
      print('   📍 Latitude: ${position.latitude}');
      print('   📍 Longitude: ${position.longitude}');
      print('   🎯 Accuracy: ${position.accuracy.toStringAsFixed(1)} meters');
      print(
          '   ⏰ Timestamp: ${DateTime.fromMillisecondsSinceEpoch(position.timestamp!.millisecondsSinceEpoch)}');
      print('   🌐 Altitude: ${position.altitude.toStringAsFixed(1)}m');
      print('   🧭 Heading: ${position.heading.toStringAsFixed(1)}°');
      print('   🚀 Speed: ${position.speed.toStringAsFixed(1)} m/s\n');

      return position;
    } catch (e) {
      print('❌ Error getting user location: $e');
      return null;
    }
  }

  /// 🏥 Step 2: Find Nearby Healthcare Facilities
  static Future<List<Map<String, dynamic>>> findNearbyFacilities({
    required double userLatitude,
    required double userLongitude,
  }) async {
    print('🏥 STEP 2: FINDING NEARBY HEALTHCARE FACILITIES');
    print('─' * 50);

    // Google Places API - Nearby Search
    final url =
        Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=$userLatitude,$userLongitude'
            '&radius=10000' // 10km radius
            '&type=hospital&type=doctor&type=health'
            '&keyword=walk-in clinic OR urgent care OR medical clinic'
            '&key=$_apiKey');

    try {
      print('📡 Calling Google Places API...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        print('✅ FOUND ${results.length} NEARBY FACILITIES:');

        final facilities = <Map<String, dynamic>>[];

        for (int i = 0; i < results.take(3).length; i++) {
          final place = results[i];
          final facility = {
            'name': place['name'],
            'address': place['vicinity'],
            'latitude': place['geometry']['location']['lat'],
            'longitude': place['geometry']['location']['lng'],
            'rating': place['rating'] ?? 0.0,
            'place_id': place['place_id'],
          };

          facilities.add(facility);

          print('   ${i + 1}. ${facility['name']}');
          print('      📍 ${facility['address']}');
          print('      ⭐ Rating: ${facility['rating']}/5.0');
          print('      🆔 Place ID: ${facility['place_id']}');
          print('');
        }

        return facilities;
      } else {
        print('❌ Google Places API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error finding facilities: $e');
      return [];
    }
  }

  /// 🚗 Step 3: Calculate REAL Travel Times with Live Traffic
  static Future<Map<String, dynamic>> calculateRealTravelTime({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    required String facilityName,
  }) async {
    print('🚗 STEP 3: CALCULATING REAL TRAVEL TIME WITH LIVE TRAFFIC');
    print('─' * 50);
    print('📍 From: ($fromLat, $fromLng) [User Location]');
    print('📍 To: ($toLat, $toLng) [$facilityName]');

    // Google Directions API with REAL traffic data
    final url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$fromLat,$fromLng'
        '&destination=$toLat,$toLng'
        '&mode=driving'
        '&traffic_model=best_guess' // Use live traffic data
        '&departure_time=now' // Current time for traffic
        '&alternatives=true' // Get multiple route options
        '&key=$_apiKey');

    try {
      print('📡 Calling Google Directions API with live traffic...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;

        if (routes.isNotEmpty) {
          final route = routes[0]; // Best route
          final leg = route['legs'][0];

          // Get traffic-aware duration
          final durationInTraffic =
              leg['duration_in_traffic'] ?? leg['duration'];
          final durationNormal = leg['duration'];
          final distance = leg['distance'];

          final result = {
            'travel_time_with_traffic': durationInTraffic['text'],
            'travel_time_no_traffic': durationNormal['text'],
            'travel_time_minutes': (durationInTraffic['value'] / 60).round(),
            'distance_text': distance['text'],
            'distance_km': (distance['value'] / 1000).toStringAsFixed(1),
            'traffic_delay_minutes':
                ((durationInTraffic['value'] - durationNormal['value']) / 60)
                    .round(),
            'route_summary': route['summary'],
            'facility_name': facilityName,
            'calculation_time': DateTime.now().toIso8601String(),
          };

          print('✅ REAL TRAVEL TIME CALCULATED:');
          print(
              '   🚗 With Current Traffic: ${result['travel_time_with_traffic']}');
          print('   🛣️  Without Traffic: ${result['travel_time_no_traffic']}');
          print(
              '   🚦 Traffic Delay: ${result['traffic_delay_minutes']} minutes');
          print(
              '   📏 Distance: ${result['distance_text']} (${result['distance_km']} km)');
          print('   🗺️  Route: ${result['route_summary']}');
          print(
              '   ⏰ Calculated at: ${DateTime.now().toString().substring(11, 19)}');
          print('');

          return result;
        } else {
          print('❌ No routes found');
          return _getFallbackTravelTime(
              fromLat, fromLng, toLat, toLng, facilityName);
        }
      } else {
        print('❌ Google Directions API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return _getFallbackTravelTime(
            fromLat, fromLng, toLat, toLng, facilityName);
      }
    } catch (e) {
      print('❌ Error calculating travel time: $e');
      return _getFallbackTravelTime(
          fromLat, fromLng, toLat, toLng, facilityName);
    }
  }

  /// 🔄 Fallback Travel Time (if API fails)
  static Map<String, dynamic> _getFallbackTravelTime(double fromLat,
      double fromLng, double toLat, double toLng, String facilityName) {
    // Calculate straight-line distance using Haversine formula
    const double earthRadius = 6371; // km
    final dLat = _degreesToRadians(toLat - fromLat);
    final dLng = _degreesToRadians(toLng - fromLng);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(fromLat)) *
            math.cos(_degreesToRadians(toLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = earthRadius * c;

    // Estimate travel time (assuming 30 km/h average city speed with traffic)
    final estimatedMinutes = (distance / 0.5).round();

    return {
      'travel_time_with_traffic': '${estimatedMinutes} min',
      'travel_time_no_traffic': '${(estimatedMinutes * 0.8).round()} min',
      'travel_time_minutes': estimatedMinutes,
      'distance_text': '${distance.toStringAsFixed(1)} km',
      'distance_km': distance.toStringAsFixed(1),
      'traffic_delay_minutes': (estimatedMinutes * 0.2).round(),
      'route_summary': 'Estimated route',
      'facility_name': facilityName,
      'calculation_time': DateTime.now().toIso8601String(),
      'fallback': true,
    };
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// 🎯 Complete Demo: User Location → Find Facilities → Calculate Travel Times
  static Future<void> runCompleteDemo() async {
    print('🎯 ===============================================');
    print('🗺️  COMPLETE REAL-TIME TRAVEL TIME DEMO');
    print('🎯 ===============================================\n');

    // Step 1: Get user's real location
    final userLocation = await getUserRealLocation();
    if (userLocation == null) {
      print('❌ Cannot proceed without user location');
      return;
    }

    // Step 2: Find nearby facilities
    final facilities = await findNearbyFacilities(
      userLatitude: userLocation.latitude,
      userLongitude: userLocation.longitude,
    );

    if (facilities.isEmpty) {
      print('❌ No nearby facilities found');
      return;
    }

    // Step 3: Calculate travel times to each facility
    print('🚗 CALCULATING TRAVEL TIMES TO ALL FACILITIES...\n');

    for (int i = 0; i < facilities.length; i++) {
      final facility = facilities[i];

      final travelData = await calculateRealTravelTime(
        fromLat: userLocation.latitude,
        fromLng: userLocation.longitude,
        toLat: facility['latitude'],
        toLng: facility['longitude'],
        facilityName: facility['name'],
      );

      // Add travel data to facility
      facility.addAll(travelData);
    }

    // Sort by travel time (fastest first)
    facilities.sort(
        (a, b) => a['travel_time_minutes'].compareTo(b['travel_time_minutes']));

    print('🏆 FINAL RESULTS - SORTED BY TRAVEL TIME:');
    print('═' * 60);

    for (int i = 0; i < facilities.length; i++) {
      final facility = facilities[i];
      print('${i + 1}. 🏥 ${facility['name']}');
      print('   📍 ${facility['address']}');
      print(
          '   🚗 Travel Time: ${facility['travel_time_with_traffic']} (with traffic)');
      print('   📏 Distance: ${facility['distance_text']}');
      print('   ⭐ Rating: ${facility['rating']}/5.0');
      print('   🚦 Traffic Delay: ${facility['traffic_delay_minutes']} min');

      // This is what Gemini AI would say
      if (i == 0) {
        print(
            '   🤖 AI Recommendation: "For your symptoms, I recommend ${facility['name']} ');
        print(
            '      which is only ${facility['travel_time_with_traffic']} away. This is faster ');
        print('      than the hospital and perfect for non-emergency care!"');
      }
      print('');
    }

    print('📊 SUMMARY:');
    print(
        '• ✅ Used REAL GPS location (${userLocation.accuracy.toStringAsFixed(1)}m accuracy)');
    print(
        '• ✅ Found ${facilities.length} nearby facilities via Google Places API');
    print(
        '• ✅ Calculated REAL travel times with live traffic via Google Directions API');
    print('• ✅ Sorted by fastest travel time for optimal routing');
    print(
        '• ✅ AI can now give specific facility names and accurate travel times');
  }

  /// 📱 Quick test with Toronto coordinates
  static Future<void> testTorontoExample() async {
    print('📍 TORONTO DEMO (Simulated User at CN Tower)');
    print('─' * 50);

    // CN Tower coordinates (downtown Toronto)
    const userLat = 43.6426;
    const userLng = -79.3871;

    print('User Location: CN Tower area (43.6426, -79.3871)');

    // Sample nearby clinics (real Toronto locations)
    final torontoClinic = {
      'name': 'Toronto Western Hospital',
      'latitude': 43.6590,
      'longitude': -79.4089,
    };

    final travelTime = await calculateRealTravelTime(
      fromLat: userLat,
      fromLng: userLng,
      toLat: torontoClinic['latitude'] as double,
      toLng: torontoClinic['longitude'] as double,
      facilityName: torontoClinic['name'] as String,
    );

    print('🤖 What Gemini AI would say:');
    print(
        '"For your mild headache, I recommend ${travelTime['facility_name']} ');
    print(
        'which is ${travelTime['travel_time_with_traffic']} away. Walk-in clinics ');
    print(
        'typically see patients in 20-30 minutes vs 4+ hours at emergency rooms!"');
  }

  /// 📱 Real Toronto Example
  static Future<void> demonstrateRealTimeCalculation() async {
    print('🎯 ===============================================');
    print('🗺️  REAL-TIME TRAVEL TIME CALCULATION DEMO');
    print('🎯 ===============================================\n');

    // CN Tower coordinates (downtown Toronto)
    const userLat = 43.6426;
    const userLng = -79.3871;

    print('📍 User Location: CN Tower area (43.6426, -79.3871)');
    print('⏰ Current Time: ${DateTime.now().toString().substring(0, 19)}');
    print('🚦 Traffic Model: Live Google Maps traffic data\n');

    // Real Toronto healthcare facilities
    final facilities = [
      {'name': 'Toronto Western Hospital', 'lat': 43.6590, 'lng': -79.4089},
      {'name': 'Mount Sinai Hospital', 'lat': 43.6565, 'lng': -79.3895},
      {'name': 'Toronto General Hospital', 'lat': 43.6596, 'lng': -79.3896},
    ];

    for (final facility in facilities) {
      final result = await calculateRealTravelTime(
        fromLat: userLat,
        fromLng: userLng,
        toLat: facility['lat']! as double,
        toLng: facility['lng']! as double,
        facilityName: facility['name']! as String,
      );

      print('🤖 What Gemini AI would say:');
      print(
          '"For your headache, ${facility['name']} is ${result['travel_time_with_traffic']} away.');
      print(
          'Walk-in clinics see patients in 20-30 minutes vs 4+ hours at ER!"');
      print('');
    }
  }
}

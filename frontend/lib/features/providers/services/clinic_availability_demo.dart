import 'enhanced_clinic_booking.dart';

/// 🏥 COMPLETE CLINIC AVAILABILITY & BOOKING DEMO
///
/// This demonstrates EXACTLY what we implemented:
/// ✅ Real-time clinic availability (open/closed via Google Maps)
/// ✅ Live travel time calculation with traffic
/// ✅ Phone calling integration
/// ✅ Google Maps navigation
/// ✅ Booking options
/// ✅ Wait time estimates
/// ✅ Operating hours verification
class ClinicAvailabilityDemo {
  /// 🎯 Complete Demo: Everything You Asked For
  static Future<void> runCompleteDemo() async {
    print('🏥 ===============================================');
    print('🎯  COMPLETE CLINIC AVAILABILITY & BOOKING DEMO');
    print('🏥 ===============================================\n');

    // User location (Toronto downtown)
    const userLat = 43.6532;
    const userLng = -79.3832;
    const symptoms = 'mild headache for 2 hours';

    print('📍 User Location: Downtown Toronto (43.6532, -79.3832)');
    print('📝 Symptoms: "$symptoms"');
    print('⏰ Current Time: ${DateTime.now().toString().substring(0, 19)}');
    print('🔍 Searching for available clinics...\n');

    final bookingService = EnhancedClinicBookingService();

    try {
      // Find available clinics with full booking capabilities
      final availableClinics =
          await bookingService.findAvailableClinicsWithBooking(
        userLatitude: userLat,
        userLongitude: userLng,
        symptoms: symptoms,
        radiusKm: 10,
      );

      if (availableClinics.isEmpty) {
        print('❌ No clinics found in the area');
        return;
      }

      print('🎉 FOUND ${availableClinics.length} AVAILABLE CLINICS:\n');
      print('═' * 80);

      for (int i = 0; i < availableClinics.length; i++) {
        final clinic = availableClinics[i];

        print('${i + 1}. 🏥 ${clinic.name}');
        print('   📍 ${clinic.address}');
        print('   📏 Distance: ${clinic.distanceKm.toStringAsFixed(1)} km');
        print(
            '   🚗 Travel Time: ${clinic.travelTimeText} (with live traffic)');
        print('   ⭐ Rating: ${clinic.rating}/5.0');

        // REAL-TIME AVAILABILITY
        if (clinic.isCurrentlyOpen) {
          print('   ✅ CURRENTLY OPEN');
          print('   ⏰ Estimated Wait: ${clinic.estimatedWaitTime['text']}');
        } else {
          print('   ❌ CURRENTLY CLOSED');
        }

        // Operating hours
        if (clinic.openingHours.isNotEmpty) {
          print(
              '   🕐 Today\'s Hours: ${_getTodaysHours(clinic.openingHours)}');
        }

        // Contact information
        if (clinic.phoneNumber != null) {
          print('   📞 Phone: ${clinic.phoneNumber}');
        }

        if (clinic.website != null) {
          print('   🌐 Website: ${clinic.website}');
        }

        // BOOKING OPTIONS
        final bookingOptions =
            EnhancedClinicBookingService.generateBookingOptions(clinic);
        print('   📅 BOOKING OPTIONS:');

        for (final option in bookingOptions) {
          print('      ${option.icon} ${option.title}');
          if (option.actionUrl.isNotEmpty) {
            print('         → ${option.actionUrl}');
          }
        }

        // GEMINI AI RECOMMENDATION
        print('   🤖 AI RECOMMENDATION:');
        print('      "${clinic.geminiRecommendationText}"');

        print('\n' + '─' * 80 + '\n');
      }

      // Show what Gemini AI would tell the user
      final topClinic = availableClinics.first;
      print('🎯 TOP RECOMMENDATION FOR USER:');
      print('═' * 50);
      print('🤖 Gemini AI Response:');
      print('"For your mild headache, I recommend ${topClinic.name} which is ');
      print(
          '${topClinic.travelTimeText} away (${topClinic.distanceKm.toStringAsFixed(1)} km). ');

      if (topClinic.isCurrentlyOpen) {
        print('This clinic is currently OPEN with an estimated wait of ');
        print('${topClinic.estimatedWaitTime['text']}. ');
      } else {
        print('This clinic is currently CLOSED. ');
      }

      print('Walk-in clinics typically see patients in 20-60 minutes vs ');
      print(
          '4+ hours at emergency rooms, helping reduce hospital congestion!"');

      print('\n📱 AVAILABLE ACTIONS:');
      final options =
          EnhancedClinicBookingService.generateBookingOptions(topClinic);
      for (final option in options) {
        print('• ${option.icon} ${option.title} → ${option.actionUrl}');
      }
    } catch (e) {
      print('❌ Error running demo: $e');
    }
  }

  /// 📊 Show Implementation Details
  static void showImplementationDetails() {
    print('\n🔧 ===============================================');
    print('📋  WHAT WE IMPLEMENTED (YOUR REQUIREMENTS)');
    print('🔧 ===============================================\n');

    print('✅ 1. REAL-TIME CLINIC AVAILABILITY:');
    print('   • Google Places API → Find nearby clinics');
    print('   • Google Places Details API → Check opening_hours.open_now');
    print('   • Real opening/closing times verification');
    print('   • Weekend/holiday hour detection\n');

    print('✅ 2. GOOGLE MAPS INTEGRATION:');
    print('   • Google Directions API → Live traffic travel times');
    print('   • departure_time=now → Current traffic conditions');
    print('   • duration_in_traffic → Real-world travel estimates');
    print('   • Navigation URLs → Direct Google Maps integration\n');

    print('✅ 3. BOOKING SYSTEM:');
    print('   • Phone calling (tel: URLs)');
    print('   • Walk-in availability with wait times');
    print('   • Online booking (clinic websites)');
    print('   • Google Maps navigation integration\n');

    print('✅ 4. SMART WAIT TIME ESTIMATION:');
    print('   • Time-of-day factors (morning/evening rush)');
    print('   • Symptom urgency adjustments');
    print('   • Realistic wait time modeling\n');

    print('✅ 5. LOCATION-BASED ROUTING:');
    print('   • User\'s GPS coordinates');
    print('   • Distance calculation (Haversine formula)');
    print('   • Sort by availability + travel time');
    print('   • Traffic reduction recommendations\n');

    print('✅ 6. GEMINI AI INTEGRATION:');
    print('   • Real facility names in AI responses');
    print('   • Specific travel times (e.g., "12 minutes away")');
    print('   • Open/closed status in recommendations');
    print('   • Traffic reduction explanations\n');

    print('🎯 RESULT: Exactly what you requested!');
    print('   "clinic is 12 min away so can have access to google maps"');
    print('   "user can go there" + "call that facility using google maps"');
    print('   "distance we can give location time estimate too"');
  }

  /// 📱 Show Example API Response
  static void showExampleApiResponse() {
    print('\n📋 ===============================================');
    print('📊  EXAMPLE API RESPONSE (What Gemini Gets)');
    print('📋 ===============================================\n');

    final exampleResponse = '''
{
  "available_clinics": [
    {
      "name": "Toronto Medical Clinic",
      "address": "123 University Ave, Toronto, ON",
      "phone": "+1 (416) 555-0123",
      "website": "https://torontomedical.ca",
      "distance_km": 2.3,
      "travel_time_text": "12 mins",
      "travel_time_minutes": 12,
      "is_currently_open": true,
      "estimated_wait_time": {
        "text": "25 min",
        "minutes": 25,
        "type": "standard"
      },
      "opening_hours": [
        "Monday: 8:00 AM – 8:00 PM",
        "Tuesday: 8:00 AM – 8:00 PM",
        "Today: Open until 8:00 PM"
      ],
      "facility_type": "WALKIN",
      "rating": 4.2,
      "booking_options": [
        {
          "type": "phone",
          "title": "Call to Book",
          "action_url": "tel:+14165550123",
          "icon": "📞"
        },
        {
          "type": "walkin", 
          "title": "Walk-in Available",
          "action_url": "https://www.google.com/maps/dir/?api=1&destination=43.6590,-79.4089",
          "icon": "🚶‍♂️"
        },
        {
          "type": "navigate",
          "title": "Get Directions", 
          "action_url": "https://www.google.com/maps/dir/?api=1&destination=43.6590,-79.4089",
          "icon": "🗺️"
        }
      ],
      "gemini_recommendation": "For your symptoms, I recommend Toronto Medical Clinic which is 12 mins away (2.3 km). This clinic is currently open with estimated wait: 25 min. Walk-in clinics typically see patients in 20-60 minutes vs 4+ hours at emergency rooms!"
    }
  ],
  "user_location": {
    "latitude": 43.6532,
    "longitude": -79.3832
  },
  "search_radius_km": 10,
  "calculation_time": "2025-01-27T14:23:15Z"
}''';

    print(exampleResponse);
  }

  /// 🕐 Get today's hours from opening hours array
  static String _getTodaysHours(List<String> openingHours) {
    final today = DateTime.now().weekday;
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final todayName = dayNames[today - 1];

    for (final hours in openingHours) {
      if (hours.toLowerCase().contains(todayName.toLowerCase())) {
        return hours;
      }
    }

    return openingHours.isNotEmpty ? openingHours.first : 'Hours not available';
  }
}

/// 🚀 Quick Test Runner
void main() async {
  print('🎯 Starting Complete Clinic Availability Demo...\n');

  // Run the complete demo
  await ClinicAvailabilityDemo.runCompleteDemo();

  // Show what we implemented
  ClinicAvailabilityDemo.showImplementationDetails();

  // Show example API response
  ClinicAvailabilityDemo.showExampleApiResponse();

  print('\n✅ DEMO COMPLETE!');
  print('🎯 This system provides exactly what you requested:');
  print('   • Real-time clinic availability via Google Maps');
  print('   • Live travel times with traffic');
  print('   • Phone calling + navigation integration');
  print('   • Booking options');
  print('   • Gemini AI with specific facility recommendations');
}

import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/healthcare_facility_model.dart';

/// 🩺 Specialist Availability Service - HackTheBrain 2025 Inter-Hospital System
///
/// Solves the critical problem: "If Dr. X is unavailable, find Dr. Y who can see the patient sooner"
/// Real-world scenario: 15 cardio appointments cancelled -> find available cardiologist elsewhere
///
/// UPDATED: Now requires user location (latitude, longitude) for accurate distance calculations
class SpecialistAvailabilityService {
  static final Random _random = Random();

  /// Helper method to calculate distance between user and facility
  static double _calculateDistanceKm(
      double userLat, double userLng, HealthcareFacility facility) {
    return Geolocator.distanceBetween(
          userLat,
          userLng,
          facility.latitude,
          facility.longitude,
        ) /
        1000; // Convert meters to kilometers
  }

  /// 🔄 Find Alternative Specialist When Primary is Unavailable
  static Future<SpecialistAlternative?> findAlternativeSpecialist({
    required String specialty,
    required String originalHospital,
    required DateTime requestedDate,
    required String urgencyLevel,
    required List<HealthcareFacility> gtaFacilities,
    required double userLatitude,
    required double userLongitude,
  }) async {
    print('🔄 Finding alternative $specialty specialist...');
    print('📍 Original: $originalHospital, Date: $requestedDate');
    print('⚠️ Urgency: $urgencyLevel');

    // Filter facilities that have the required specialty
    final facilitiesWithSpecialty = gtaFacilities
        .where((facility) =>
            _hasSpecialty(facility, specialty) &&
            facility.name != originalHospital)
        .toList();

    if (facilitiesWithSpecialty.isEmpty) {
      print('❌ No alternative facilities found with $specialty');
      return null;
    }

    // Check availability at each facility
    final alternatives = <SpecialistAlternative>[];

    for (final facility in facilitiesWithSpecialty) {
      final availability = await _checkSpecialistAvailability(
        facility: facility,
        specialty: specialty,
        urgencyLevel: urgencyLevel,
        requestedDate: requestedDate,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
      );

      if (availability != null) {
        alternatives.add(availability);
      }
    }

    if (alternatives.isEmpty) {
      print('❌ No available specialists found in GTA network');
      return null;
    }

    // Sort by earliest available date, then by distance/quality
    alternatives.sort((a, b) {
      final dateComparison = a.availableDate.compareTo(b.availableDate);
      if (dateComparison != 0) return dateComparison;
      return a.priorityScore.compareTo(b.priorityScore);
    });

    final best = alternatives.first;
    final originalWait = requestedDate.difference(DateTime.now()).inDays;
    final newWait = best.availableDate.difference(DateTime.now()).inDays;
    final timeSaved = originalWait - newWait;

    print(
        '✅ Found alternative: ${best.specialistName} at ${best.facilityName}');
    print('⏰ Time saved: $timeSaved days (${originalWait} → ${newWait} days)');

    return best;
  }

  /// 🏥 Check if facility has required specialty
  static bool _hasSpecialty(HealthcareFacility facility, String specialty) {
    // Simulate specialty availability based on facility type and name
    final specialties = _getFacilitySpecialties(facility);
    return specialties.contains(specialty.toLowerCase());
  }

  /// 🔍 Get specialties available at each facility
  static List<String> _getFacilitySpecialties(HealthcareFacility facility) {
    // Major hospitals - full spectrum
    if (facility.name.contains('General') ||
        facility.name.contains('University') ||
        facility.name.contains('Mount Sinai')) {
      return [
        'cardiology',
        'neurology',
        'orthopedics',
        'oncology',
        'gastroenterology',
        'endocrinology',
        'nephrology',
        'pulmonology'
      ];
    }

    // Specialized hospitals
    if (facility.name.contains('Heart') || facility.name.contains('Cardiac')) {
      return ['cardiology', 'cardiovascular surgery'];
    }

    if (facility.name.contains('Cancer') ||
        facility.name.contains('Oncology')) {
      return ['oncology', 'hematology', 'radiation oncology'];
    }

    // Community hospitals - basic specialties
    return ['cardiology', 'orthopedics', 'gastroenterology'];
  }

  /// 🗓️ Check Specialist Availability at Facility
  static Future<SpecialistAlternative?> _checkSpecialistAvailability({
    required HealthcareFacility facility,
    required String specialty,
    required String urgencyLevel,
    required DateTime requestedDate,
    required double userLatitude,
    required double userLongitude,
  }) async {
    // Simulate checking real hospital booking systems
    await Future.delayed(
        const Duration(milliseconds: 100)); // API call simulation

    // Availability probability based on facility size and specialty
    final availabilityChance =
        _getAvailabilityChance(facility, specialty, urgencyLevel);

    if (_random.nextDouble() > availabilityChance) {
      return null; // No availability
    }

    // Calculate realistic available date
    final daysToAdd = _calculateDaysToAvailability(urgencyLevel, facility);
    final availableDate = DateTime.now().add(Duration(days: daysToAdd));

    // If available date is after requested date, no benefit
    if (availableDate.isAfter(requestedDate)) {
      return null;
    }

    return SpecialistAlternative(
      facilityName: facility.name,
      facilityId: facility.id,
      specialistName: _generateSpecialistName(specialty),
      specialty: specialty,
      availableDate: availableDate,
      estimatedDuration: '45-60 minutes',
      distanceKm: _calculateDistanceKm(userLatitude, userLongitude, facility),
      qualityRating: facility.qualityRating,
      waitTimeReduction: requestedDate.difference(availableDate).inDays,
      priorityScore: _calculatePriorityScore(
          facility, availableDate, urgencyLevel, userLatitude, userLongitude),
      transferReason: _getTransferReason(urgencyLevel),
    );
  }

  /// 📊 Calculate availability chance based on facility and urgency
  static double _getAvailabilityChance(
      HealthcareFacility facility, String specialty, String urgencyLevel) {
    double baseChance = 0.3; // 30% base availability

    // Larger facilities have more specialists
    if (facility.bedCount > 400) baseChance += 0.2;
    if (facility.bedCount > 600) baseChance += 0.1;

    // Higher urgency gets priority
    switch (urgencyLevel.toLowerCase()) {
      case 'urgent':
      case 'critical':
        baseChance += 0.3;
        break;
      case 'semi-urgent':
        baseChance += 0.2;
        break;
    }

    // Common specialties more available
    if (['cardiology', 'orthopedics'].contains(specialty.toLowerCase())) {
      baseChance += 0.1;
    }

    return baseChance.clamp(0.0, 0.8); // Max 80% chance
  }

  /// 📅 Calculate days to availability based on urgency
  /// Source: ICES Ontario Study (BMC Family Practice 2014) + Canadian Family Physician (2020)
  /// - National median specialist wait: 78 days (11 weeks)
  /// - Cardiology: 39 days, General Surgery: 33 days, Gastroenterology: 76 days
  /// - Urgent referrals: 24 days median (vs 78 days routine)
  static int _calculateDaysToAvailability(
      String urgencyLevel, HealthcareFacility facility) {
    int baseDays = 7; // Default 1 week for cross-referral availability

    switch (urgencyLevel.toLowerCase()) {
      case 'critical':
        baseDays = 1; // Next day (emergency protocol)
        break;
      case 'urgent':
        baseDays = 3; // Within 3 days (CIHI urgent standard)
        break;
      case 'semi-urgent':
        baseDays = 7; // Within a week (faster than 24-day urgent median)
        break;
      case 'routine':
        baseDays = 14; // Within 2 weeks (much faster than 78-day median)
        break;
    }

    // Add random variation
    final variation = _random.nextInt(3) - 1; // -1 to +1 days
    return (baseDays + variation).clamp(0, 30);
  }

  /// 🩺 Generate realistic specialist names
  static String _generateSpecialistName(String specialty) {
    final firstNames = [
      'Dr. Sarah',
      'Dr. Michael',
      'Dr. Jennifer',
      'Dr. David',
      'Dr. Emily',
      'Dr. Robert'
    ];
    final lastNames = [
      'Chen',
      'Smith',
      'Rodriguez',
      'Johnson',
      'Williams',
      'Brown',
      'Davis',
      'Miller'
    ];

    final firstName = firstNames[_random.nextInt(firstNames.length)];
    final lastName = lastNames[_random.nextInt(lastNames.length)];

    return '$firstName $lastName';
  }

  /// 🎯 Calculate priority score for sorting alternatives
  static double _calculatePriorityScore(
      HealthcareFacility facility,
      DateTime availableDate,
      String urgencyLevel,
      double userLatitude,
      double userLongitude) {
    // Lower score = higher priority
    double score = 0.0;

    // Time factor (most important)
    final daysToAvailable = availableDate.difference(DateTime.now()).inDays;
    score += daysToAvailable * 10; // 10 points per day

    // Distance factor
    final distanceKm =
        _calculateDistanceKm(userLatitude, userLongitude, facility);
    score += distanceKm * 2; // 2 points per km

    // Quality factor (inverted - higher quality = lower score)
    score += (5.0 - facility.qualityRating) * 5; // Up to 25 points

    // Urgency bonus (lower score for urgent cases)
    if (urgencyLevel.toLowerCase() == 'critical') score -= 50;
    if (urgencyLevel.toLowerCase() == 'urgent') score -= 30;

    return score;
  }

  /// 📝 Get transfer reason explanation
  static String _getTransferReason(String urgencyLevel) {
    switch (urgencyLevel.toLowerCase()) {
      case 'critical':
        return 'Critical case - immediate specialist required';
      case 'urgent':
        return 'Urgent case - faster specialist access needed';
      case 'semi-urgent':
        return 'Earlier appointment available to reduce wait time';
      default:
        return 'Alternative appointment found with shorter wait time';
    }
  }

  /// 🌐 Get System-Wide Specialist Availability Report
  static Map<String, dynamic> getSystemAvailabilityReport(
      List<HealthcareFacility> facilities) {
    final specialtyAvailability = <String, Map<String, dynamic>>{};

    final commonSpecialties = [
      'cardiology',
      'orthopedics',
      'neurology',
      'gastroenterology',
      'endocrinology',
      'oncology',
      'pulmonology',
      'nephrology'
    ];

    for (final specialty in commonSpecialties) {
      final facilitiesWithSpecialty =
          facilities.where((f) => _hasSpecialty(f, specialty)).length;
      final estimatedAvailability =
          (facilitiesWithSpecialty * 0.4).round(); // 40% typically available

      specialtyAvailability[specialty] = {
        'totalFacilities': facilitiesWithSpecialty,
        'estimatedAvailable': estimatedAvailability,
        'averageWaitDays': _random.nextInt(14) + 7, // 7-21 days
        'urgentSlots': _random.nextInt(5) + 2, // 2-7 urgent slots
      };
    }

    return {
      'lastUpdated': DateTime.now().toIso8601String(),
      'totalFacilities': facilities.length,
      'specialtyAvailability': specialtyAvailability,
      'systemStatus': 'Operational',
    };
  }
}

/// 🏥 Specialist Alternative Model
class SpecialistAlternative {
  final String facilityName;
  final String facilityId;
  final String specialistName;
  final String specialty;
  final DateTime availableDate;
  final String estimatedDuration;
  final double distanceKm;
  final double qualityRating;
  final int waitTimeReduction;
  final double priorityScore;
  final String transferReason;

  SpecialistAlternative({
    required this.facilityName,
    required this.facilityId,
    required this.specialistName,
    required this.specialty,
    required this.availableDate,
    required this.estimatedDuration,
    required this.distanceKm,
    required this.qualityRating,
    required this.waitTimeReduction,
    required this.priorityScore,
    required this.transferReason,
  });

  String get timeSavedMessage {
    if (waitTimeReduction <= 0) return 'No time saved';
    if (waitTimeReduction == 1) return '1 day sooner';
    if (waitTimeReduction < 7) return '$waitTimeReduction days sooner';
    if (waitTimeReduction < 30)
      return '${(waitTimeReduction / 7).round()} weeks sooner';
    return '${(waitTimeReduction / 30).round()} months sooner';
  }

  Map<String, dynamic> toJson() {
    return {
      'facilityName': facilityName,
      'facilityId': facilityId,
      'specialistName': specialistName,
      'specialty': specialty,
      'availableDate': availableDate.toIso8601String(),
      'estimatedDuration': estimatedDuration,
      'distanceKm': distanceKm,
      'qualityRating': qualityRating,
      'waitTimeReduction': waitTimeReduction,
      'timeSavedMessage': timeSavedMessage,
      'transferReason': transferReason,
      'priorityScore': priorityScore,
    };
  }
}

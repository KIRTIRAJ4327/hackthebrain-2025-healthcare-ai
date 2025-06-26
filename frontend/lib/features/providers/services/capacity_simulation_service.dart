import 'dart:math';
import '../models/healthcare_facility_model.dart';

/// 🔥 **HACKTHEBRAIN 2025 COMPETITION FEATURE**: Real-time Capacity Simulation Engine
///
/// Simulates realistic healthcare capacity across Greater Toronto Area based on:
/// - Ontario healthcare crisis research (20-hour average ER waits)
/// - Time of day patterns (morning rush, lunch, evening surge)
/// - Day of week variations (Monday madness, weekend patterns)
/// - GTA traffic patterns affecting travel times
///
/// This creates a living, breathing healthcare system for your demo!
class CapacitySimulationService {
  static final Random _random = Random();

  /// 🏥 Generate realistic wait times based on evidence-based patterns
  static Map<String, dynamic> generateRealtimeCapacityData(
      {DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final timeOfDay = now.hour;
    final dayOfWeek = now.weekday;

    // Base multiplier starts at 1.0
    double systemLoadMultiplier = 1.0;

    // 🕒 TIME OF DAY FACTORS (based on real ER admission patterns)
    if (timeOfDay >= 8 && timeOfDay <= 10) {
      systemLoadMultiplier *= 1.6; // Morning rush: +60%
    } else if (timeOfDay >= 14 && timeOfDay <= 16) {
      systemLoadMultiplier *= 1.3; // Lunch aftermath: +30%
    } else if (timeOfDay >= 17 && timeOfDay <= 19) {
      systemLoadMultiplier *= 1.8; // After-work surge: +80%
    } else if (timeOfDay >= 22 || timeOfDay <= 6) {
      systemLoadMultiplier *= 0.7; // Night reduction: -30%
    }

    // 📅 DAY OF WEEK FACTORS
    switch (dayOfWeek) {
      case 1:
        systemLoadMultiplier *= 1.4;
        break; // Monday madness: +40%
      case 2:
        systemLoadMultiplier *= 1.1;
        break; // Tuesday: +10%
      case 5:
        systemLoadMultiplier *= 1.2;
        break; // Friday: +20%
      case 6:
        systemLoadMultiplier *= 1.1;
        break; // Saturday: +10%
      case 7:
        systemLoadMultiplier *= 0.9;
        break; // Sunday: -10%
    }

    // 🎲 Random events (system incidents, staff shortages, etc.)
    final randomEvent = _random.nextDouble();
    if (randomEvent < 0.05) {
      systemLoadMultiplier *= 1.5; // 5% chance of major incident
    } else if (randomEvent < 0.15) {
      systemLoadMultiplier *= 1.3; // 10% chance of moderate incident
    }

    // 🏥 EVIDENCE-BASED WAIT TIMES from Official Canadian Data Sources
    // Sources:
    // - CIHI NACRS Emergency Department Data (2024): Average 2.0 hours initial assessment
    // - Health Quality Ontario (Aug 2024): Low-urgency 3.2h, High-urgency 4.7h, Admitted 19.2h
    // - ICES Ontario Study (BMC Family Practice): Specialist wait times 33-76 days
    // - Canadian Family Physician (2020): National median specialist wait 78 days (11 weeks)

    // Emergency Department Times (Health Quality Ontario, August 2024)
    final emergencyWait = (180 +
            (_random.nextDouble() * 120 * systemLoadMultiplier))
        .round(); // 3-5 hours (HQO: low-urgency 3.2h avg, high-urgency 4.7h avg)

    // Urgent care: Evidence-based 1-2 hours (much better than emergency)
    final urgentWait = (60 + (_random.nextDouble() * 60 * systemLoadMultiplier))
        .round(); // 1-2 hours (industry standard, CIHI data)

    // Walk-in clinics: 30-90 minutes (major traffic reducer from ER)
    final clinicWait =
        (30 + (_random.nextDouble() * 60 * systemLoadMultiplier * 0.7))
            .round(); // 30-90 min (Ontario primary care data)

    // Hospital general: 2-4 hours (CIHI emergency data baseline)
    final hospitalWait =
        (120 + (_random.nextDouble() * 120 * systemLoadMultiplier))
            .round(); // 2-4 hours

    // Specialist appointments: ICES Study - 33-76 days if available same-day
    // For walk-in specialist availability: 45-90 minutes
    final specialistWait =
        (45 + (_random.nextDouble() * 45 * systemLoadMultiplier))
            .round(); // 45-90 min for available appointments

    return {
      'emergency': emergencyWait,
      'urgent_care': urgentWait,
      'hospital': hospitalWait,
      'clinic': clinicWait,
      'specialized': specialistWait,
      'lastUpdated': now.toIso8601String(),
      'trafficMultiplier': _getGTATrafficMultiplier(timeOfDay, dayOfWeek),
      'systemLoadPercentage':
          (systemLoadMultiplier * 100).round().clamp(50, 150),
      'systemStatus': _getSystemHealthStatus(systemLoadMultiplier),
    };
  }

  /// 🚗 GTA traffic multipliers for travel time calculation
  static double _getGTATrafficMultiplier(int hour, int dayOfWeek) {
    // GTA-specific traffic patterns
    if (dayOfWeek >= 1 && dayOfWeek <= 5) {
      // Weekdays
      if ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19)) {
        return 2.2; // Rush hour nightmare: +120% travel time
      } else if (hour >= 10 && hour <= 16) {
        return 1.4; // Midday traffic: +40%
      }
    } else {
      // Weekends
      if (hour >= 12 && hour <= 18) {
        return 1.5; // Weekend shopping/events: +50%
      }
    }
    return 1.0; // Normal traffic
  }

  /// 🏥 Get system health status based on load
  static String _getSystemHealthStatus(double loadMultiplier) {
    if (loadMultiplier <= 0.8) return 'Optimal';
    if (loadMultiplier <= 1.1) return 'Normal';
    if (loadMultiplier <= 1.3) return 'Busy';
    if (loadMultiplier <= 1.5) return 'High Load';
    return 'Critical';
  }

  /// 🎯 **COMPETITION DEMO**: Update facility with realistic real-time data
  static HealthcareFacility updateFacilityWithRealtimeData(
    HealthcareFacility facility, {
    DateTime? currentTime,
  }) {
    final capacityData = generateRealtimeCapacityData(currentTime: currentTime);
    final waitTime =
        capacityData[facility.type] ?? facility.currentWaitTimeMinutes;
    final loadPercentage = capacityData['systemLoadPercentage'] / 100.0;

    // Generate realistic alerts based on current conditions
    final alerts = <String>[];

    if (loadPercentage > 1.2) {
      alerts.add('High Volume');
    }
    if (loadPercentage > 1.4) {
      alerts.add('Critical Capacity');
    }
    if (_random.nextDouble() < 0.1) {
      alerts.add('Staff Shortage');
    }
    if (_random.nextDouble() < 0.05) {
      alerts.add('Equipment Issue');
    }

    return facility.copyWith(
      currentCapacity:
          (facility.currentCapacity * loadPercentage).clamp(0.0, 1.0),
      currentWaitTimeMinutes: waitTime,
      lastUpdated: DateTime.now(),
      currentAlerts: alerts,
      // Adjust available beds based on capacity
      availableBeds: (facility.bedCount * (1.0 - loadPercentage * 0.5))
          .round()
          .clamp(0, facility.bedCount),
      // Staffing level varies with load
      staffingLevel: (1.0 - (loadPercentage - 1.0) * 0.3).clamp(0.5, 1.0),
    );
  }

  /// 📊 **ANALYTICS**: Get GTA-wide system metrics
  static Map<String, dynamic> getSystemMetrics({
    required List<HealthcareFacility> facilities,
    DateTime? currentTime,
  }) {
    final capacityData = generateRealtimeCapacityData(currentTime: currentTime);

    // Calculate system-wide averages
    double totalWaitTime = 0;
    double totalCapacity = 0;
    int facilitiesAtCapacity = 0;

    for (final facility in facilities) {
      final facilityWait = capacityData[facility.type] ?? 0;
      totalWaitTime += facilityWait;

      if (facility.currentCapacity >= 0.9) {
        facilitiesAtCapacity++;
      }
      totalCapacity += facility.currentCapacity;
    }

    final avgWaitTime =
        facilities.isNotEmpty ? totalWaitTime / facilities.length : 0.0;
    final avgCapacity =
        facilities.isNotEmpty ? totalCapacity / facilities.length : 0.0;

    return {
      'averageWaitTime': avgWaitTime,
      'systemCapacity': avgCapacity,
      'facilitiesAtCapacity': facilitiesAtCapacity,
      'totalFacilities': facilities.length,
      'systemStatus': capacityData['systemStatus'],
      'trafficMultiplier': capacityData['trafficMultiplier'],
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// 🚨 Generate real-time system alerts
  static List<String> generateSystemAlerts({
    required Map<String, dynamic> systemMetrics,
  }) {
    final alerts = <String>[];

    final avgCapacity = systemMetrics['systemCapacity'] ?? 0.0;
    final facilitiesAtCapacity = systemMetrics['facilitiesAtCapacity'] ?? 0;
    final avgWaitTime = systemMetrics['averageWaitTime'] ?? 0.0;

    if (avgCapacity >= 0.9) {
      alerts.add('System-wide High Capacity');
    }
    if (facilitiesAtCapacity >= 3) {
      alerts.add('Multiple Facilities at Capacity');
    }
    if (avgWaitTime >= 300) {
      alerts.add('Province-wide Delays');
    }

    return alerts;
  }
}

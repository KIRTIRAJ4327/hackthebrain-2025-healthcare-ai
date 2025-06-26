import 'healthcare_facility_model.dart';

/// 🎯 **COMPETITION WINNING FEATURE**: Optimal Facility Result
///
/// This is the output of your AI-powered optimization engine!
/// Combines facility data with AI recommendations, travel times, and total optimization scores.
class OptimalFacilityResult {
  final HealthcareFacility facility;
  final double optimalScore; // 0.0-1.0, higher = better choice
  final Duration travelTime;
  final int totalTimeMinutes; // travel + wait time
  final String aiRecommendationReason;
  final Map<String, dynamic> optimizationFactors;

  const OptimalFacilityResult({
    required this.facility,
    required this.optimalScore,
    required this.travelTime,
    required this.totalTimeMinutes,
    required this.aiRecommendationReason,
    this.optimizationFactors = const {},
  });

  /// Get total time as human-readable string
  String get totalTimeFormatted {
    final hours = totalTimeMinutes ~/ 60;
    final minutes = totalTimeMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Get travel time as human-readable string
  String get travelTimeFormatted {
    final minutes = travelTime.inMinutes;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m';
  }

  /// Get wait time as human-readable string
  String get waitTimeFormatted {
    final minutes = facility.currentWaitTimeMinutes;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m';
  }

  /// Get optimization score as percentage
  String get scorePercentage => '${(optimalScore * 100).round()}%';

  /// Get facility type display name
  String get facilityTypeDisplay {
    switch (facility.type) {
      case 'emergency':
        return 'Emergency Department';
      case 'urgent_care':
        return 'Urgent Care Centre';
      case 'hospital':
        return 'Hospital';
      case 'clinic':
        return 'Medical Clinic';
      case 'specialized':
        return 'Specialist Centre';
      default:
        return 'Healthcare Facility';
    }
  }

  /// Get urgency indicator based on total time
  String get urgencyIndicator {
    if (totalTimeMinutes <= 60) return 'Excellent';
    if (totalTimeMinutes <= 120) return 'Good';
    if (totalTimeMinutes <= 240) return 'Fair';
    return 'High Wait';
  }

  /// Get urgency color for UI
  String get urgencyColor {
    if (totalTimeMinutes <= 60) return '#4CAF50'; // Green
    if (totalTimeMinutes <= 120) return '#FF9800'; // Orange
    if (totalTimeMinutes <= 240) return '#FF5722'; // Red-Orange
    return '#F44336'; // Red
  }

  /// Check if this is an optimal choice (top 20% score)
  bool get isOptimalChoice => optimalScore >= 0.8;

  /// Get specialized capabilities as list
  List<String> get specializedCapabilities {
    final capabilities = <String>[];

    if (facility.hasTraumaCenter) capabilities.add('Trauma Centre');
    if (facility.hasCardiacCare) capabilities.add('Cardiac Care');
    if (facility.hasStroke) capabilities.add('Stroke Care');
    if (facility.hasPediatricER) capabilities.add('Pediatric Emergency');
    if (facility.hasBurnUnit) capabilities.add('Burn Unit');
    if (facility.hasMaternity) capabilities.add('Maternity Care');

    return capabilities;
  }

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'facility': facility.toJson(),
      'optimalScore': optimalScore,
      'travelTimeMinutes': travelTime.inMinutes,
      'totalTimeMinutes': totalTimeMinutes,
      'aiRecommendationReason': aiRecommendationReason,
      'optimizationFactors': optimizationFactors,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Create from JSON
  factory OptimalFacilityResult.fromJson(Map<String, dynamic> json) {
    return OptimalFacilityResult(
      facility: HealthcareFacility.fromJson(json['facility']),
      optimalScore: (json['optimalScore'] ?? 0.0).toDouble(),
      travelTime: Duration(minutes: json['travelTimeMinutes'] ?? 0),
      totalTimeMinutes: json['totalTimeMinutes'] ?? 0,
      aiRecommendationReason: json['aiRecommendationReason'] ?? '',
      optimizationFactors:
          Map<String, dynamic>.from(json['optimizationFactors'] ?? {}),
    );
  }
}

/// 🔍 **SYSTEM-WIDE ANALYTICS**: GTA Healthcare System Status
///
/// Real-time analytics across the entire Greater Toronto Area healthcare network
class GTAHealthcareSystemStatus {
  final int totalFacilities;
  final int availableFacilities;
  final double averageWaitTime;
  final double systemCapacity; // 0.0-1.0
  final List<String> systemAlerts;
  final Map<String, int> facilityTypeBreakdown;
  final DateTime lastUpdated;

  const GTAHealthcareSystemStatus({
    required this.totalFacilities,
    required this.availableFacilities,
    required this.averageWaitTime,
    required this.systemCapacity,
    required this.systemAlerts,
    required this.facilityTypeBreakdown,
    required this.lastUpdated,
  });

  /// Get system health status
  String get systemHealthStatus {
    if (systemCapacity <= 0.7) return 'Optimal';
    if (systemCapacity <= 0.85) return 'Busy';
    if (systemCapacity <= 0.95) return 'High Load';
    return 'Critical';
  }

  /// Get system health color
  String get systemHealthColor {
    if (systemCapacity <= 0.7) return '#4CAF50';
    if (systemCapacity <= 0.85) return '#FF9800';
    if (systemCapacity <= 0.95) return '#FF5722';
    return '#F44336';
  }

  /// Get average wait time formatted
  String get averageWaitTimeFormatted {
    final hours = averageWaitTime ~/ 60;
    final minutes = (averageWaitTime % 60).round();

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

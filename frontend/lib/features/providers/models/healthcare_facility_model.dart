import 'package:geolocator/geolocator.dart';

/// 🏥 GTA Healthcare Facility Model
///
/// Real healthcare facilities across Greater Toronto Area with live capacity,
/// wait times, and AI-powered optimization for reducing 30-week waits to 2-hour care.
class HealthcareFacility {
  final String id;
  final String name;
  final String type; // 'emergency', 'urgent_care', 'hospital', 'clinic'
  final List<String> specialties;
  final String address;
  final double latitude;
  final double longitude;
  final String postalCode;
  final String city;
  final String
      healthNetwork; // 'UHN', 'Unity Health', 'Scarborough Health', etc.

  // Real-time capacity data (based on Ontario ER crisis research)
  final double currentCapacity; // 0.0-1.0 (0 = empty, 1 = full)
  final int currentWaitTimeMinutes; // Current wait time in minutes
  final int
      avgWaitTimeMinutes; // Historical average (Ontario avg: 1200 min = 20 hours)
  final DateTime lastUpdated;

  // Emergency and specialty capabilities
  final bool hasEmergencyDepartment;
  final bool hasTraumaCenter;
  final bool hasPediatricER;
  final bool hasCardiacCare;
  final bool hasStroke;
  final bool hasBurnUnit;
  final bool hasMaternity;
  final List<String> languages; // ['en', 'fr', 'zh', 'ur', 'pa', 'ar']

  // Contact and operational info
  final String phoneNumber;
  final String website;
  final Map<String, String>
      operatingHours; // {'monday': '24/7', 'tuesday': '8-18'}
  final bool isOpen24Hours;
  final bool acceptsWalkIns;
  final bool requiresReferral;

  // Quality and performance metrics
  final double qualityRating; // 1-5 stars
  final int bedCount;
  final int availableBeds;
  final double staffingLevel; // 0.0-1.0 (current staffing vs optimal)
  final List<String>
      currentAlerts; // ['High Volume', 'Staff Shortage', 'Equipment Issue']

  HealthcareFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.specialties,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.postalCode,
    required this.city,
    required this.healthNetwork,
    required this.currentCapacity,
    required this.currentWaitTimeMinutes,
    required this.avgWaitTimeMinutes,
    required this.lastUpdated,
    required this.hasEmergencyDepartment,
    required this.hasTraumaCenter,
    required this.hasPediatricER,
    required this.hasCardiacCare,
    required this.hasStroke,
    required this.hasBurnUnit,
    required this.hasMaternity,
    required this.languages,
    required this.phoneNumber,
    required this.website,
    required this.operatingHours,
    required this.isOpen24Hours,
    required this.acceptsWalkIns,
    required this.requiresReferral,
    required this.qualityRating,
    required this.bedCount,
    required this.availableBeds,
    required this.staffingLevel,
    required this.currentAlerts,
  });

  /// Calculate optimal score for patient routing (AI-powered)
  double calculateOptimalScore({
    required Position patientLocation,
    required String urgencyLevel, // 'CTAS-1' to 'CTAS-5'
    required List<String> requiredSpecialties,
    required List<String> preferredLanguages,
  }) {
    double score = 0.0;

    // 1. Distance factor (closer = better)
    final distance = Geolocator.distanceBetween(patientLocation.latitude,
            patientLocation.longitude, latitude, longitude) /
        1000; // Convert to km

    final distanceScore = (50 - distance.clamp(0, 50)) / 50; // Max 50km range

    // 2. Wait time factor (shorter = better) - Critical for Ontario's 20-hour crisis
    final waitScore =
        (300 - currentWaitTimeMinutes.clamp(0, 300)) / 300; // Max 5 hours

    // 3. Capacity factor (less crowded = better)
    final capacityScore = 1.0 - currentCapacity;

    // 4. Specialty match (exact match = bonus)
    double specialtyScore = 0.0;
    for (String required in requiredSpecialties) {
      if (specialties.contains(required)) specialtyScore += 0.2;
    }

    // 5. Language support (patient language = bonus)
    double languageScore = 0.0;
    for (String preferred in preferredLanguages) {
      if (languages.contains(preferred)) languageScore += 0.1;
    }

    // 6. Quality and staffing
    final qualityScore = qualityRating / 5.0;
    final staffScore = staffingLevel;

    // 7. Urgency-based weighting (CTAS Level 1 = immediate, Level 5 = non-urgent)
    Map<String, Map<String, double>> urgencyWeights = {
      'CTAS-1': {
        'wait': 0.6,
        'distance': 0.3,
        'capacity': 0.1
      }, // Life-threatening
      'CTAS-2': {
        'wait': 0.5,
        'distance': 0.3,
        'capacity': 0.2
      }, // Imminently life-threatening
      'CTAS-3': {'wait': 0.4, 'distance': 0.3, 'capacity': 0.3}, // Urgent
      'CTAS-4': {'wait': 0.3, 'distance': 0.4, 'capacity': 0.3}, // Less urgent
      'CTAS-5': {'wait': 0.2, 'distance': 0.4, 'capacity': 0.4}, // Non-urgent
    };

    final weights = urgencyWeights[urgencyLevel] ?? urgencyWeights['CTAS-3']!;

    // Calculate weighted score
    score = (waitScore * weights['wait']!) +
        (distanceScore * weights['distance']!) +
        (capacityScore * weights['capacity']!) +
        (specialtyScore * 0.1) +
        (languageScore * 0.05) +
        (qualityScore * 0.05) +
        (staffScore * 0.05);

    // Penalty for alerts
    for (String alert in currentAlerts) {
      if (alert == 'High Volume') score *= 0.9;
      if (alert == 'Staff Shortage') score *= 0.8;
      if (alert == 'Equipment Issue') score *= 0.7;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Get estimated travel time to facility
  Duration getEstimatedTravelTime(Position patientLocation) {
    final distance = Geolocator.distanceBetween(patientLocation.latitude,
            patientLocation.longitude, latitude, longitude) /
        1000; // Convert to km

    // Estimate based on GTA traffic patterns
    // Average speed: 35 km/h (accounting for traffic, lights, etc.)
    final travelTimeMinutes = (distance / 35 * 60).round();
    return Duration(minutes: travelTimeMinutes);
  }

  /// Check if facility can handle specific medical emergency
  bool canHandleEmergency(String emergencyType) {
    switch (emergencyType.toLowerCase()) {
      case 'cardiac':
      case 'heart attack':
        return hasCardiacCare && hasEmergencyDepartment;
      case 'stroke':
        return hasStroke && hasEmergencyDepartment;
      case 'trauma':
      case 'accident':
        return hasTraumaCenter;
      case 'pediatric':
      case 'child':
        return hasPediatricER;
      case 'burn':
        return hasBurnUnit;
      case 'maternity':
      case 'birth':
        return hasMaternity;
      default:
        return hasEmergencyDepartment;
    }
  }

  /// Serialize to JSON for Firebase storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'specialties': specialties,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'postalCode': postalCode,
      'city': city,
      'healthNetwork': healthNetwork,
      'currentCapacity': currentCapacity,
      'currentWaitTimeMinutes': currentWaitTimeMinutes,
      'avgWaitTimeMinutes': avgWaitTimeMinutes,
      'lastUpdated': lastUpdated.toIso8601String(),
      'hasEmergencyDepartment': hasEmergencyDepartment,
      'hasTraumaCenter': hasTraumaCenter,
      'hasPediatricER': hasPediatricER,
      'hasCardiacCare': hasCardiacCare,
      'hasStroke': hasStroke,
      'hasBurnUnit': hasBurnUnit,
      'hasMaternity': hasMaternity,
      'languages': languages,
      'phoneNumber': phoneNumber,
      'website': website,
      'operatingHours': operatingHours,
      'isOpen24Hours': isOpen24Hours,
      'acceptsWalkIns': acceptsWalkIns,
      'requiresReferral': requiresReferral,
      'qualityRating': qualityRating,
      'bedCount': bedCount,
      'availableBeds': availableBeds,
      'staffingLevel': staffingLevel,
      'currentAlerts': currentAlerts,
    };
  }

  /// Create from JSON (Firebase data)
  factory HealthcareFacility.fromJson(Map<String, dynamic> json) {
    return HealthcareFacility(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      specialties: List<String>.from(json['specialties'] ?? []),
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      postalCode: json['postalCode'] ?? '',
      city: json['city'] ?? '',
      healthNetwork: json['healthNetwork'] ?? '',
      currentCapacity: (json['currentCapacity'] ?? 0.0).toDouble(),
      currentWaitTimeMinutes: json['currentWaitTimeMinutes'] ?? 0,
      avgWaitTimeMinutes: json['avgWaitTimeMinutes'] ?? 0,
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      hasEmergencyDepartment: json['hasEmergencyDepartment'] ?? false,
      hasTraumaCenter: json['hasTraumaCenter'] ?? false,
      hasPediatricER: json['hasPediatricER'] ?? false,
      hasCardiacCare: json['hasCardiacCare'] ?? false,
      hasStroke: json['hasStroke'] ?? false,
      hasBurnUnit: json['hasBurnUnit'] ?? false,
      hasMaternity: json['hasMaternity'] ?? false,
      languages: List<String>.from(json['languages'] ?? []),
      phoneNumber: json['phoneNumber'] ?? '',
      website: json['website'] ?? '',
      operatingHours: Map<String, String>.from(json['operatingHours'] ?? {}),
      isOpen24Hours: json['isOpen24Hours'] ?? false,
      acceptsWalkIns: json['acceptsWalkIns'] ?? false,
      requiresReferral: json['requiresReferral'] ?? false,
      qualityRating: (json['qualityRating'] ?? 0.0).toDouble(),
      bedCount: json['bedCount'] ?? 0,
      availableBeds: json['availableBeds'] ?? 0,
      staffingLevel: (json['staffingLevel'] ?? 0.0).toDouble(),
      currentAlerts: List<String>.from(json['currentAlerts'] ?? []),
    );
  }

  /// Create a copy with updated values
  HealthcareFacility copyWith({
    String? id,
    String? name,
    String? type,
    List<String>? specialties,
    String? address,
    double? latitude,
    double? longitude,
    String? postalCode,
    String? city,
    String? healthNetwork,
    double? currentCapacity,
    int? currentWaitTimeMinutes,
    int? avgWaitTimeMinutes,
    DateTime? lastUpdated,
    bool? hasEmergencyDepartment,
    bool? hasTraumaCenter,
    bool? hasPediatricER,
    bool? hasCardiacCare,
    bool? hasStroke,
    bool? hasBurnUnit,
    bool? hasMaternity,
    List<String>? languages,
    String? phoneNumber,
    String? website,
    Map<String, String>? operatingHours,
    bool? isOpen24Hours,
    bool? acceptsWalkIns,
    bool? requiresReferral,
    double? qualityRating,
    int? bedCount,
    int? availableBeds,
    double? staffingLevel,
    List<String>? currentAlerts,
  }) {
    return HealthcareFacility(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      specialties: specialties ?? this.specialties,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      healthNetwork: healthNetwork ?? this.healthNetwork,
      currentCapacity: currentCapacity ?? this.currentCapacity,
      currentWaitTimeMinutes:
          currentWaitTimeMinutes ?? this.currentWaitTimeMinutes,
      avgWaitTimeMinutes: avgWaitTimeMinutes ?? this.avgWaitTimeMinutes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hasEmergencyDepartment:
          hasEmergencyDepartment ?? this.hasEmergencyDepartment,
      hasTraumaCenter: hasTraumaCenter ?? this.hasTraumaCenter,
      hasPediatricER: hasPediatricER ?? this.hasPediatricER,
      hasCardiacCare: hasCardiacCare ?? this.hasCardiacCare,
      hasStroke: hasStroke ?? this.hasStroke,
      hasBurnUnit: hasBurnUnit ?? this.hasBurnUnit,
      hasMaternity: hasMaternity ?? this.hasMaternity,
      languages: languages ?? this.languages,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      operatingHours: operatingHours ?? this.operatingHours,
      isOpen24Hours: isOpen24Hours ?? this.isOpen24Hours,
      acceptsWalkIns: acceptsWalkIns ?? this.acceptsWalkIns,
      requiresReferral: requiresReferral ?? this.requiresReferral,
      qualityRating: qualityRating ?? this.qualityRating,
      bedCount: bedCount ?? this.bedCount,
      availableBeds: availableBeds ?? this.availableBeds,
      staffingLevel: staffingLevel ?? this.staffingLevel,
      currentAlerts: currentAlerts ?? this.currentAlerts,
    );
  }
}

/// 🎯 Optimization Result for Patient Routing
class OptimizationResult {
  final HealthcareFacility facility;
  final double optimizationScore;
  final Duration estimatedTravelTime;
  final Duration totalTimeToTreatment; // Travel + Wait
  final String reasoningExplanation;
  final List<String> warnings;

  OptimizationResult({
    required this.facility,
    required this.optimizationScore,
    required this.estimatedTravelTime,
    required this.totalTimeToTreatment,
    required this.reasoningExplanation,
    required this.warnings,
  });
}

/// 📊 GTA Healthcare Network Statistics
class GTAHealthcareStats {
  final int totalFacilities;
  final double avgWaitTime;
  final double avgCapacity;
  final int facilitiesAtCapacity;
  final Map<String, int> facilitiesByNetwork;
  final Map<String, double> avgWaitByNetwork;

  GTAHealthcareStats({
    required this.totalFacilities,
    required this.avgWaitTime,
    required this.avgCapacity,
    required this.facilitiesAtCapacity,
    required this.facilitiesByNetwork,
    required this.avgWaitByNetwork,
  });
}

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

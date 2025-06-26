import 'package:uuid/uuid.dart';

/// 🏥 Triage Result Model
///
/// Represents the AI analysis result following CTAS protocol
class TriageResult {
  final String sessionId;
  final int ctasLevel; // 1-5 (Canadian Triage and Acuity Scale)
  final String urgencyDescription;
  final String reasoning;
  final String recommendedAction;
  final double confidenceScore; // 0.0-1.0
  final String estimatedWaitTime;
  final bool requiresEmergency;
  final String language;
  final DateTime analysisTimestamp;
  final List<String> redFlags;
  final List<String> nextSteps;

  // 🗺️ Location-based facility recommendation fields (optional)
  final String? recommendedFacility;
  final String? facilityType;
  final String? trafficReductionMessage;
  final double? facilityDistance;
  final String? facilityTravelTime;

  TriageResult({
    required this.sessionId,
    required this.ctasLevel,
    required this.urgencyDescription,
    required this.reasoning,
    required this.recommendedAction,
    required this.confidenceScore,
    required this.estimatedWaitTime,
    required this.requiresEmergency,
    required this.language,
    required this.analysisTimestamp,
    required this.redFlags,
    required this.nextSteps,
    // Optional location-based fields
    this.recommendedFacility,
    this.facilityType,
    this.trafficReductionMessage,
    this.facilityDistance,
    this.facilityTravelTime,
  });

  /// 🚨 Create Safety Fallback Result
  ///
  /// Used when AI analysis fails - ensures patient always gets guidance
  factory TriageResult.createSafetyFallback({
    required String sessionId,
    required String language,
    required String originalSymptoms,
  }) {
    final isEmergencyKeyword = _containsEmergencyKeywords(originalSymptoms);

    return TriageResult(
      sessionId: sessionId,
      ctasLevel: isEmergencyKeyword ? 2 : 3, // Conservative escalation
      urgencyDescription: isEmergencyKeyword
          ? 'Potentially Life-Threatening'
          : 'Urgent Assessment Required',
      reasoning:
          'AI analysis unavailable. Based on safety protocols, immediate medical attention recommended.',
      recommendedAction: isEmergencyKeyword
          ? 'Go to Emergency Department immediately'
          : 'Visit healthcare provider within 30 minutes',
      confidenceScore: 0.8, // High confidence in safety escalation
      estimatedWaitTime: isEmergencyKeyword ? 'Immediate' : '30 minutes',
      requiresEmergency: isEmergencyKeyword,
      language: language,
      analysisTimestamp: DateTime.now(),
      redFlags: isEmergencyKeyword ? ['Emergency keywords detected'] : [],
      nextSteps: [
        'Seek immediate medical attention',
        'Do not delay treatment',
        'Call 911 if symptoms worsen',
      ],
    );
  }

  /// 🚨 Create location-aware TriageResult with facility recommendation
  factory TriageResult.withLocationData({
    required String sessionId,
    required int ctasLevel,
    required String urgencyDescription,
    required String reasoning,
    required String recommendedAction,
    required double confidenceScore,
    required String estimatedWaitTime,
    required bool requiresEmergency,
    required String language,
    required DateTime analysisTimestamp,
    required List<String> redFlags,
    required List<String> nextSteps,
    String? recommendedFacility,
    String? facilityType,
    String? trafficReductionMessage,
    double? facilityDistance,
    String? facilityTravelTime,
  }) {
    return TriageResult(
      sessionId: sessionId,
      ctasLevel: ctasLevel,
      urgencyDescription: urgencyDescription,
      reasoning: reasoning,
      recommendedAction: recommendedAction,
      confidenceScore: confidenceScore,
      estimatedWaitTime: estimatedWaitTime,
      requiresEmergency: requiresEmergency,
      language: language,
      analysisTimestamp: analysisTimestamp,
      redFlags: redFlags,
      nextSteps: nextSteps,
      recommendedFacility: recommendedFacility,
      facilityType: facilityType,
      trafficReductionMessage: trafficReductionMessage,
      facilityDistance: facilityDistance,
      facilityTravelTime: facilityTravelTime,
    );
  }

  /// 📊 Get Priority Color for UI
  String get priorityColor {
    switch (ctasLevel) {
      case 1:
        return '#DC2626'; // Emergency Red
      case 2:
        return '#F59E0B'; // Warning Orange
      case 3:
        return '#D97706'; // Urgent Orange
      case 4:
        return '#059669'; // Less Urgent Green
      case 5:
        return '#10B981'; // Non-Urgent Light Green
      default:
        return '#6B7280'; // Gray
    }
  }

  /// ⏱️ Get Max Wait Time Minutes
  int get maxWaitTimeMinutes {
    switch (ctasLevel) {
      case 1:
        return 0;
      case 2:
        return 15;
      case 3:
        return 30;
      case 4:
        return 60;
      case 5:
        return 120;
      default:
        return 60;
    }
  }

  /// 🚨 Check if Critical Case
  bool get isCritical => ctasLevel <= 2;

  /// ⚡ Check if Urgent Case
  bool get isUrgent => ctasLevel <= 3;

  /// 📱 Get Formatted Display Text
  String get formattedUrgency {
    switch (ctasLevel) {
      case 1:
        return 'IMMEDIATE - Life Threatening';
      case 2:
        return 'URGENT - Potentially Life Threatening';
      case 3:
        return 'URGENT - Needs Attention';
      case 4:
        return 'LESS URGENT - Can Wait';
      case 5:
        return 'NON-URGENT - Routine Care';
      default:
        return 'ASSESSMENT NEEDED';
    }
  }

  /// 🔄 Convert to Map for Storage
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'ctasLevel': ctasLevel,
      'urgencyDescription': urgencyDescription,
      'reasoning': reasoning,
      'recommendedAction': recommendedAction,
      'confidenceScore': confidenceScore,
      'estimatedWaitTime': estimatedWaitTime,
      'requiresEmergency': requiresEmergency,
      'language': language,
      'analysisTimestamp': analysisTimestamp.toIso8601String(),
      'redFlags': redFlags,
      'nextSteps': nextSteps,
      'recommendedFacility': recommendedFacility,
      'facilityType': facilityType,
      'trafficReductionMessage': trafficReductionMessage,
      'facilityDistance': facilityDistance,
      'facilityTravelTime': facilityTravelTime,
    };
  }

  /// 📥 Create from Map
  factory TriageResult.fromMap(Map<String, dynamic> map) {
    return TriageResult(
      sessionId: map['sessionId'] ?? '',
      ctasLevel: map['ctasLevel'] ?? 5,
      urgencyDescription: map['urgencyDescription'] ?? '',
      reasoning: map['reasoning'] ?? '',
      recommendedAction: map['recommendedAction'] ?? '',
      confidenceScore: (map['confidenceScore'] ?? 0.0).toDouble(),
      estimatedWaitTime: map['estimatedWaitTime'] ?? '',
      requiresEmergency: map['requiresEmergency'] ?? false,
      language: map['language'] ?? 'en',
      analysisTimestamp: DateTime.parse(
        map['analysisTimestamp'] ?? DateTime.now().toIso8601String(),
      ),
      redFlags: List<String>.from(map['redFlags'] ?? []),
      nextSteps: List<String>.from(map['nextSteps'] ?? []),
      recommendedFacility: map['recommendedFacility'],
      facilityType: map['facilityType'],
      trafficReductionMessage: map['trafficReductionMessage'],
      facilityDistance: map['facilityDistance'],
      facilityTravelTime: map['facilityTravelTime'],
    );
  }

  /// 🚨 Static Emergency Keyword Detection
  static bool _containsEmergencyKeywords(String symptoms) {
    final emergencyKeywords = [
      'chest pain',
      'can\'t breathe',
      'shortness of breath',
      'unconscious',
      'severe bleeding',
      'heart attack',
      'stroke',
      'anaphylaxis',
      'severe allergic',
    ];

    final symptomsLower = symptoms.toLowerCase();
    return emergencyKeywords.any((keyword) => symptomsLower.contains(keyword));
  }
}

/// 👤 Patient Information Model
class PatientInfo {
  final String id;
  final String? name;
  final int? age;
  final String? gender;
  final String preferredLanguage;
  final List<String> allergies;
  final List<String> medications;
  final List<String> medicalHistory;
  final Map<String, dynamic>? vitalSigns;
  final DateTime createdAt;

  PatientInfo({
    required this.id,
    this.name,
    this.age,
    this.gender,
    this.preferredLanguage = 'en',
    this.allergies = const [],
    this.medications = const [],
    this.medicalHistory = const [],
    this.vitalSigns,
    required this.createdAt,
  });

  /// 🔄 Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'preferredLanguage': preferredLanguage,
      'allergies': allergies,
      'medications': medications,
      'medicalHistory': medicalHistory,
      'vitalSigns': vitalSigns,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 📥 Create from Map
  factory PatientInfo.fromMap(Map<String, dynamic> map) {
    return PatientInfo(
      id: map['id'] ?? '',
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      preferredLanguage: map['preferredLanguage'] ?? 'en',
      allergies: List<String>.from(map['allergies'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      medicalHistory: List<String>.from(map['medicalHistory'] ?? []),
      vitalSigns: map['vitalSigns'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// 🆔 Create Anonymous Patient
  factory PatientInfo.anonymous({String language = 'en'}) {
    return PatientInfo(
      id: const Uuid().v4(),
      preferredLanguage: language,
      createdAt: DateTime.now(),
    );
  }
}

/// 🏥 Healthcare Provider Model
class HealthcareProvider {
  final String id;
  final String name;
  final String type; // 'hospital', 'clinic', 'urgent_care'
  final List<String> specialties;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> supportedLanguages;
  final double currentCapacity; // 0.0-1.0
  final Duration averageWaitTime;
  final bool acceptsEmergency;
  final bool acceptsWalkIns;
  final Map<String, dynamic> operatingHours;
  final double rating;
  final int reviewCount;

  HealthcareProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.specialties,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.supportedLanguages = const ['en'],
    this.currentCapacity = 0.5,
    this.averageWaitTime = const Duration(minutes: 30),
    this.acceptsEmergency = false,
    this.acceptsWalkIns = true,
    this.operatingHours = const {},
    this.rating = 4.0,
    this.reviewCount = 0,
  });

  /// 📍 Calculate Distance from Patient
  double calculateDistance(double patientLat, double patientLon) {
    // Simple distance calculation (for demo - use proper geo library in production)
    final latDiff = latitude - patientLat;
    final lonDiff = longitude - patientLon;
    return (latDiff * latDiff + lonDiff * lonDiff) *
        111.0; // Rough km conversion
  }

  /// ⏱️ Get Estimated Wait Time with Capacity
  Duration getEstimatedWaitTime() {
    final baseMinutes = averageWaitTime.inMinutes;
    final capacityMultiplier = 1.0 + currentCapacity;
    return Duration(minutes: (baseMinutes * capacityMultiplier).round());
  }

  /// 🎯 Calculate Match Score for Patient
  double calculateMatchScore({
    required TriageResult triage,
    required PatientInfo patient,
    required double distanceKm,
  }) {
    double score = 0.0;

    // Urgency match (40%)
    if (triage.requiresEmergency && acceptsEmergency) {
      score += 0.4;
    } else if (!triage.requiresEmergency && acceptsWalkIns) {
      score += 0.3;
    }

    // Distance factor (25%)
    final distanceScore = 1.0 - (distanceKm / 50.0).clamp(0.0, 1.0);
    score += distanceScore * 0.25;

    // Language support (20%)
    if (supportedLanguages.contains(patient.preferredLanguage)) {
      score += 0.2;
    }

    // Capacity availability (15%)
    final capacityScore = 1.0 - currentCapacity;
    score += capacityScore * 0.15;

    return score.clamp(0.0, 1.0);
  }

  /// 🔄 Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'specialties': specialties,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'supportedLanguages': supportedLanguages,
      'currentCapacity': currentCapacity,
      'averageWaitTime': averageWaitTime.inMinutes,
      'acceptsEmergency': acceptsEmergency,
      'acceptsWalkIns': acceptsWalkIns,
      'operatingHours': operatingHours,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  /// 📥 Create from Map
  factory HealthcareProvider.fromMap(Map<String, dynamic> map) {
    return HealthcareProvider(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'clinic',
      specialties: List<String>.from(map['specialties'] ?? []),
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      supportedLanguages: List<String>.from(
        map['supportedLanguages'] ?? ['en'],
      ),
      currentCapacity: (map['currentCapacity'] ?? 0.5).toDouble(),
      averageWaitTime: Duration(minutes: map['averageWaitTime'] ?? 30),
      acceptsEmergency: map['acceptsEmergency'] ?? false,
      acceptsWalkIns: map['acceptsWalkIns'] ?? true,
      operatingHours: Map<String, dynamic>.from(map['operatingHours'] ?? {}),
      rating: (map['rating'] ?? 4.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }
}

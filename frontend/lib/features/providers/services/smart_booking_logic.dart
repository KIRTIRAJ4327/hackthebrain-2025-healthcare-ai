import 'dart:math';
import '../../../features/triage/models/triage_models.dart';
import 'enhanced_clinic_booking.dart';

/// 🧠 Smart Booking Logic System
///
/// Determines when and where patients should book appointments based on:
/// - CTAS triage levels (1-5)
/// - Symptom severity and urgency
/// - Facility capabilities
/// - Medical appropriateness
/// - Safety protocols
///
/// Key Principle: Only show booking options when medically appropriate
/// CTAS 1-2: NO booking (emergency only)
/// CTAS 3: LIMITED booking (urgent care only)
/// CTAS 4-5: FULL booking options available
class SmartBookingLogic {
  /// 🎯 Determine Booking Availability
  ///
  /// Core logic: Higher severity = fewer booking options
  /// Emergency cases bypass booking entirely
  static BookingDecision shouldAllowBooking({
    required TriageResult triageResult,
    required List<AvailableClinic> availableClinics,
    required String symptoms,
  }) {
    final ctasLevel = triageResult.ctasLevel;

    // CTAS 1: Emergency - No booking allowed
    if (ctasLevel == 1) {
      return BookingDecision(
        allowBooking: false,
        reason: 'IMMEDIATE_EMERGENCY',
        message:
            '🚨 IMMEDIATE EMERGENCY\n\nGo to emergency department immediately. Do not book - this is life-threatening.',
        urgencyLevel: 'CRITICAL',
        recommendedAction: 'EMERGENCY_DEPARTMENT',
        allowedFacilityTypes: [],
        showEmergencyButton: true,
        estimatedSeverity: 'LIFE_THREATENING',
      );
    }

    // CTAS 2: Urgent - No booking allowed
    if (ctasLevel == 2) {
      return BookingDecision(
        allowBooking: false,
        reason: 'POTENTIALLY_LIFE_THREATENING',
        message:
            '⚠️ URGENT CARE NEEDED\n\nGo to emergency or urgent care immediately. This cannot wait for booking.',
        urgencyLevel: 'HIGH',
        recommendedAction: 'EMERGENCY_OR_URGENT_CARE',
        allowedFacilityTypes: ['EMERGENCY', 'URGENT_CARE'],
        showEmergencyButton: true,
        estimatedSeverity: 'POTENTIALLY_SERIOUS',
      );
    }

    // CTAS 3: Limited urgent care booking only
    if (ctasLevel == 3) {
      final urgentClinics = availableClinics
          .where((clinic) => _canHandleUrgentCare(clinic))
          .toList();

      return BookingDecision(
        allowBooking: urgentClinics.isNotEmpty,
        reason: urgentClinics.isNotEmpty
            ? 'URGENT_CARE_AVAILABLE'
            : 'NO_URGENT_CARE',
        message: urgentClinics.isNotEmpty
            ? '⏰ URGENT BOOKING AVAILABLE\n\nFound urgent care facilities for your condition.'
            : '🏥 NO URGENT CARE AVAILABLE\n\nGo to emergency department.',
        urgencyLevel: 'MODERATE_HIGH',
        recommendedAction: 'URGENT_CARE_BOOKING',
        allowedFacilityTypes: ['URGENT_CARE'],
        availableClinics: urgentClinics,
        maxWaitTime: 30,
        estimatedSeverity: 'URGENT',
      );
    }

    // CTAS 4-5: Standard booking allowed
    return BookingDecision(
      allowBooking: true,
      reason: 'STANDARD_CARE_APPROPRIATE',
      message: ctasLevel == 4
          ? '📅 BOOKING RECOMMENDED\n\nYour condition can be treated at various facilities.'
          : '✅ FLEXIBLE BOOKING\n\nNon-urgent condition with full booking options.',
      urgencyLevel: ctasLevel == 4 ? 'MODERATE' : 'LOW',
      recommendedAction: 'STANDARD_BOOKING',
      allowedFacilityTypes: ['CLINIC', 'WALKIN', 'FAMILY_MEDICINE'],
      availableClinics: availableClinics,
      maxWaitTime: ctasLevel == 4 ? 60 : 120,
      estimatedSeverity: ctasLevel == 4 ? 'MODERATE' : 'MILD',
    );
  }

  /// 🏥 Check if Clinic Can Handle Urgent Care
  static bool _canHandleUrgentCare(AvailableClinic clinic) {
    final type = clinic.facilityType.toUpperCase();
    final name = clinic.name.toLowerCase();

    return type.contains('URGENT') ||
        type.contains('EMERGENCY') ||
        name.contains('hospital') ||
        name.contains('urgent');
  }

  /// 🚨 Generate Emergency Action Options
  static List<EmergencyAction> getEmergencyActions({
    required TriageResult triageResult,
    required double? userLatitude,
    required double? userLongitude,
  }) {
    final actions = <EmergencyAction>[];

    // Always include 911 for CTAS 1-2
    if (triageResult.ctasLevel <= 2) {
      actions.add(EmergencyAction(
        type: 'CALL_911',
        title: '📞 Call 911',
        description: 'Emergency medical services',
        actionUrl: 'tel:911',
        priority: 1,
        isImmediate: true,
      ));
    }

    // Find nearest emergency department
    actions.add(EmergencyAction(
      type: 'NEAREST_ER',
      title: '🏥 Nearest Emergency Room',
      description: 'Navigate to closest emergency department',
      actionUrl: _getNearestERUrl(userLatitude, userLongitude),
      priority: 2,
      isImmediate: triageResult.ctasLevel <= 2,
    ));

    // Health Link Ontario for non-critical
    if (triageResult.ctasLevel >= 3) {
      actions.add(EmergencyAction(
        type: 'HEALTH_LINK',
        title: '📞 Health Link Ontario',
        description: '24/7 health advice: 811',
        actionUrl: 'tel:811',
        priority: 3,
        isImmediate: false,
      ));
    }

    return actions;
  }

  /// 🗺️ Get Nearest Emergency Room URL
  static String _getNearestERUrl(double? latitude, double? longitude) {
    if (latitude != null && longitude != null) {
      return 'https://www.google.com/maps/search/emergency+room+hospital+near+me/@$latitude,$longitude,15z';
    }

    // Fallback to Toronto emergency departments
    return 'https://www.google.com/maps/search/emergency+room+hospital+toronto';
  }

  /// 📊 Filter Clinics by Appropriateness
  static List<AvailableClinic> filterClinicsForCondition({
    required List<AvailableClinic> allClinics,
    required TriageResult triageResult,
    required String symptoms,
  }) {
    final ctasLevel = triageResult.ctasLevel;

    return allClinics.where((clinic) {
      // CTAS 1-2: Only emergency facilities
      if (ctasLevel <= 2) {
        return _canHandleUrgentCare(clinic);
      }

      // CTAS 3: Urgent care and above
      if (ctasLevel == 3) {
        return _canHandleUrgentCare(clinic);
      }

      // CTAS 4-5: All standard care facilities
      if (ctasLevel >= 4) {
        return _canHandleStandardCare(clinic);
      }

      return false;
    }).toList();
  }

  /// 🏥 Check if Clinic Can Handle Standard Care
  static bool _canHandleStandardCare(AvailableClinic clinic) {
    final facilityType = clinic.facilityType.toUpperCase();

    // Most clinic types can handle standard care
    return [
      'CLINIC',
      'WALKIN',
      'FAMILY_MEDICINE',
      'URGENT_CARE',
      'MEDICAL_CENTER'
    ].any((type) => facilityType.contains(type));
  }

  /// ⚠️ Generate Safety Warnings
  static List<String> generateSafetyWarnings(TriageResult triageResult) {
    final warnings = <String>[];

    if (triageResult.ctasLevel == 1) {
      warnings.addAll([
        '🚨 This is a medical emergency',
        '⏱️ Every minute counts - seek help immediately',
        '📞 Call 911 if symptoms worsen',
        '🚫 Do not drive yourself to hospital',
      ]);
    }

    if (triageResult.ctasLevel == 2) {
      warnings.addAll([
        '⚠️ This condition could be serious',
        '⏰ Seek medical attention within 15 minutes',
        '📞 Call 911 if symptoms worsen rapidly',
        '🏥 Go directly to emergency or urgent care',
      ]);
    }

    if (triageResult.ctasLevel == 3) {
      warnings.addAll([
        '⏰ Medical attention needed within 30 minutes',
        '🏥 Urgent care or emergency department recommended',
        '📞 Call ahead to reduce wait time',
      ]);
    }

    return warnings;
  }
}

/// 📋 Booking Decision Result
class BookingDecision {
  final bool allowBooking;
  final String reason;
  final String message;
  final String urgencyLevel;
  final String recommendedAction;
  final List<String> allowedFacilityTypes;
  final List<AvailableClinic>? availableClinics;
  final bool showEmergencyButton;
  final int? maxWaitTime;
  final String estimatedSeverity;

  BookingDecision({
    required this.allowBooking,
    required this.reason,
    required this.message,
    required this.urgencyLevel,
    required this.recommendedAction,
    required this.allowedFacilityTypes,
    this.availableClinics,
    this.showEmergencyButton = false,
    this.maxWaitTime,
    required this.estimatedSeverity,
  });

  /// 📊 Get UI Display Information
  Map<String, dynamic> getDisplayInfo() {
    return {
      'allowBooking': allowBooking,
      'urgencyColor': _getUrgencyColor(),
      'urgencyIcon': _getUrgencyIcon(),
      'message': message,
      'actionRequired': recommendedAction,
      'safetyLevel': estimatedSeverity,
      'clinicCount': availableClinics?.length ?? 0,
      'maxWaitMinutes': maxWaitTime,
    };
  }

  String _getUrgencyColor() {
    switch (urgencyLevel) {
      case 'CRITICAL':
        return '#DC2626'; // Red
      case 'HIGH':
        return '#F59E0B'; // Orange
      case 'MODERATE_HIGH':
        return '#D97706'; // Dark Orange
      case 'MODERATE':
        return '#059669'; // Green
      case 'LOW':
        return '#10B981'; // Light Green
      default:
        return '#6B7280'; // Gray
    }
  }

  String _getUrgencyIcon() {
    switch (urgencyLevel) {
      case 'CRITICAL':
        return '🚨';
      case 'HIGH':
        return '⚠️';
      case 'MODERATE_HIGH':
        return '⏰';
      case 'MODERATE':
        return '📅';
      case 'LOW':
        return '✅';
      default:
        return '🔍';
    }
  }
}

/// 🚨 Emergency Action Option
class EmergencyAction {
  final String type;
  final String title;
  final String description;
  final String actionUrl;
  final int priority;
  final bool isImmediate;

  EmergencyAction({
    required this.type,
    required this.title,
    required this.description,
    required this.actionUrl,
    required this.priority,
    required this.isImmediate,
  });
}

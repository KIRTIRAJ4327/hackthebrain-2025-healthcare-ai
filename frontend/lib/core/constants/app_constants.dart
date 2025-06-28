import 'package:flutter/material.dart';

/// 🏥 Healthcare AI App Constants
/// Contains all the constant values used throughout the application
class AppConstants {
  // App Information
  static const String appName = 'Healthcare AI Orchestration';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Reducing wait times from 30 weeks to 12-18 weeks';

  // API Endpoints
  static const String baseApiUrl = 'https://api.hackthebrain-healthcare.com';
  static const String aiServiceUrl = 'https://ai.hackthebrain-healthcare.com';

  // Google API Keys (from environment)
  static const String googleMapsApiKey =
      'AIzaSyDU_FzWafxPvEDbUsVDM3g5fcZgRtGa_88';
  static const String googleCalendarApiKey =
      'AIzaSyCM4s34yndHCvfJxyoI7LGyiZLveFX2TKQ';
  static const String googleGeminiApiKey =
      'AIzaSyCaQBh8728RE-THxYwODkyfwTmlgSlt9CQ';
  static const String googleTranslateApiKey =
      'AIzaSyBihIzOTMJmAxqwa1umqoxCAut1kwrsNcI';

  // Medical Triage Constants
  static const Map<String, String> ctasLevels = {
    'RED': 'Level 1 - Resuscitation (Immediate)',
    'ORANGE': 'Level 2 - Emergent (15 minutes)',
    'YELLOW': 'Level 3 - Urgent (30 minutes)',
    'GREEN': 'Level 4 - Less Urgent (60 minutes)',
    'BLUE': 'Level 5 - Non-urgent (120 minutes)',
  };

  static const Map<String, Color> ctasColors = {
    'RED': Color(0xFFE53E3E),
    'ORANGE': Color(0xFFFF8C00),
    'YELLOW': Color(0xFFECC94B),
    'GREEN': Color(0xFF38A169),
    'BLUE': Color(0xFF3182CE),
  };

  // Time Constants
  static const int triageTimeoutSeconds = 30;
  static const int appointmentBufferMinutes = 15;
  static const int maxWaitTimeWeeks = 30;
  static const int targetWaitTimeWeeks = 12;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashAnimationDuration = Duration(milliseconds: 2000);

  // Security Constants
  static const int maxLoginAttempts = 3;
  static const int sessionTimeoutMinutes = 30;
  static const double minConfidenceScore = 0.95;

  // Healthcare Specialties
  static const List<String> medicalSpecialties = [
    'Cardiology',
    'Dermatology',
    'Endocrinology',
    'Gastroenterology',
    'General Practice',
    'Neurology',
    'Oncology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'Surgery',
    'Urology',
  ];

  // Emergency Keywords (for immediate escalation)
  static const List<String> emergencyKeywords = [
    'chest pain',
    'shortness of breath',
    'unconscious',
    'severe bleeding',
    'stroke symptoms',
    'heart attack',
    'severe allergic reaction',
    'difficulty breathing',
    'severe trauma',
    'poisoning',
  ];

  // Success Metrics
  static const Map<String, dynamic> impactMetrics = {
    'livesAnnualSavings': 1500,
    'costSavingsMillions': 170,
    'waitTimeReductionPercent': 50,
    'targetUtilizationPercent': 90,
    'currentWaitWeeks': 30,
    'targetWaitWeeks': 12,
  };

  // Demo Scenarios for Judges
  static const Map<String, String> demoScenarios = {
    'emergency': '45-year-old with chest pain + shortness of breath',
    'system_resilience': 'Cardiology clinic closure affecting 50 patients',
    'predictive_analytics': 'Flu season surge detection and capacity planning',
  };
}

/// Medical Priority Levels following CTAS (Canadian Triage and Acuity Scale)
enum MedicalPriority {
  red('RED', 'Resuscitation', 0),
  orange('ORANGE', 'Emergent', 15),
  yellow('YELLOW', 'Urgent', 30),
  green('GREEN', 'Less Urgent', 60),
  blue('BLUE', 'Non-urgent', 120);

  const MedicalPriority(this.code, this.description, this.maxWaitMinutes);

  final String code;
  final String description;
  final int maxWaitMinutes;
}

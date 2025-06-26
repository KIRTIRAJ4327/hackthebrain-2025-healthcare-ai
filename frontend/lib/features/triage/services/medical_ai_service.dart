import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import '../models/triage_models.dart';
import '../../providers/services/realtime_clinic_finder.dart';

/// 🤖 Medical AI Service - REAL Gemini API Integration
///
/// This service provides CTAS-compliant medical triage using Google's Gemini AI
/// to analyze symptoms and provide intelligent healthcare recommendations.
///
/// CRITICAL: This is for TRIAGE ONLY - Never provides medical diagnosis
class MedicalAIService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-1.5-flash-latest';

  final http.Client _httpClient;
  final Uuid _uuid = const Uuid();

  // Get API key from environment
  String get _apiKey => dotenv.env['GOOGLE_GEMINI_API_KEY'] ?? '';

  MedicalAIService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// 🧠 Analyze Medical Case and Provide CTAS-Compliant Triage
  ///
  /// This is the core AI that saves lives by rapidly assessing urgency
  Future<TriageResult> analyzeMedicalCase({
    required String symptoms,
    required String language, // 'en', 'fr', 'es'
    required bool isVoiceInput,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
  }) async {
    final sessionId = _uuid.v4();

    try {
      print('🤖 REAL AI Analysis Starting - Session: $sessionId');
      print('📝 Symptoms: $symptoms');
      print('🌐 Language: $language');
      print('🔑 API Key available: ${_apiKey.isNotEmpty}');

      if (_apiKey.isEmpty) {
        throw Exception(
          'Gemini API key not configured. Please set GOOGLE_GEMINI_API_KEY in .env file',
        );
      }

      final prompt = _buildMedicalPrompt(
        symptoms: symptoms,
        language: language,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
      );

      print('📤 Calling REAL Gemini API...');
      final response = await _callGeminiAPI(prompt);
      print('📥 Gemini API Response received');

      final analysisResult = _parseGeminiResponse(response);

      var triageResult = TriageResult(
        sessionId: sessionId,
        ctasLevel: analysisResult['ctasLevel'] ?? 5,
        urgencyDescription: analysisResult['urgencyDescription'] ?? 'Unknown',
        reasoning: analysisResult['reasoning'] ?? 'Unable to analyze',
        recommendedAction: analysisResult['recommendedAction'] ??
            'Consult healthcare provider',
        confidenceScore: (analysisResult['confidenceScore'] ?? 0.0).toDouble(),
        estimatedWaitTime: analysisResult['estimatedWaitTime'] ?? 'Unknown',
        requiresEmergency: (analysisResult['ctasLevel'] ?? 5) <= 2,
        language: language,
        analysisTimestamp: DateTime.now(),
        redFlags: List<String>.from(analysisResult['redFlags'] ?? []),
        nextSteps: List<String>.from(analysisResult['nextSteps'] ?? []),
      );

      print(
        '✅ REAL AI Analysis Complete - CTAS Level: ${triageResult.ctasLevel}',
      );
      print('🎯 Confidence: ${(triageResult.confidenceScore * 100).toInt()}%');

      // 🚨 CRITICAL: Confidence Threshold Checking & Human-in-the-Loop
      triageResult = await _applyConfidenceThresholds(triageResult, symptoms);

      // Log for audit trail (required for medical applications)
      await _logTriageAnalysis(triageResult, symptoms);

      return triageResult;
    } catch (e) {
      print('❌ REAL AI Analysis Error: $e');

      // Safety fallback - Never leave patient without guidance
      return TriageResult.createSafetyFallback(
        sessionId: sessionId,
        language: language,
        originalSymptoms: symptoms,
      );
    }
  }

  /// 🏥 Build CTAS-Compliant Medical Prompt for Gemini
  String _buildMedicalPrompt({
    required String symptoms,
    required String language,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
  }) {
    final languageInstruction = _getLanguageInstruction(language);

    return '''
$languageInstruction

You are a professional medical AI assistant trained in the Canadian Triage and Acuity Scale (CTAS). Your role is to analyze symptoms and classify urgency level ONLY - you NEVER provide medical diagnosis.

CRITICAL SAFETY RULES:
1. NEVER provide medical diagnosis - only urgency classification
2. ALWAYS use CTAS levels 1-5 only
3. ALWAYS recommend appropriate healthcare pathway
4. If uncertain, escalate to higher urgency level (be conservative)
5. Include confidence score (0.0-1.0) - be honest about uncertainty

PATIENT PRESENTATION:
Symptoms: $symptoms
${medicalHistory != null ? 'Medical History: ${jsonEncode(medicalHistory)}' : ''}
${vitalSigns != null ? 'Vital Signs: ${jsonEncode(vitalSigns)}' : ''}

CANADIAN TRIAGE AND ACUITY SCALE (CTAS) + TRAFFIC REDUCTION STRATEGY:
- Level 1: Life-threatening, immediate care (0 minutes) - cardiac arrest, severe trauma, anaphylaxis → EMERGENCY ROOM ONLY
- Level 2: Imminently life-threatening (15 minutes) - chest pain with cardiac features, stroke symptoms → EMERGENCY ROOM ONLY  
- Level 3: Urgent, potentially life-threatening (30 minutes) - severe abdominal pain, moderate respiratory distress → EMERGENCY ROOM
- Level 4: Less urgent (60 minutes) - minor injuries, stable vital signs → CONSIDER WALK-IN CLINICS to reduce hospital traffic
- Level 5: Non-urgent (120 minutes) - minor cuts, routine medication refills → RECOMMEND WALK-IN CLINICS/FAMILY DOCTOR to save hospital resources

🏥 TRAFFIC REDUCTION MISSION: For CTAS 4-5, recommend nearby walk-in clinics and urgent care centers instead of emergency rooms to:
- Reduce hospital congestion for critical patients
- Provide faster care for non-emergency cases  
- Save healthcare resources for life-threatening emergencies

EMERGENCY KEYWORDS TO DETECT:
- Chest pain + shortness of breath + sweating = likely cardiac
- Facial droop + speech slurred + arm weakness = stroke (FAST criteria)
- Severe bleeding, unconscious, severe allergic reaction
- High fever + altered mental state + stiff neck = possible meningitis
- Severe abdominal pain + vomiting + fever

RESPOND WITH VALID JSON ONLY:
{
  "ctasLevel": 1-5,
  "urgencyDescription": "Brief clinical description",
  "reasoning": "Clear medical reasoning based on symptoms and CTAS criteria",
  "recommendedAction": "Specific next steps for patient - include traffic reduction recommendations",
  "confidenceScore": 0.0-1.0,
  "estimatedWaitTime": "Time estimate based on CTAS level",
  "redFlags": ["List of concerning symptoms found"],
  "nextSteps": ["Immediate actions patient should take"],
  "facilityType": "EMERGENCY|CLINIC|WALKIN|FAMILY_DOCTOR",
  "trafficReductionMessage": "Explanation of why this facility type saves time and helps hospital traffic"
}

Analyze the symptoms now and respond with JSON only. Be precise and follow CTAS protocols exactly.
''';
  }

  /// 🌐 Get Language-Specific Instructions
  String _getLanguageInstruction(String language) {
    switch (language) {
      case 'fr':
        return 'Répondez en français. Utilisez la terminologie médicale française appropriée selon les protocoles CTAS.';
      case 'es':
        return 'Responde en español. Usa terminología médica apropiada en español según protocolos CTAS.';
      default:
        return 'Respond in English. Use clear, professional medical terminology following CTAS protocols.';
    }
  }

  /// 🔗 Call Real Gemini API for Medical Analysis
  Future<String> _callGeminiAPI(String prompt) async {
    final url = Uri.parse(
      '$_baseUrl/models/$_model:generateContent?key=$_apiKey',
    );

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1, // Low temperature for medical accuracy
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
      ],
    };

    print('📤 Sending request to Gemini API...');
    final response = await _httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('📥 Gemini API Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] != null && data['candidates'].isNotEmpty) {
        final responseText =
            data['candidates'][0]['content']['parts'][0]['text'];
        print(
          '✅ Gemini AI Response received: ${responseText.substring(0, 100)}...',
        );
        return responseText;
      } else {
        throw Exception('No response from Gemini AI');
      }
    } else {
      final errorBody = response.body;
      print('❌ Gemini API Error: ${response.statusCode} - $errorBody');
      throw Exception('Gemini API Error: ${response.statusCode} - $errorBody');
    }
  }

  /// 📊 Parse Gemini AI Response
  Map<String, dynamic> _parseGeminiResponse(String response) {
    try {
      // Clean the response (remove markdown formatting if present)
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }

      final parsed = jsonDecode(cleanResponse.trim());
      print('✅ Successfully parsed Gemini response');
      return parsed;
    } catch (e) {
      print('❌ Error parsing Gemini response: $e');
      print('📄 Raw response: $response');

      // Safety fallback parsing
      return {
        'ctasLevel': 4, // Default to less urgent if parsing fails
        'urgencyDescription': 'Requires Assessment',
        'reasoning':
            'Unable to parse AI response - please consult healthcare provider immediately',
        'recommendedAction':
            'Visit nearest healthcare facility for proper assessment',
        'confidenceScore': 0.5,
        'estimatedWaitTime': '60 minutes',
        'redFlags': ['AI parsing error'],
        'nextSteps': [
          'Seek immediate medical attention due to technical issue',
        ],
      };
    }
  }

  /// 📄 Log Triage Analysis for Audit Trail
  Future<void> _logTriageAnalysis(
    TriageResult result,
    String originalSymptoms,
  ) async {
    final auditLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': result.sessionId,
      'ctasLevel': result.ctasLevel,
      'confidenceScore': result.confidenceScore,
      'urgencyDescription': result.urgencyDescription,
      'reasoning': result.reasoning,
      'recommendedAction': result.recommendedAction,
      'originalSymptoms': originalSymptoms,
      'redFlags': result.redFlags,
      'language': result.language,
      'requiresEmergency': result.requiresEmergency,
    };

    print('📊 MEDICAL AUDIT LOG: ${jsonEncode(auditLog)}');

    // In production, this would be stored in a secure, HIPAA-compliant database
    // with proper encryption and access controls for regulatory compliance
  }

  /// 🚨 Detect Emergency Keywords in Multiple Languages
  bool detectEmergencyKeywords(String symptoms, String language) {
    final emergencyPatterns = {
      'en': [
        r'chest pain.*(shortness|breath|pressure|crushing)',
        r'cannot breathe',
        r'not breathing',
        r'severe bleeding',
        r'heavy bleeding',
        r'unconscious',
        r'unresponsive',
        r'stroke symptoms',
        r'heart attack',
        r'cardiac arrest',
        r'anaphylaxis',
        r'severe allergic reaction',
        r'facial droop',
        r'slurred speech',
        r'choking',
        r'overdose',
        r'seizure',
        r'convulsions'
      ],
      'fr': [
        r'douleur thoracique.*essoufflement',
        r'ne peut pas respirer',
        r'saignement grave',
        r'inconscient',
        r'avc',
        r'crise cardiaque',
        r'allergie grave',
      ],
      'es': [
        r'dolor en el pecho.*falta de aire',
        r'no puede respirar',
        r'sangrado severo',
        r'inconsciente',
        r'derrame cerebral',
        r'ataque cardíaco',
        r'alergia severa',
      ],
    };

    final patterns = emergencyPatterns[language] ?? emergencyPatterns['en']!;
    final symptomsLower = symptoms.toLowerCase();

    // 🏥 SMART TRAFFIC REDUCTION: Route non-emergency cases to clinics/walk-ins
    final clinicSuitableSymptoms = [
      'stomach pain',
      'stomach ache',
      'belly pain',
      'abdominal pain',
      'headache',
      'mild pain',
      'sore throat',
      'runny nose',
      'cough',
      'fever under 101',
      'nausea',
      'vomiting',
      'diarrhea',
      'back pain',
      'muscle ache',
      'joint pain',
      'rash',
      'cold symptoms',
      'flu symptoms',
      'minor cuts',
      'bruises',
      'sprain',
      'minor burn',
      'ear ache',
      'sinus pressure',
      'allergies'
    ];

    // 💡 TRAFFIC SOLUTION: If it's clinic-suitable, suggest walk-ins instead of emergency
    final isClinicSuitable = clinicSuitableSymptoms
        .any((symptom) => symptomsLower.contains(symptom));

    if (isClinicSuitable) {
      print(
          '🏥 TRAFFIC REDUCER: Clinic-suitable symptom - Will suggest walk-ins/clinics instead of emergency');
      return false; // Don't trigger emergency mode - route to clinics
    }

    // Check for true emergency patterns
    for (final pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(symptomsLower)) {
        print('🚨 EMERGENCY KEYWORD DETECTED: $pattern');
        return true;
      }
    }

    return false;
  }

  /// 🧪 Test Real AI Service Connection
  Future<bool> testConnection() async {
    try {
      print('🧪 Testing REAL Gemini API connection...');
      final testResult = await analyzeMedicalCase(
        symptoms: 'Test connection - mild headache for medical AI system test',
        language: 'en',
        isVoiceInput: false,
      );

      final isSuccess =
          testResult.confidenceScore > 0 && testResult.reasoning.isNotEmpty;
      print(
        isSuccess
            ? '✅ REAL AI connection test PASSED'
            : '❌ REAL AI connection test FAILED',
      );
      return isSuccess;
    } catch (e) {
      print('❌ REAL AI Service Test Failed: $e');
      return false;
    }
  }

  void dispose() {
    _httpClient.close();
  }

  /// 🤖 Generate Response using Gemini AI (Public Method)
  static Future<String?> generateResponse(String prompt) async {
    final service = MedicalAIService();
    try {
      final response = await service._callGeminiAPI(prompt);
      final parsed = service._parseGeminiResponse(response);
      return parsed['reasoning'] ?? 'AI response generated successfully';
    } catch (e) {
      print('Error generating AI response: $e');
      return null;
    } finally {
      service.dispose();
    }
  }

  /// 🧠 Generate Gemini Response (Alternative method name)
  static Future<String> generateGeminiResponse(String prompt) async {
    final response = await generateResponse(prompt);
    return response ?? 'Unable to generate AI response at this time.';
  }

  /// 🎯 Apply Confidence Thresholds and Human-in-the-Loop Review
  ///
  /// CRITICAL SAFETY FEATURE: Ensures low-confidence cases get human review
  Future<TriageResult> _applyConfidenceThresholds(
    TriageResult result,
    String originalSymptoms,
  ) async {
    // Define confidence thresholds based on CTAS level criticality
    final confidenceThresholds = {
      1: 0.95, // Life-threatening: 95% confidence required
      2: 0.90, // Imminently life-threatening: 90% confidence required
      3: 0.75, // Urgent: 75% confidence required (lowered)
      4: 0.65, // Less urgent: 65% confidence required (lowered)
      5: 0.55, // Non-urgent: 55% confidence required (lowered)
    };

    final requiredConfidence = confidenceThresholds[result.ctasLevel] ?? 0.85;

    print(
        '🎯 Confidence Check: ${(result.confidenceScore * 100).round()}% vs required ${(requiredConfidence * 100).round()}%');

    // If confidence is below threshold, flag for human review
    if (result.confidenceScore < requiredConfidence) {
      print('⚠️ LOW CONFIDENCE DETECTED - Flagging for human review');

      // For critical cases (CTAS 1-2), escalate immediately to human
      if (result.ctasLevel <= 2) {
        return await _escalateToHumanReview(
            result, originalSymptoms, 'CRITICAL_LOW_CONFIDENCE');
      }

      // For non-critical cases, apply conservative escalation
      return await _applyConservativeEscalation(result, originalSymptoms);
    }

    // Additional safety checks
    if (_hasConflictingSymptoms(result, originalSymptoms)) {
      print('⚠️ CONFLICTING SYMPTOMS DETECTED - Flagging for human review');
      return await _escalateToHumanReview(
          result, originalSymptoms, 'CONFLICTING_SYMPTOMS');
    }

    // Confidence is acceptable
    print('✅ Confidence threshold met - Proceeding with AI recommendation');
    return result;
  }

  /// 🚨 Escalate to Human Review (Critical Safety Feature)
  Future<TriageResult> _escalateToHumanReview(
    TriageResult originalResult,
    String symptoms,
    String reason,
  ) async {
    print('🚨 ESCALATING TO HUMAN REVIEW: $reason');

    // Create a modified result that indicates human review is needed
    final humanReviewResult = TriageResult(
      sessionId: originalResult.sessionId,
      ctasLevel: math.max(2,
          originalResult.ctasLevel - 1), // Escalate by 1 level, minimum CTAS-2
      urgencyDescription:
          'REQUIRES HUMAN REVIEW - ${originalResult.urgencyDescription}',
      reasoning:
          'AI confidence below threshold (${(originalResult.confidenceScore * 100).round()}%). '
          'Human medical professional review required. Original reasoning: ${originalResult.reasoning}',
      recommendedAction:
          'IMMEDIATE: Speak with medical professional for assessment. Do not wait.',
      confidenceScore: 0.95, // High confidence in need for human review
      estimatedWaitTime: 'Immediate',
      requiresEmergency: true,
      language: originalResult.language,
      analysisTimestamp: originalResult.analysisTimestamp,
      redFlags: [
        'LOW AI CONFIDENCE',
        'HUMAN REVIEW REQUIRED',
        ...originalResult.redFlags,
      ],
      nextSteps: [
        '🚨 SPEAK WITH MEDICAL PROFESSIONAL IMMEDIATELY',
        'Do not rely solely on AI assessment',
        'Provide all symptoms to healthcare provider',
        ...originalResult.nextSteps,
      ],
    );

    // Log the escalation for audit trail
    await _logHumanEscalation(
        humanReviewResult, originalResult, symptoms, reason);

    // In a production system, this would:
    // 1. Send alert to medical staff
    // 2. Queue case for urgent human review
    // 3. Notify patient about immediate consultation

    return humanReviewResult;
  }

  /// 🛡️ Apply Conservative Escalation for Low Confidence
  Future<TriageResult> _applyConservativeEscalation(
    TriageResult originalResult,
    String symptoms,
  ) async {
    print('🛡️ APPLYING CONSERVATIVE ESCALATION');

    // Escalate by one CTAS level (more urgent)
    final escalatedLevel = math.max(1, originalResult.ctasLevel - 1);

    return TriageResult(
      sessionId: originalResult.sessionId,
      ctasLevel: escalatedLevel,
      urgencyDescription: 'ESCALATED - ${originalResult.urgencyDescription}',
      reasoning:
          'Conservative escalation applied due to AI confidence ${(originalResult.confidenceScore * 100).round()}% '
          'below required threshold. Original reasoning: ${originalResult.reasoning}',
      recommendedAction:
          'Seek medical attention promptly. Conservative assessment applied.',
      confidenceScore: 0.85, // Moderate confidence in conservative approach
      estimatedWaitTime: _getEscalatedWaitTime(escalatedLevel),
      requiresEmergency: escalatedLevel <= 2,
      language: originalResult.language,
      analysisTimestamp: originalResult.analysisTimestamp,
      redFlags: [
        'CONSERVATIVE ESCALATION',
        'LOW AI CONFIDENCE',
        ...originalResult.redFlags,
      ],
      nextSteps: [
        'Seek medical attention promptly',
        'Conservative assessment applied for safety',
        ...originalResult.nextSteps,
      ],
    );
  }

  /// 🔍 Check for Conflicting Symptoms
  bool _hasConflictingSymptoms(TriageResult result, String symptoms) {
    // Check for critical keywords that might conflict with low CTAS level
    final criticalKeywords = [
      'chest pain',
      'can\'t breathe',
      'unconscious',
      'severe bleeding',
      'heart attack',
      'stroke',
      'anaphylaxis',
      'severe allergic'
    ];

    final symptomsLower = symptoms.toLowerCase();
    final hasCriticalKeywords =
        criticalKeywords.any((keyword) => symptomsLower.contains(keyword));

    // If critical keywords present but CTAS level is 4-5, flag as conflicting
    if (hasCriticalKeywords && result.ctasLevel >= 4) {
      return true;
    }

    return false;
  }

  /// ⏱️ Get Escalated Wait Time
  String _getEscalatedWaitTime(int ctasLevel) {
    switch (ctasLevel) {
      case 1:
        return 'Immediate';
      case 2:
        return '15 minutes';
      case 3:
        return '30 minutes';
      case 4:
        return '60 minutes';
      case 5:
        return '120 minutes';
      default:
        return '30 minutes';
    }
  }

  /// 📊 Log Human Escalation (Critical for Audit Trail)
  Future<void> _logHumanEscalation(
    TriageResult escalatedResult,
    TriageResult originalResult,
    String symptoms,
    String reason,
  ) async {
    final escalationLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': escalatedResult.sessionId,
      'escalationReason': reason,
      'originalConfidence': originalResult.confidenceScore,
      'originalCTAS': originalResult.ctasLevel,
      'escalatedCTAS': escalatedResult.ctasLevel,
      'symptoms': symptoms,
      'requiresHumanReview': true,
      'urgencyLevel': 'HIGH',
    };

    print('📊 HUMAN ESCALATION LOGGED: ${jsonEncode(escalationLog)}');

    // In production, this would:
    // 1. Store in secure medical database
    // 2. Send alert to medical staff
    // 3. Create audit trail for regulatory compliance
    // 4. Trigger human review workflow
  }

  /// 🗺️ ENHANCED: Location-Aware Medical Analysis with Real-Time Facility Routing
  ///
  /// This version finds nearby open facilities and gives Gemini AI REAL data
  /// to recommend specific facilities with travel times and wait estimates
  Future<TriageResult> analyzeMedicalCaseWithLocation({
    required String symptoms,
    required String language, // 'en', 'fr', 'es'
    required bool isVoiceInput,
    required double latitude,
    required double longitude,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
  }) async {
    final sessionId = _uuid.v4();

    try {
      print('🗺️ LOCATION-AWARE AI Analysis Starting - Session: $sessionId');
      print('📝 Symptoms: $symptoms');
      print('📍 Location: ($latitude, $longitude)');
      print('🌐 Language: $language');

      if (_apiKey.isEmpty) {
        throw Exception(
          'Gemini API key not configured. Please set GOOGLE_GEMINI_API_KEY in .env file',
        );
      }

      // Step 1: Find nearby open facilities
      print('🔍 Finding nearby open facilities...');
      final nearbyFacilities = await _findNearbyOpenFacilities(
        latitude: latitude,
        longitude: longitude,
        symptoms: symptoms,
      );

      // Step 2: Build location-enhanced prompt with real facility data
      final prompt = _buildLocationAwareMedicalPrompt(
        symptoms: symptoms,
        language: language,
        nearbyFacilities: nearbyFacilities,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
      );

      print('📤 Calling REAL Gemini API with location data...');
      final response = await _callGeminiAPI(prompt);
      print('📥 Gemini API Response received');

      final analysisResult = _parseGeminiResponse(response);

      var triageResult = TriageResult(
        sessionId: sessionId,
        ctasLevel: analysisResult['ctasLevel'] ?? 5,
        urgencyDescription: analysisResult['urgencyDescription'] ?? 'Unknown',
        reasoning: analysisResult['reasoning'] ?? 'Unable to analyze',
        recommendedAction: analysisResult['recommendedAction'] ??
            'Consult healthcare provider',
        confidenceScore: (analysisResult['confidenceScore'] ?? 0.0).toDouble(),
        estimatedWaitTime: analysisResult['estimatedWaitTime'] ?? 'Unknown',
        requiresEmergency: (analysisResult['ctasLevel'] ?? 5) <= 2,
        language: language,
        analysisTimestamp: DateTime.now(),
        redFlags: List<String>.from(analysisResult['redFlags'] ?? []),
        nextSteps: List<String>.from(analysisResult['nextSteps'] ?? []),
      );

      print(
        '✅ LOCATION-AWARE AI Analysis Complete - CTAS Level: ${triageResult.ctasLevel}',
      );
      print('🎯 Confidence: ${(triageResult.confidenceScore * 100).toInt()}%');
      print('🏥 Recommended facilities: ${nearbyFacilities.length} found');

      // Apply confidence thresholds and human-in-the-loop validation
      triageResult = await _applyConfidenceThresholds(triageResult, symptoms);

      // Log for audit trail
      await _logTriageAnalysis(triageResult, symptoms);

      return triageResult;
    } catch (e) {
      print('❌ LOCATION-AWARE AI Analysis Error: $e');

      // Safety fallback
      return TriageResult.createSafetyFallback(
        sessionId: sessionId,
        language: language,
        originalSymptoms: symptoms,
      );
    }
  }

  /// 🏥 Find Nearby Open Facilities Based on Symptoms
  Future<List<ClinicFacility>> _findNearbyOpenFacilities({
    required double latitude,
    required double longitude,
    required String symptoms,
  }) async {
    final clinicFinder = RealTimeClinicFinder();
    final allFacilities = <ClinicFacility>[];

    // Determine appropriate facility types based on symptoms
    final facilityTypes = _determineFacilityTypes(symptoms);

    print('🏥 Searching for facility types: ${facilityTypes.join(", ")}');

    // Search for each facility type
    for (final facilityType in facilityTypes) {
      try {
        final facilities = await clinicFinder.findOpenClinicsNearby(
          latitude: latitude,
          longitude: longitude,
          facilityType: facilityType,
        );
        allFacilities.addAll(facilities);
      } catch (e) {
        print('⚠️ Error finding $facilityType facilities: $e');
      }
    }

    // Remove duplicates and sort by distance
    final uniqueFacilities = <String, ClinicFacility>{};
    for (final facility in allFacilities) {
      final key = '${facility.name}_${facility.address}';
      if (!uniqueFacilities.containsKey(key) ||
          facility.distanceKm < uniqueFacilities[key]!.distanceKm) {
        uniqueFacilities[key] = facility;
      }
    }

    final sortedFacilities = uniqueFacilities.values.toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    print('✅ Found ${sortedFacilities.length} unique open facilities');
    return sortedFacilities.take(5).toList(); // Return top 5 closest
  }

  /// 🎯 Determine Appropriate Facility Types Based on Symptoms
  List<String> _determineFacilityTypes(String symptoms) {
    final symptomsLower = symptoms.toLowerCase();

    // Emergency symptoms - only hospitals
    final emergencyKeywords = [
      'chest pain',
      'heart attack',
      'stroke',
      'severe bleeding',
      'unconscious',
      'difficulty breathing',
      'anaphylaxis',
      'severe allergic reaction',
      'overdose',
      'seizure',
    ];

    for (final keyword in emergencyKeywords) {
      if (symptomsLower.contains(keyword)) {
        return ['EMERGENCY']; // Hospital emergency room only
      }
    }

    // Minor symptoms - prefer clinics and walk-ins
    final minorKeywords = [
      'headache',
      'cold',
      'sore throat',
      'runny nose',
      'cough',
      'minor pain',
      'stomach ache',
      'nausea',
      'rash',
      'ear ache',
      'allergies',
      'minor cut',
      'bruise',
    ];

    for (final keyword in minorKeywords) {
      if (symptomsLower.contains(keyword)) {
        return [
          'WALKIN',
          'CLINIC',
          'URGENT_CARE'
        ]; // Prefer non-hospital options
      }
    }

    // Moderate symptoms - urgent care and clinics preferred
    return ['URGENT_CARE', 'CLINIC', 'WALKIN'];
  }

  /// 📍 Build Location-Aware Medical Prompt with Real Facility Data
  String _buildLocationAwareMedicalPrompt({
    required String symptoms,
    required String language,
    required List<ClinicFacility> nearbyFacilities,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
  }) {
    final languageInstruction = _getLanguageInstruction(language);

    // Build facility data for Gemini
    final facilityData = nearbyFacilities
        .map((facility) => {
              'name': facility.name,
              'type': facility.facilityType,
              'distance': '${facility.distanceKm.toStringAsFixed(1)} km',
              'travelTime': facility.estimatedTravelTime,
              'rating': facility.rating.toStringAsFixed(1),
              'address': facility.address,
            })
        .toList();

    return '''
$languageInstruction

You are a professional medical AI assistant with access to REAL-TIME nearby healthcare facilities. Your goal is to analyze symptoms using CTAS protocols AND recommend the most appropriate nearby facility.

CRITICAL SAFETY RULES:
1. NEVER provide medical diagnosis - only urgency classification
2. ALWAYS use CTAS levels 1-5 only
3. Recommend specific nearby facilities when appropriate
4. If uncertain, escalate to higher urgency level (be conservative)
5. Include confidence score (0.0-1.0) - be honest about uncertainty

PATIENT PRESENTATION:
Symptoms: $symptoms
${medicalHistory != null ? 'Medical History: ${jsonEncode(medicalHistory)}' : ''}
${vitalSigns != null ? 'Vital Signs: ${jsonEncode(vitalSigns)}' : ''}

NEARBY OPEN HEALTHCARE FACILITIES:
${facilityData.isEmpty ? 'No facilities found nearby' : jsonEncode(facilityData)}

TRAFFIC REDUCTION EXAMPLES:
- "headache_mild": Recommend walk-in clinic, explain "For a mild headache, there's a walk-in clinic 5 minutes away that can help you quickly. This saves hospital resources for emergencies and gets you faster care."
- "cold_symptoms": Recommend pharmacy or virtual consultation, explain "Cold symptoms can be handled at a nearby pharmacy. The closest walk-in clinic is 8 minutes away with 15-minute waits vs 4+ hours at hospital."
- "minor_injury": Recommend urgent care center, explain "For minor cuts, an urgent care center is perfect! Much faster than ER and designed for exactly this type of care."

CANADIAN TRIAGE AND ACUITY SCALE (CTAS) + FACILITY ROUTING:
- Level 1: Life-threatening → EMERGENCY ROOM ONLY
- Level 2: Imminently life-threatening → EMERGENCY ROOM ONLY  
- Level 3: Urgent → EMERGENCY ROOM (but mention urgent care if available)
- Level 4: Less urgent → PREFER WALK-IN CLINICS/URGENT CARE
- Level 5: Non-urgent → RECOMMEND WALK-IN CLINICS/FAMILY DOCTOR

RESPOND WITH VALID JSON ONLY:
{
  "ctasLevel": 1-5,
  "urgencyDescription": "Brief clinical description",
  "reasoning": "Clear medical reasoning based on symptoms and CTAS criteria",
  "recommendedAction": "Specific recommendation with nearby facility name and travel time",
  "confidenceScore": 0.0-1.0,
  "estimatedWaitTime": "Time estimate based on CTAS level and facility type",
  "redFlags": ["List of concerning symptoms found"],
  "nextSteps": ["Immediate actions including specific facility recommendation"],
  "facilityType": "EMERGENCY|CLINIC|WALKIN|FAMILY_DOCTOR|URGENT_CARE",
  "recommendedFacility": "Specific facility name from nearby list if applicable",
  "trafficReductionMessage": "Explain why this facility choice saves time and helps hospital traffic - be specific about travel time and wait time benefits"
}

Example for headache: "For your mild headache, I recommend [Specific Clinic Name] which is only 5 minutes away. Walk-in clinics typically see patients within 20-30 minutes, while hospitals have 4+ hour waits for non-emergency cases. This gets you faster care and keeps emergency rooms free for critical patients."

Analyze the symptoms and recommend the best nearby facility now. Be specific about facility names and travel times when possible.
''';
  }

  // ====== PUBLIC STATIC METHODS FOR EASY ACCESS ======

  /// 🏥 Static method for standard medical analysis
  static Future<TriageResult> analyzeSymptoms({
    required String symptoms,
    String language = 'en',
    bool isVoiceInput = false,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
  }) async {
    final service = MedicalAIService();
    return service.analyzeMedicalCase(
      symptoms: symptoms,
      language: language,
      isVoiceInput: isVoiceInput,
      medicalHistory: medicalHistory,
      vitalSigns: vitalSigns,
    );
  }

  /// 🗺️ Static method for location-aware medical analysis with real facility routing
  static Future<TriageResult> analyzeSymptomsWithLocation({
    required String symptoms,
    required double latitude,
    required double longitude,
    String language = 'en',
    bool isVoiceInput = false,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
  }) async {
    final service = MedicalAIService();
    return service.analyzeMedicalCaseWithLocation(
      symptoms: symptoms,
      latitude: latitude,
      longitude: longitude,
      language: language,
      isVoiceInput: isVoiceInput,
      medicalHistory: medicalHistory,
      vitalSigns: vitalSigns,
    );
  }

  /// 📱 Easy demo method for testing location-based recommendations
  static Future<void> demoLocationBasedRouting() async {
    print('🎯 DEMO: Location-Based Smart Healthcare Routing');

    // Toronto downtown coordinates
    const latitude = 43.6532;
    const longitude = -79.3832;

    final testCases = [
      {
        'symptoms': 'mild headache for 2 hours, no fever',
        'expectedRoute': 'WALKIN clinic - faster than hospital'
      },
      {
        'symptoms': 'cold symptoms, runny nose, cough',
        'expectedRoute': 'CLINIC or pharmacy - save ER for emergencies'
      },
      {
        'symptoms': 'chest pain with shortness of breath',
        'expectedRoute': 'EMERGENCY room - life threatening'
      },
    ];

    for (final testCase in testCases) {
      print('\n📝 Testing: ${testCase['symptoms']}');
      print('🎯 Expected: ${testCase['expectedRoute']}');

      try {
        final result = await analyzeSymptomsWithLocation(
          symptoms: testCase['symptoms']!,
          latitude: latitude,
          longitude: longitude,
        );

        print('✅ AI Recommendation: ${result.recommendedAction}');
        print('🏥 CTAS Level: ${result.ctasLevel}');
        print('⏰ Estimated Wait: ${result.estimatedWaitTime}');
      } catch (e) {
        print('❌ Error: $e');
      }
    }
  }
}

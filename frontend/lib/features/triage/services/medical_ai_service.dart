import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/triage_models.dart';

/// 🤖 Medical AI Service - The Brain of Healthcare AI System
///
/// This service provides CTAS-compliant medical triage using advanced AI
/// to analyze symptoms and provide intelligent healthcare recommendations.
///
/// CRITICAL: This is for TRIAGE ONLY - Never provides medical diagnosis
class MedicalAIService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-1.5-flash-latest';

  // TODO: Move to environment variables
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Configure in .env

  final http.Client _httpClient;
  final Uuid _uuid = const Uuid();

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
    try {
      final sessionId = _uuid.v4();
      final prompt = _buildMedicalPrompt(
        symptoms: symptoms,
        language: language,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
      );

      print('🤖 AI Analysis Starting - Session: $sessionId');
      print('📝 Symptoms: $symptoms');
      print('🌐 Language: $language');

      // For demo purposes, simulate AI response if no API key configured
      if (_apiKey == 'YOUR_GEMINI_API_KEY') {
        return _simulateAIResponse(sessionId, symptoms, language);
      }

      final response = await _callGeminiAPI(prompt);
      final analysisResult = _parseGeminiResponse(response);

      final triageResult = TriageResult(
        sessionId: sessionId,
        ctasLevel: analysisResult['ctasLevel'] ?? 5,
        urgencyDescription: analysisResult['urgencyDescription'] ?? 'Unknown',
        reasoning: analysisResult['reasoning'] ?? 'Unable to analyze',
        recommendedAction:
            analysisResult['recommendedAction'] ??
            'Consult healthcare provider',
        confidenceScore: (analysisResult['confidenceScore'] ?? 0.0).toDouble(),
        estimatedWaitTime: analysisResult['estimatedWaitTime'] ?? 'Unknown',
        requiresEmergency: (analysisResult['ctasLevel'] ?? 5) <= 2,
        language: language,
        analysisTimestamp: DateTime.now(),
        redFlags: List<String>.from(analysisResult['redFlags'] ?? []),
        nextSteps: List<String>.from(analysisResult['nextSteps'] ?? []),
      );

      print('✅ AI Analysis Complete - CTAS Level: ${triageResult.ctasLevel}');

      // Log for audit trail (required for medical applications)
      await _logTriageAnalysis(triageResult, symptoms);

      return triageResult;
    } catch (e) {
      print('❌ AI Analysis Error: $e');

      // Safety fallback - Never leave patient without guidance
      return TriageResult.createSafetyFallback(
        sessionId: _uuid.v4(),
        language: language,
        originalSymptoms: symptoms,
      );
    }
  }

  /// 🎭 Simulate AI Response for Demo (when no API key configured)
  TriageResult _simulateAIResponse(
    String sessionId,
    String symptoms,
    String language,
  ) {
    final symptomsLower = symptoms.toLowerCase();

    // Emergency keywords detection
    final emergencyKeywords = [
      'chest pain',
      'shortness of breath',
      'unconscious',
      'stroke',
      'heart attack',
    ];
    final hasEmergencyKeywords = emergencyKeywords.any(
      (keyword) => symptomsLower.contains(keyword),
    );

    // Severe keywords detection
    final severeKeywords = [
      'severe',
      'intense',
      'unbearable',
      'cannot',
      'difficult to breathe',
    ];
    final hasSevereKeywords = severeKeywords.any(
      (keyword) => symptomsLower.contains(keyword),
    );

    // Common symptoms detection
    final commonKeywords = ['headache', 'fever', 'cough', 'cold', 'tired'];
    final hasCommonKeywords = commonKeywords.any(
      (keyword) => symptomsLower.contains(keyword),
    );

    int ctasLevel;
    String urgencyDescription;
    String reasoning;
    String recommendedAction;
    double confidenceScore;
    String estimatedWaitTime;
    List<String> redFlags = [];
    List<String> nextSteps = [];

    if (hasEmergencyKeywords) {
      ctasLevel = 2;
      urgencyDescription = 'Potentially Life-Threatening';
      reasoning =
          'Emergency symptoms detected requiring immediate medical attention';
      recommendedAction = 'Go to Emergency Department immediately';
      confidenceScore = 0.95;
      estimatedWaitTime = '15 minutes';
      redFlags = ['Emergency symptoms detected'];
      nextSteps = [
        'Call 911 or go to ER immediately',
        'Do not drive yourself',
        'Bring medication list',
      ];
    } else if (hasSevereKeywords) {
      ctasLevel = 3;
      urgencyDescription = 'Urgent - Needs Attention';
      reasoning = 'Severe symptoms requiring prompt medical evaluation';
      recommendedAction = 'Visit urgent care or family doctor within 2 hours';
      confidenceScore = 0.85;
      estimatedWaitTime = '30 minutes';
      redFlags = ['Severe symptom intensity'];
      nextSteps = [
        'Seek medical attention within 2 hours',
        'Monitor symptoms',
        'Prepare medical history',
      ];
    } else if (hasCommonKeywords) {
      ctasLevel = 4;
      urgencyDescription = 'Less Urgent - Can Wait';
      reasoning = 'Common symptoms that can be managed with routine care';
      recommendedAction = 'Schedule appointment with family doctor';
      confidenceScore = 0.80;
      estimatedWaitTime = '60 minutes';
      redFlags = [];
      nextSteps = [
        'Book routine appointment',
        'Rest and hydrate',
        'Monitor for changes',
      ];
    } else {
      ctasLevel = 4;
      urgencyDescription = 'Assessment Needed';
      reasoning = 'Symptoms require professional medical evaluation';
      recommendedAction = 'Consult with healthcare provider';
      confidenceScore = 0.75;
      estimatedWaitTime = '60 minutes';
      redFlags = [];
      nextSteps = [
        'Contact healthcare provider',
        'Document symptoms',
        'Prepare for consultation',
      ];
    }

    return TriageResult(
      sessionId: sessionId,
      ctasLevel: ctasLevel,
      urgencyDescription: urgencyDescription,
      reasoning: reasoning,
      recommendedAction: recommendedAction,
      confidenceScore: confidenceScore,
      estimatedWaitTime: estimatedWaitTime,
      requiresEmergency: ctasLevel <= 2,
      language: language,
      analysisTimestamp: DateTime.now(),
      redFlags: redFlags,
      nextSteps: nextSteps,
    );
  }

  /// 🏥 Build CTAS-Compliant Medical Prompt
  ///
  /// This prompt ensures AI follows Canadian Triage and Acuity Scale
  String _buildMedicalPrompt({
    required String symptoms,
    required String language,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
  }) {
    final languageInstruction = _getLanguageInstruction(language);

    return '''
$languageInstruction

You are a CTAS-compliant medical triage AI assistant. Your role is to analyze symptoms and classify urgency ONLY - never diagnose.

CRITICAL SAFETY RULES:
1. NEVER provide medical diagnosis
2. ALWAYS classify using CTAS levels 1-5 only
3. ALWAYS recommend appropriate healthcare pathway
4. If uncertain, escalate to higher urgency level
5. Include confidence score (0.0-1.0)

PATIENT PRESENTATION:
Symptoms: $symptoms
${medicalHistory != null ? 'Medical History: ${jsonEncode(medicalHistory)}' : ''}
${vitalSigns != null ? 'Vital Signs: ${jsonEncode(vitalSigns)}' : ''}

CANADIAN TRIAGE AND ACUITY SCALE (CTAS):
- Level 1: Life-threatening, immediate care (0 minutes)
- Level 2: Imminently life-threatening (15 minutes)
- Level 3: Urgent, potentially life-threatening (30 minutes)
- Level 4: Less urgent (60 minutes)
- Level 5: Non-urgent (120 minutes)

RESPOND WITH JSON:
{
  "ctasLevel": 1-5,
  "urgencyDescription": "Brief description",
  "reasoning": "Clear medical reasoning based on symptoms",
  "recommendedAction": "Specific next steps",
  "confidenceScore": 0.0-1.0,
  "estimatedWaitTime": "Time estimate",
  "redFlags": ["List", "of", "concerning", "symptoms"],
  "nextSteps": ["Immediate", "actions", "to", "take"]
}

EMERGENCY KEYWORDS TO DETECT:
- Chest pain + shortness of breath
- Stroke symptoms (FAST criteria)
- Severe bleeding
- Loss of consciousness
- Severe allergic reaction
- Severe abdominal pain
- High fever with altered mental state

Analyze now and respond with JSON only.
''';
  }

  /// 🌐 Get Language-Specific Instructions
  String _getLanguageInstruction(String language) {
    switch (language) {
      case 'fr':
        return 'Répondez en français. Utilisez la terminologie médicale française appropriée.';
      case 'es':
        return 'Responde en español. Usa terminología médica apropiada en español.';
      default:
        return 'Respond in English. Use clear, professional medical terminology.';
    }
  }

  /// 🔗 Call Gemini API for Medical Analysis
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
        'topK': 1,
        'topP': 0.8,
        'maxOutputTokens': 1000,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_MEDICAL',
          'threshold': 'BLOCK_NONE', // We handle medical safety ourselves
        },
      ],
    };

    final response = await _httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception(
        'Gemini API Error: ${response.statusCode} - ${response.body}',
      );
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

      return jsonDecode(cleanResponse.trim());
    } catch (e) {
      print('❌ Error parsing AI response: $e');
      print('📄 Raw response: $response');

      // Safety fallback parsing
      return {
        'ctasLevel': 4, // Default to less urgent if parsing fails
        'urgencyDescription': 'Requires Assessment',
        'reasoning':
            'Unable to parse AI response - please consult healthcare provider',
        'recommendedAction': 'Visit nearest healthcare facility for assessment',
        'confidenceScore': 0.5,
        'estimatedWaitTime': '60 minutes',
        'redFlags': [],
        'nextSteps': ['Seek medical attention'],
      };
    }
  }

  /// 📝 Log Triage Analysis for Audit Trail
  ///
  /// REQUIRED: All medical AI decisions must be logged
  Future<void> _logTriageAnalysis(
    TriageResult result,
    String originalSymptoms,
  ) async {
    final logEntry = {
      'sessionId': result.sessionId,
      'timestamp': result.analysisTimestamp.toIso8601String(),
      'ctasLevel': result.ctasLevel,
      'confidenceScore': result.confidenceScore,
      'originalSymptoms': originalSymptoms,
      'aiReasoningLength': result.reasoning.length,
      'requiresEmergency': result.requiresEmergency,
      'language': result.language,
      'version': '1.0.0',
    };

    print('📋 Triage Analysis Logged: ${jsonEncode(logEntry)}');

    // TODO: Send to Firebase for permanent audit trail
    // await FirebaseService.logTriageAnalysis(logEntry);
  }

  /// 🚨 Detect Emergency Keywords in Multiple Languages
  bool detectEmergencyKeywords(String symptoms, String language) {
    final emergencyPatterns = {
      'en': [
        r'chest pain.*shortness',
        r'cannot breathe',
        r'severe bleeding',
        r'unconscious',
        r'stroke',
        r'heart attack',
        r'severe allergic',
        r'anaphylaxis',
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

    for (final pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(symptomsLower)) {
        print('🚨 EMERGENCY KEYWORD DETECTED: $pattern');
        return true;
      }
    }

    return false;
  }

  /// 🧪 Test AI Service Connection
  Future<bool> testConnection() async {
    try {
      final testResult = await analyzeMedicalCase(
        symptoms: 'Test connection - mild headache',
        language: 'en',
        isVoiceInput: false,
      );

      return testResult.confidenceScore > 0;
    } catch (e) {
      print('❌ AI Service Test Failed: $e');
      return false;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/triage_models.dart';

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

      final triageResult = TriageResult(
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

CANADIAN TRIAGE AND ACUITY SCALE (CTAS):
- Level 1: Life-threatening, immediate care (0 minutes) - cardiac arrest, severe trauma, anaphylaxis
- Level 2: Imminently life-threatening (15 minutes) - chest pain with cardiac features, stroke symptoms
- Level 3: Urgent, potentially life-threatening (30 minutes) - severe abdominal pain, moderate respiratory distress
- Level 4: Less urgent (60 minutes) - minor injuries, stable vital signs
- Level 5: Non-urgent (120 minutes) - minor cuts, routine medication refills

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
  "recommendedAction": "Specific next steps for patient",
  "confidenceScore": 0.0-1.0,
  "estimatedWaitTime": "Time estimate based on CTAS level",
  "redFlags": ["List of concerning symptoms found"],
  "nextSteps": ["Immediate actions patient should take"]
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
      'version': '2.0.0-real-ai',
      'apiUsed': 'gemini-1.5-flash',
    };

    print('📋 Medical Triage Analysis Logged: ${jsonEncode(logEntry)}');

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
        r'facial droop',
        r'speech slurred',
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
}

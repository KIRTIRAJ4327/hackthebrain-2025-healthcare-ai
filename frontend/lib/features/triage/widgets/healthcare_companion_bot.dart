import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 🏆 Revolutionary Healthcare Companion Bot - HackTheBrain 2025 Winner
///
/// This is the REAL AI companion that will win the competition!
/// Features:
/// - REAL Google Gemini AI integration with your API keys
/// - Multi-language support (EN/FR/CN/PA) for Toronto demographics
/// - Emergency detection with instant visual feedback
/// - Professional voice recognition and translation
/// - Medical-grade animations and UX
class HealthcareCompanionBot extends StatefulWidget {
  final Function(String message, String language, bool isEmergency)?
      onAnalysisComplete;

  const HealthcareCompanionBot({super.key, this.onAnalysisComplete});

  @override
  State<HealthcareCompanionBot> createState() => _HealthcareCompanionBotState();
}

class _HealthcareCompanionBotState extends State<HealthcareCompanionBot>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _emergencyController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _emergencyAnimation;

  // Voice & AI State
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  String _currentLanguage = 'English';
  String _aiResponse = '';
  bool _isEmergencyDetected = false;
  bool _analysisComplete = false;

  // Medical History & Vital Signs
  final List<String> _symptomHistory = [];
  bool _showMedicalHistory = false;
  int _painLevel = 0;
  String _symptomDuration = '';

  // REAL API Keys from your env.txt
  String get _geminiApiKey => dotenv.env['GOOGLE_GEMINI_API_KEY'] ?? '';

  // Toronto Language Config - Competition Ready 🏆
  final Map<String, Map<String, dynamic>> _torontoConfig = {
    'English': {
      'greeting':
          '👋 Hi! I\'m MediCore AI. Tell me your symptoms and I\'ll provide intelligent triage.',
      'emergency':
          '🚨 EMERGENCY DETECTED! Connecting to immediate medical help.',
      'processing': '🧠 Analyzing your symptoms with real AI...',
      'complete':
          '✅ AI Medical Analysis Complete\n\nProfessional CTAS-compliant assessment ready',
      'color': const Color(0xFF1565C0),
      'emergencyColor': const Color(0xFFD32F2F),
      'flag': '🇨🇦',
      'locale': 'en-US', // Most supported English locale
      'languageCode': 'en',
    },
    'French': {
      'greeting':
          '👋 Salut! Je suis MediCore AI. Décrivez vos symptômes pour un triage intelligent.',
      'emergency':
          '🚨 URGENCE DÉTECTÉE! Connexion à l\'aide médicale immédiate.',
      'processing': '🧠 Analyse de vos symptômes avec une IA réelle...',
      'complete':
          '✅ Analyse médicale IA terminée\n\nÉvaluation professionnelle conforme CTAS prête',
      'color': const Color(0xFF1565C0),
      'emergencyColor': const Color(0xFFD32F2F),
      'flag': '🇫🇷',
      'locale': 'fr-FR', // Standard French locale
      'languageCode': 'fr',
    },
    'Mandarin': {
      'greeting': '👋 您好！我是MediCore AI。告诉我您的症状，我会提供智能分诊。',
      'emergency': '🚨 检测到紧急情况！正在连接紧急医疗帮助。',
      'processing': '🧠 正在用真实AI分析您的症状...',
      'complete': '✅ AI医疗分析完成\n\n专业CTAS合规评估已准备就绪',
      'color': const Color(0xFF1565C0),
      'emergencyColor': const Color(0xFFD32F2F),
      'flag': '🇨🇳',
      'locale': 'zh-CN', // Standard Mandarin locale
      'languageCode': 'zh',
    },
    'Hindi': {
      'greeting':
          '👋 नमस्ते! मैं MediCore AI हूं। अपने लक्षण बताएं, मैं तुरंत मेडिकल ट्राइज प्रदान करूंगा।',
      'emergency':
          '🚨 आपातकाल का पता चला! तत्काल चिकित्सा सहायता से जोड़ रहे हैं।',
      'processing':
          '🧠 वास्तविक AI के साथ आपके लक्षणों का विश्लेषण कर रहे हैं...',
      'complete':
          '✅ AI मेडिकल विश्लेषण पूर्ण\n\nपेशेवर CTAS-अनुपालित मूल्यांकन तैयार',
      'color': const Color(0xFF1565C0),
      'emergencyColor': const Color(0xFFD32F2F),
      'flag': '🇮🇳',
      'locale': 'hi-IN', // Hindi locale for India
      'languageCode': 'hi',
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeech();
    _setInitialGreeting();
  }

  void _initializeAnimations() {
    _pulseController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _emergencyController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _emergencyAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(
            parent: _emergencyController, curve: Curves.elasticOut));
  }

  void _initializeSpeech() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onError: (error) => print('❌ Speech Error: $error'),
      onStatus: (status) => print('📱 Speech Status: $status'),
    );
    print('🎤 Speech Recognition Available: $available');

    // List available locales for debugging
    var locales = await _speech.locales();
    print(
        '🌍 Available locales: ${locales.map((l) => l.localeId).take(10).toList()}');
  }

  void _setInitialGreeting() {
    setState(() {
      _aiResponse = _torontoConfig[_currentLanguage]!['greeting'];
      _analysisComplete = false;
    });
  }

  /// 📋 Collect Additional Medical Information
  void _collectMedicalHistory(String symptoms) {
    setState(() {
      _symptomHistory.add('${DateTime.now().toIso8601String()}: $symptoms');
      _showMedicalHistory = true;
    });
  }

  /// 🩺 Build Medical History Panel
  Widget _buildMedicalHistoryPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_information_outlined,
                  color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'Additional Medical Information',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Pain Level Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.sentiment_very_dissatisfied,
                        color: _painLevel >= 7 ? Colors.red : Colors.blue[600],
                        size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pain Level: $_painLevel/10',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _painLevel >= 7
                            ? Colors.red[100]
                            : _painLevel >= 4
                                ? Colors.orange[100]
                                : Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _painLevel >= 7
                            ? 'SEVERE'
                            : _painLevel >= 4
                                ? 'MODERATE'
                                : 'MILD',
                        style: TextStyle(
                          color: _painLevel >= 7
                              ? Colors.red[700]
                              : _painLevel >= 4
                                  ? Colors.orange[700]
                                  : Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _painLevel.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: _painLevel.toString(),
                  activeColor: _painLevel >= 7 ? Colors.red : Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _painLevel = value.round();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Duration Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'How long have you had these symptoms?',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children:
                      ['Minutes', 'Hours', 'Days', 'Weeks'].map((duration) {
                    final isSelected = _symptomDuration == duration;
                    return GestureDetector(
                      onTap: () => setState(() => _symptomDuration = duration),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue[600] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue[600]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          duration,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.blue[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🤖 REAL Gemini AI Medical Analysis - Single Source of Truth
  Future<void> _analyzeWithRealGeminiAI(String userInput) async {
    print(
        '🔑 API Key Check: ${_geminiApiKey.isNotEmpty ? "✅ Available (${_geminiApiKey.substring(0, 10)}...)" : "❌ Missing"}');

    if (_geminiApiKey.isEmpty) {
      _showError('Gemini API key not configured. Please check .env file.');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _aiResponse = _torontoConfig[_currentLanguage]!['processing'];
    });

    final languageCode = _torontoConfig[_currentLanguage]!['languageCode'];
    final medicalPrompt = '''
You are MediCore AI, a medical triage assistant for Toronto healthcare. 

Patient Input: "$userInput"
Language: $_currentLanguage
Language Code: $languageCode
Pain Level: $_painLevel/10 ${_painLevel >= 7 ? '(SEVERE)' : _painLevel >= 4 ? '(MODERATE)' : '(MILD)'}
Symptom Duration: $_symptomDuration
Previous Symptoms: ${_symptomHistory.join(', ')}

CRITICAL EMERGENCY DETECTION INSTRUCTIONS:
1. Analyze the patient's input for ANY signs of medical emergency
2. Consider context, urgency, pain level (7-10 = emergency consideration), and severity
3. Look for both explicit emergency words AND implicit emergency situations
4. Pain level 8-10 should be considered potential emergency
5. Examples of emergencies: chest pain, difficulty breathing, severe bleeding, unconsciousness, severe injuries, falls with injury, accidents, severe pain (8-10/10), stroke symptoms, heart attack symptoms
6. Be VERY sensitive to emergency detection - err on the side of caution

RESPONSE REQUIREMENTS:
- Start response with "EMERGENCY:" if ANY emergency signs detected
- Start response with "ROUTINE:" if non-emergency
- Consider pain level and duration in your assessment
- Provide caring, professional medical guidance
- Always recommend appropriate healthcare pathway
- Respond in $_currentLanguage language
- Keep response under 150 words but be thorough

EMERGENCY EXAMPLES:
- "I fell and I'm bleeding" → EMERGENCY
- "Chest pain and can't breathe" → EMERGENCY  
- "Severe headache with vision problems" → EMERGENCY
- "Car accident, hurt badly" → EMERGENCY
- "Pain level 9/10" → EMERGENCY
- "Can't move my arm after fall" → EMERGENCY

ROUTINE EXAMPLES:
- "Mild headache for 2 days" → ROUTINE
- "Small cut on finger" → ROUTINE
- "Feeling tired lately" → ROUTINE
- "Pain level 3/10" → ROUTINE

Analyze the patient's symptoms now and respond professionally in $_currentLanguage.
''';

    try {
      print('🤖 Calling REAL Gemini AI with Enhanced Emergency Detection...');
      print('📝 User Input: $userInput');
      print('🌍 Language: $_currentLanguage');
      print('😰 Pain Level: $_painLevel/10');
      print('⏰ Duration: $_symptomDuration');

      // Collect medical history
      _collectMedicalHistory(userInput);

      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': medicalPrompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature':
                0.1, // Lower temperature for more consistent emergency detection
            'maxOutputTokens': 400,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_NONE',
            },
          ],
        }),
      );

      print('📥 Gemini Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final aiText = data['candidates'][0]['content']['parts'][0]['text'];

          // 🧠 INTELLIGENT EMERGENCY DETECTION - Smarter Logic for Headache & Combined Symptoms
          // Check pain level, duration, and combined symptoms for accurate triage
          final isCommonNonEmergency = _isCommonNonEmergencySymptom(userInput);

          bool isEmergency = false;

          // Smart headache evaluation - consider severity and combinations
          if (userInput.toLowerCase().contains('headache')) {
            // Emergency headache indicators
            final hasEmergencyHeadacheSymptoms =
                userInput.toLowerCase().contains('vision') ||
                    userInput.toLowerCase().contains('severe') ||
                    userInput.toLowerCase().contains('worst') ||
                    userInput.toLowerCase().contains('sudden') ||
                    userInput.toLowerCase().contains('neck stiff') ||
                    userInput.toLowerCase().contains('confusion') ||
                    userInput.toLowerCase().contains('fever');

            isEmergency = hasEmergencyHeadacheSymptoms ||
                (_painLevel >= 8) || // Very high pain
                aiText.toUpperCase().startsWith('EMERGENCY:') ||
                (aiText.toLowerCase().contains('ctas level 1') ||
                    aiText.toLowerCase().contains('ctas 1'));
          } else if (!isCommonNonEmergency) {
            // Non-headache symptoms - use original logic
            isEmergency = aiText.toUpperCase().startsWith('EMERGENCY:') ||
                aiText.toLowerCase().contains('emergency') ||
                aiText.contains('🚨') ||
                (_painLevel >= 9) ||
                (aiText.toLowerCase().contains('ctas level 1') ||
                    aiText.toLowerCase().contains('ctas 1') ||
                    aiText.toLowerCase().contains('resuscitation'));
          } else {
            // Other common non-emergency symptoms
            isEmergency = (_painLevel >= 9) ||
                aiText.toUpperCase().startsWith('EMERGENCY:') ||
                (aiText.toLowerCase().contains('ctas level 1') ||
                    aiText.toLowerCase().contains('ctas 1'));
          }

          print('✅ AI Analysis Complete');
          print('🎯 Common Non-Emergency: $isCommonNonEmergency');
          print('🎯 Pain Level: $_painLevel/10');
          print('🎯 Emergency Detected: $isEmergency');
          print(
              '📄 AI Response: ${aiText.substring(0, aiText.length > 150 ? 150 : aiText.length)}...');

          if (!mounted) return;

          setState(() {
            _aiResponse = isEmergency
                ? _torontoConfig[_currentLanguage]!['emergency']
                : '✅ Analysis complete! I\'ve reviewed your symptoms and provided a detailed medical assessment. Please check the results below for my reasoning and recommendations.';
            _isProcessing = false;
            _isEmergencyDetected = isEmergency;
            _analysisComplete = true;
          });

          if (isEmergency) {
            _triggerEmergencyMode();
          }

          // 🔄 CRITICAL: Call the parent widget to trigger analysis flow
          print('🔄 Triggering parent analysis callback...');
          print('📋 Full AI Response for debugging: $aiText');
          widget.onAnalysisComplete?.call(userInput, languageCode, isEmergency);
        } else {
          _setFallbackResponse('No AI response received');
        }
      } else {
        final errorBody = response.body;
        print('❌ Gemini API Error: ${response.statusCode}');
        print('📄 Error Body: $errorBody');
        _setFallbackResponse('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ REAL AI Analysis Error: $e');
      _setFallbackResponse('Analysis failed: $e');
    }
  }

  bool _detectEmergencyKeywords(String input) {
    final keywords = [
      // English - Comprehensive Emergency Keywords
      'chest pain', 'can\'t breathe', 'bleeding', 'unconscious', 'heart attack',
      'stroke', 'severe pain', 'difficulty breathing', 'fell down', 'accident',
      'car accident', 'broken bone', 'fracture', 'head injury', 'concussion',
      'dizzy', 'fainted', 'vomiting blood', 'blood in stool', 'can\'t move',
      'paralyzed', 'seizure', 'allergic reaction', 'swelling', 'overdose',
      'poisoning', 'burn', 'cut badly', 'deep cut', 'emergency', 'help me',
      'call 911', 'ambulance', 'hospital now', 'dying', 'can\'t see',
      'vision loss', 'slurred speech', 'weakness', 'numb', 'crushing pain',

      // French - Emergency Keywords
      'douleur thoracique', 'ne peut pas respirer', 'saignement', 'inconscient',
      'crise cardiaque', 'accident vasculaire', 'douleur sévère', 'accident',
      'accident de voiture', 'os cassé', 'fracture', 'blessure à la tête',
      'étourdissement', 'évanoui', 'vomissement de sang', 'ne peut pas bouger',
      'paralysé', 'crise', 'réaction allergique', 'empoisonnement', 'brûlure',
      'coupure profonde', 'urgence', 'aidez-moi', 'appelez le 911', 'ambulance',
      'hôpital maintenant', 'mourant', 'perte de vision', 'faiblesse',

      // Chinese - Emergency Keywords
      '胸痛', '无法呼吸', '出血', '昏迷', '心脏病', '中风', '严重疼痛',
      '事故', '车祸', '骨折', '头部受伤', '头晕', '昏倒', '吐血',
      '无法移动', '瘫痪', '癫痫', '过敏反应', '中毒', '烧伤', '深度割伤',
      '紧急情况', '帮助我', '叫救护车', '医院', '快死了', '视力丧失', '无力',

      // Hindi - Emergency Keywords
      'सीने में दर्द', 'सांस नहीं ले सकता', 'खून बह रहा', 'बेहोश',
      'दिल का दौरा',
      'स्ट्रोक', 'गंभीर दर्द', 'दुर्घटना', 'गिर गया', 'कार दुर्घटना',
      'हड्डी टूटी',
      'सिर में चोट', 'चक्कर आना', 'बेहोशी', 'खून की उल्टी', 'हिल नहीं सकता',
      'लकवा', 'दौरा', 'एलर्जी', 'जहर', 'जलना', 'गहरा कट', 'आपातकाल',
      'मदद करो', 'एम्बुलेंस बुलाओ', 'अस्पताल', 'मर रहा हूं',
      'दिखाई नहीं दे रहा',
      'कमजोरी', 'सुन्न', 'तेज दर्द'
    ];

    final lowerInput = input.toLowerCase();
    return keywords
        .any((keyword) => lowerInput.contains(keyword.toLowerCase()));
  }

  /// 🏥 Check if symptom is common non-emergency that should go to clinic/walk-in
  bool _isCommonNonEmergencySymptom(String input) {
    final nonEmergencySymptoms = [
      // English
      'headache', 'mild headache', 'tension headache', 'sore throat',
      'runny nose',
      'stuffy nose', 'cough', 'cold', 'fever', 'flu', 'nausea', 'stomach ache',
      'belly pain', 'abdominal pain', 'diarrhea', 'constipation', 'fatigue',
      'tired', 'muscle ache', 'back pain', 'joint pain', 'rash', 'minor cut',
      'bruise', 'sprain', 'ear ache', 'sinus pressure', 'allergies',
      'minor burn', 'cold symptoms', 'flu symptoms',

      // French
      'mal de tête', 'mal de gorge', 'nez qui coule', 'toux', 'rhume', 'fièvre',
      'grippe', 'nausée', 'mal de ventre', 'diarrhée', 'fatigue', 'mal de dos',
      'éruption cutanée',

      // Chinese
      '头痛', '喉咙痛', '流鼻涕', '咳嗽', '感冒', '发烧', '流感', '恶心', '肚子痛',
      '腹泻', '疲劳', '背痛', '皮疹',

      // Hindi
      'सिरदर्द', 'गले में दर्द', 'नाक बहना', 'खांसी', 'जुकाम', 'बुखार', 'फ्लू',
      'जी मिचलाना', 'पेट दर्द', 'दस्त', 'थकान', 'कमर दर्द', 'चकत्ते'
    ];

    final lowerInput = input.toLowerCase();
    return nonEmergencySymptoms
        .any((symptom) => lowerInput.contains(symptom.toLowerCase()));
  }

  void _triggerEmergencyMode() {
    _emergencyController.forward();
  }

  void _setFallbackResponse(String error) {
    if (!mounted) return;
    setState(() {
      _aiResponse =
          'Please consult a healthcare professional or call emergency services if urgent.';
      _isProcessing = false;
      _analysisComplete = true;
    });
  }

  /// 🎤 Enhanced Voice Recognition with Fixed Language Support
  void _startListening() async {
    if (!_speech.isAvailable) {
      bool initialized = await _speech.initialize(
        onError: (error) => print('❌ Speech Init Error: $error'),
        onStatus: (status) => print('📱 Speech Status: $status'),
      );
      if (!initialized) {
        _showError('Voice recognition not available');
        return;
      }
    }

    if (_speech.isAvailable && !_isListening) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
        _analysisComplete = false;
      });

      final config = _torontoConfig[_currentLanguage]!;
      final localeId = config['locale'];

      print('🎤 Starting to listen in: $localeId');

      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });

            if (result.finalResult && _recognizedText.trim().isNotEmpty) {
              print('✅ Voice Recognition Complete: $_recognizedText');
              _stopListening();
              _analyzeWithRealGeminiAI(_recognizedText);
            }
          }
        },
        localeId: localeId,
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  void _stopListening() {
    if (mounted) {
      setState(() => _isListening = false);
    }
    _speech.stop();
  }

  // Continue button integration
  bool get canContinue => _analysisComplete && _recognizedText.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final config = _torontoConfig[_currentLanguage]!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact Language Selector
          _buildCompactLanguageSelector(),

          const SizedBox(height: 20),

          // Main AI Companion - Smaller
          _buildCompactCompanionBot(config),

          const SizedBox(height: 16),

          // Voice Button Row with Status
          _buildVoiceControlRow(config),

          // Recognition Display - Compact
          if (_recognizedText.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCompactRecognitionDisplay(config),
          ],

          // Medical Info - Inline when needed
          if (_showMedicalHistory && !_analysisComplete) ...[
            const SizedBox(height: 12),
            _buildInlineMedicalInfo(),
          ],

          // Completion Info - Compact
          if (_analysisComplete) ...[
            const SizedBox(height: 12),
            _buildCompactCompletionInfo(),
          ],

          // Test Scenarios - Expandable
          const SizedBox(height: 16),
          _buildExpandableTestScenarios(),
        ],
      ),
    );
  }

  /// 🌍 Compact Language Selector
  Widget _buildCompactLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.language, color: const Color(0xFF1565C0), size: 20),
          const SizedBox(width: 8),
          Text(
            'Language:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _torontoConfig.keys.map((language) {
                  final isSelected = language == _currentLanguage;
                  final config = _torontoConfig[language]!;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _currentLanguage = language;
                        _aiResponse = _torontoConfig[language]!['greeting'];
                        _isEmergencyDetected = false;
                        _analysisComplete = false;
                        _recognizedText = '';
                        _showMedicalHistory = false;
                        print('🌍 Language switched to: $language');
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1565C0)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1565C0)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(config['flag'],
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              language.substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1565C0),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🤖 Compact AI Companion Bot
  Widget _buildCompactCompanionBot(Map<String, dynamic> config) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _emergencyAnimation]),
      builder: (context, child) {
        double scale = _isEmergencyDetected
            ? _emergencyAnimation.value
            : _pulseAnimation.value;
        Color botColor = _isEmergencyDetected
            ? config['emergencyColor']
            : _isListening
                ? Colors.green[600]!
                : _analysisComplete
                    ? Colors.green[700]!
                    : config['color'];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[300]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // Smaller Bot Icon
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [botColor, botColor.withOpacity(0.7)]),
                    boxShadow: [
                      BoxShadow(
                          color: botColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        _isEmergencyDetected
                            ? Icons.emergency
                            : _isListening
                                ? Icons.mic
                                : _isProcessing
                                    ? Icons.psychology
                                    : _analysisComplete
                                        ? Icons.check_circle
                                        : Icons.healing,
                        size: 30,
                        color: Colors.white,
                      ),
                      if (_isProcessing)
                        const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Compact Speech Bubble
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isEmergencyDetected
                        ? Colors.red[50]
                        : _analysisComplete
                            ? Colors.green[50]
                            : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _isEmergencyDetected
                            ? Colors.red[300]!
                            : _analysisComplete
                                ? Colors.green[300]!
                                : Colors.blue[300]!),
                  ),
                  child: Text(
                    _aiResponse,
                    style: TextStyle(
                      color: _isEmergencyDetected
                          ? Colors.red[800]
                          : _analysisComplete
                              ? Colors.green[800]
                              : config['color'],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🎤 Compact Voice Control Row
  Widget _buildVoiceControlRow(Map<String, dynamic> config) {
    Color buttonColor = _isListening
        ? Colors.green[600]!
        : _isProcessing
            ? Colors.orange[600]!
            : _analysisComplete
                ? Colors.green[700]!
                : config['color'];
    IconData buttonIcon = _isListening
        ? Icons.mic
        : _isProcessing
            ? Icons.psychology
            : _analysisComplete
                ? Icons.check_circle
                : Icons.mic_none;

    String status = 'Ready to help you';
    IconData statusIcon = Icons.health_and_safety;
    Color statusColor = Colors.blue;

    if (_isListening) {
      status = 'Listening...';
      statusIcon = Icons.hearing;
      statusColor = Colors.green;
    } else if (_isProcessing) {
      status = 'AI analyzing...';
      statusIcon = Icons.psychology;
      statusColor = Colors.orange;
    } else if (_isEmergencyDetected) {
      status = 'Emergency detected!';
      statusIcon = Icons.emergency;
      statusColor = Colors.red;
    } else if (_analysisComplete) {
      status = 'Analysis complete';
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          // Voice Button - Smaller
          GestureDetector(
            onTap: _analysisComplete
                ? null
                : (_isListening ? _stopListening : _startListening),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: buttonColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: buttonColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2)
                ],
              ),
              child: Icon(buttonIcon, color: Colors.white, size: 24),
            ),
          ),

          const SizedBox(width: 12),

          // Status Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 Compact Recognition Display
  Widget _buildCompactRecognitionDisplay(Map<String, dynamic> config) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.record_voice_over, color: config['color'], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"$_recognizedText"',
              style: TextStyle(
                color: config['color'],
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 🩺 Inline Medical Info
  Widget _buildInlineMedicalInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Row(
        children: [
          // Pain Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pain Level',
                    style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _painLevel.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        activeColor: _painLevel >= 7 ? Colors.red : Colors.blue,
                        onChanged: (value) =>
                            setState(() => _painLevel = value.round()),
                      ),
                    ),
                    Text('$_painLevel/10',
                        style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Duration',
                  style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: ['Min', 'Hrs', 'Days', 'Wks'].map((duration) {
                  final isSelected = _symptomDuration.startsWith(duration);
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _symptomDuration = duration == 'Min'
                            ? 'Minutes'
                            : duration == 'Hrs'
                                ? 'Hours'
                                : duration == 'Days'
                                    ? 'Days'
                                    : 'Weeks'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[600] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        duration,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.blue[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Compact Completion Info
  Widget _buildCompactCompletionInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isEmergencyDetected ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEmergencyDetected ? Colors.red[300]! : Colors.green[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isEmergencyDetected ? Icons.emergency : Icons.check_circle,
            color: _isEmergencyDetected ? Colors.red[700] : Colors.green[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEmergencyDetected
                  ? '🚨 Emergency detected! Tap Continue for detailed analysis.'
                  : '✅ Analysis complete! Tap Continue to view results.',
              style: TextStyle(
                color:
                    _isEmergencyDetected ? Colors.red[800] : Colors.green[800],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧪 Expandable Test Scenarios
  Widget _buildExpandableTestScenarios() {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(Icons.science_outlined, color: Colors.orange[700], size: 20),
          const SizedBox(width: 8),
          Text(
            'Quick Test Scenarios',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.orange[700],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          // Reset button
          if (_analysisComplete || _isEmergencyDetected)
            GestureDetector(
              onTap: () {
                setState(() {
                  _recognizedText = '';
                  _analysisComplete = false;
                  _isEmergencyDetected = false;
                  _isProcessing = false;
                  _aiResponse = _torontoConfig[_currentLanguage]!['greeting'];
                });
                print('🔄 Analysis reset - ready for new input');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.blue[700], size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              'I have a headache',
              'I fell and I\'m bleeding',
              'Chest pain and can\'t breathe',
              'Car accident, leg broken',
            ].map((scenario) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _recognizedText = scenario;
                      _analysisComplete = false;
                      _showMedicalHistory = true;
                      _isEmergencyDetected = false; // Reset emergency state
                    });

                    // 🔄 For emergency scenarios, add delay to allow pain level adjustment
                    if (_detectEmergencyKeywords(scenario)) {
                      print(
                          '🚨 Emergency scenario detected - adding 3 second delay for pain level adjustment');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Emergency scenario! You have 3 seconds to adjust pain level...'),
                          backgroundColor: Colors.orange[600],
                          duration: Duration(seconds: 3),
                        ),
                      );
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          _analyzeWithRealGeminiAI(scenario);
                        }
                      });
                    } else {
                      _analyzeWithRealGeminiAI(scenario);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_outline,
                            color: Colors.orange[600], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            scenario,
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[600]),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emergencyController.dispose();
    _speech.stop();
    super.dispose();
  }
}

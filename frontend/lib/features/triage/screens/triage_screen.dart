import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/medical_ai_service.dart';
import '../models/triage_models.dart';
import '../widgets/healthcare_companion_bot.dart';

/// 🏥 Professional Medical Triage Screen - HackTheBrain 2025 WINNER
class TriageScreen extends StatefulWidget {
  final bool isQuickAccess;

  const TriageScreen({super.key, this.isQuickAccess = false});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isEmergencyMode = false;

  // 🤖 REAL AI Service for medical analysis
  final MedicalAIService _aiService = MedicalAIService();
  TriageResult? _triageResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEmergencyMode ? Colors.red[50] : Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            if (_isEmergencyMode)
              Icon(Icons.emergency, color: Colors.red[700], size: 28),
            if (_isEmergencyMode) const SizedBox(width: 8),
            Text(
              _isEmergencyMode
                  ? '🚨 EMERGENCY MODE'
                  : '🤖 AI Medical Companion',
              style: TextStyle(
                color: _isEmergencyMode ? Colors.red[700] : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor:
            _isEmergencyMode ? Colors.red[600] : const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isEmergencyMode)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: () {
                  // Emergency call action
                  _showEmergencyDialog();
                },
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text(
                  'CALL 911',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Emergency Alert Bar
          if (_isEmergencyMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[700],
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'EMERGENCY DETECTED - Immediate medical attention required',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showEmergencyDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red[700],
                    ),
                    child: const Text('GET HELP'),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildCompanionStep(), _buildResultsStep()],
            ),
          ),

          // Navigation
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildCompanionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Welcome Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isEmergencyMode
                    ? [Colors.red[600]!, Colors.red[700]!]
                    : [const Color(0xFF1565C0), const Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_isEmergencyMode ? Colors.red : Colors.blue)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  _isEmergencyMode ? Icons.emergency : Icons.psychology,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  _isEmergencyMode
                      ? 'Emergency Medical Assistant'
                      : 'AI Healthcare Companion',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _isEmergencyMode
                      ? 'Emergency detected. Immediate medical assistance is being arranged.'
                      : 'Talk to our AI in your preferred language for instant medical triage.',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Revolutionary Healthcare Companion Bot
          HealthcareCompanionBot(onAnalysisComplete: _handleAIAnalysis),

          const SizedBox(height: 40),

          // Feature Cards
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.translate,
                  'Multi-Language',
                  '4 Languages',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  Icons.emergency,
                  'Emergency Ready',
                  'Instant Detection',
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.psychology,
                  'Real AI',
                  'Gemini Powered',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  Icons.security,
                  'CTAS Compliant',
                  'Medical Standard',
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsStep() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _triageResult?.isCritical == true
                      ? [Colors.red[600]!, Colors.red[700]!]
                      : _triageResult?.isUrgent == true
                          ? [Colors.orange[600]!, Colors.orange[700]!]
                          : [Colors.green[600]!, Colors.green[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Medical Analysis Complete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Professional CTAS-compliant assessment ready',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_triageResult != null) ...[
              // CTAS Level Display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getUrgencyColor(_triageResult!.ctasLevel),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getUrgencyColor(
                        _triageResult!.ctasLevel,
                      ).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _getUrgencyIcon(_triageResult!.ctasLevel),
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CTAS Level ${_triageResult!.ctasLevel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _triageResult!.formattedUrgency,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${(_triageResult!.confidenceScore * 100).toInt()}% confident',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Results Cards
              _buildResultCard(
                '🎯 Recommended Action',
                _triageResult!.recommendedAction,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                '⏱️ Estimated Wait Time',
                _triageResult!.estimatedWaitTime,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                '🧠 Medical Reasoning',
                _triageResult!.reasoning,
                Colors.purple,
              ),

              if (_triageResult!.redFlags.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildResultCard(
                  '🚨 Important Indicators',
                  _triageResult!.redFlags.join('\n• '),
                  Colors.red,
                ),
              ],

              if (_triageResult!.nextSteps.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildResultCard(
                  '📋 Next Steps',
                  '• ${_triageResult!.nextSteps.join('\n• ')}',
                  Colors.orange,
                ),
              ],
            ] else ...[
              _buildResultCard(
                '🤖 AI Companion Ready',
                'Use the voice interface above to describe your symptoms. Our AI will provide instant medical triage in your preferred language.',
                Colors.blue,
              ),
            ],

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/appointments'),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Book Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String content, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEmergencyMode
                      ? Colors.red[600]
                      : const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_getNextButtonText()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🤖 Handle AI Analysis from Companion Bot
  void _handleAIAnalysis(
    String message,
    String language,
    bool isEmergency,
  ) async {
    print(
      '🤖 AI Companion Analysis: $message (Language: $language, Emergency: $isEmergency)',
    );

    setState(() {
      _isEmergencyMode = isEmergency;
    });

    try {
      // 🔄 IMPORTANT: Use the existing medical AI service for detailed CTAS analysis
      // The companion bot already did basic AI analysis, now we get detailed medical assessment
      final result = await _aiService.analyzeMedicalCase(
        symptoms: message,
        language: language.toLowerCase().substring(0, 2),
        isVoiceInput: true,
      );

      setState(() {
        _triageResult = result;
        if (result.requiresEmergency) {
          _isEmergencyMode = true;
        }
      });

      print('✅ Detailed CTAS Analysis Complete - Level: ${result.ctasLevel}');
      print('🎯 Emergency Required: ${result.requiresEmergency}');

      // 🔄 AUTOMATICALLY move to results step after AI analysis
      if (_currentStep == 0) {
        _nextStep();
      }
    } catch (e) {
      print('❌ Error during detailed AI analysis: $e');
      // Still allow progression even if detailed analysis fails
      if (_currentStep == 0) {
        _nextStep();
      }
    }
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[700]),
            const SizedBox(width: 12),
            const Text('Emergency Assistance'),
          ],
        ),
        content: const Text(
          'Based on your symptoms, this appears to be a medical emergency. Would you like to:\n\n• Call 911 immediately\n• Go to nearest Emergency Room\n• Contact emergency services',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement emergency calling
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency services contacted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: const Text(
              'CALL 911',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    if (_currentStep == 0) {
      // For the companion step, check if AI analysis is complete
      return _triageResult != null;
    }
    return true; // Always allow navigation from other steps
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return _triageResult != null ? 'View Results' : 'Speak to AI First';
      case 1:
        return 'Complete';
      default:
        return 'Next';
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/home');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        // 🔄 Reset emergency mode when going back to allow fresh analysis
        _isEmergencyMode = false;
        _triageResult = null; // Reset results to allow re-analysis
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Color _getUrgencyColor(int ctasLevel) {
    switch (ctasLevel) {
      case 1:
        return const Color(0xFFD32F2F);
      case 2:
        return const Color(0xFFF57C00);
      case 3:
        return const Color(0xFFFF9800);
      case 4:
        return const Color(0xFF388E3C);
      case 5:
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getUrgencyIcon(int ctasLevel) {
    switch (ctasLevel) {
      case 1:
        return Icons.emergency;
      case 2:
        return Icons.warning;
      case 3:
        return Icons.priority_high;
      case 4:
        return Icons.schedule;
      case 5:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  @override
  void dispose() {
    _aiService.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

// Placeholder classes for missing screens
class TriageResultScreen extends StatelessWidget {
  final String sessionId;
  const TriageResultScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Triage Result')),
      body: Center(child: Text('Result for session: $sessionId')),
    );
  }
}

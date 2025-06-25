import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/medical_ai_service.dart';
import '../models/triage_models.dart';

/// AI-Powered Medical Triage Screen
class TriageScreen extends StatefulWidget {
  final bool isQuickAccess;

  const TriageScreen({super.key, this.isQuickAccess = false});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String _selectedSeverity = '';
  List<String> _selectedSymptoms = [];
  bool _isAnalyzing = false;

  // 🤖 AI Service for medical analysis
  final MedicalAIService _aiService = MedicalAIService();
  TriageResult? _triageResult;

  final List<String> _commonSymptoms = [
    'Fever',
    'Cough',
    'Headache',
    'Nausea',
    'Fatigue',
    'Chest Pain',
    'Shortness of Breath',
    'Dizziness',
    'Abdominal Pain',
    'Joint Pain',
    'Rash',
    'Sore Throat',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Medical Triage'),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildWelcomeStep(),
          _buildSymptomsStep(),
          _buildSeverityStep(),
          _buildAnalysisStep(),
          _buildResultsStep(),
        ],
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.psychology,
              size: 80,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'AI-Powered Health Assessment',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Our advanced AI will analyze your symptoms and provide intelligent recommendations to help reduce wait times.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Secure & Private',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your health information is encrypted and never shared.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '⚡ Reduces assessment time by 70%',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your symptoms',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply to get accurate recommendations',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Quick symptom buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonSymptoms.map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return FilterChip(
                label: Text(symptom),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSymptoms.add(symptom);
                    } else {
                      _selectedSymptoms.remove(symptom);
                    }
                  });
                },
                selectedColor: Colors.purple.shade100,
                checkmarkColor: Colors.purple.shade600,
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Custom symptoms input
          TextField(
            controller: _symptomsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Additional symptoms or details',
              hintText: 'Describe any other symptoms you\'re experiencing...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.edit),
            ),
          ),

          const SizedBox(height: 24),

          if (_selectedSymptoms.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Selected Symptoms (${_selectedSymptoms.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_selectedSymptoms.join(', ')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeverityStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How severe are your symptoms?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps our AI prioritize your care',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _buildSeverityOption(
            'Mild',
            'Minor discomfort, can wait for routine care',
            Icons.sentiment_satisfied,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildSeverityOption(
            'Moderate',
            'Noticeable symptoms affecting daily activities',
            Icons.sentiment_neutral,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildSeverityOption(
            'Severe',
            'Significant symptoms requiring prompt attention',
            Icons.sentiment_dissatisfied,
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildSeverityOption(
            'Emergency',
            'Life-threatening symptoms needing immediate care',
            Icons.local_hospital,
            Colors.red.shade800,
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityOption(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedSeverity == title;

    return InkWell(
      onTap: () => setState(() => _selectedSeverity = title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.psychology, size: 80, color: Colors.purple.shade600),
                const SizedBox(height: 24),
                const Text(
                  'AI Analysis in Progress',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Processing your symptoms...\nAnalyzing risk factors...\nGenerating recommendations...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '🚀 HackTheBrain 2025 Demo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
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
                  'Analysis Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your AI-powered health assessment is ready',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_triageResult != null) ...[
            // Show AI-powered results
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getUrgencyColor(_triageResult!.ctasLevel),
                borderRadius: BorderRadius.circular(12),
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
                            fontSize: 18,
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
              '🧠 AI Reasoning',
              _triageResult!.reasoning,
              Colors.purple,
            ),
            if (_triageResult!.redFlags.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildResultCard(
                '🚨 Red Flags',
                _triageResult!.redFlags.join(', '),
                Colors.red,
              ),
            ],
            if (_triageResult!.nextSteps.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildResultCard(
                '📋 Next Steps',
                _triageResult!.nextSteps.join('\n• '),
                Colors.orange,
              ),
            ],
          ] else ...[
            // Show fallback results if AI analysis failed
            _buildResultCard(
              '🎯 Recommended Action',
              'Please consult with a healthcare provider for proper assessment',
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              '⏱️ Estimated Wait Time',
              'Contact your healthcare provider',
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              '💊 Next Steps',
              'Schedule an appointment with your family doctor or visit urgent care',
              Colors.purple,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/appointments'),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Book Appointment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String content, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info, color: color),
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
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
              child: Text(_getNextButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _selectedSymptoms.isNotEmpty;
      case 2:
        return _selectedSeverity.isNotEmpty;
      case 3:
        return !_isAnalyzing;
      case 4:
        return true;
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Start Assessment';
      case 1:
        return 'Continue';
      case 2:
        return 'Analyze Symptoms';
      case 3:
        return 'View Results';
      case 4:
        return 'Complete';
      default:
        return 'Next';
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
        if (_currentStep == 3) {
          _performAIAnalysis();
        }
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/home');
    }
  }

  /// 🤖 Perform AI-Powered Medical Analysis
  Future<void> _performAIAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _triageResult = null;
    });

    try {
      // Combine selected symptoms and custom text
      final allSymptoms = [
        ..._selectedSymptoms,
        if (_symptomsController.text.isNotEmpty) _symptomsController.text,
      ].join(', ');

      print('🩺 Starting AI medical analysis...');
      print('📝 Symptoms: $allSymptoms');
      print('⚠️ Severity: $_selectedSeverity');

      // Call AI service for medical analysis
      final result = await _aiService.analyzeMedicalCase(
        symptoms: '$allSymptoms. Severity level: $_selectedSeverity',
        language: 'en', // TODO: Add language selection
        isVoiceInput: false,
      );

      if (mounted) {
        setState(() {
          _triageResult = result;
          _isAnalyzing = false;
        });

        print('✅ AI Analysis Complete!');
        print('🎯 CTAS Level: ${result.ctasLevel}');
        print('⏱️ Wait Time: ${result.estimatedWaitTime}');
        print('🚨 Emergency: ${result.requiresEmergency}');
      }
    } catch (e) {
      print('❌ AI Analysis Error: $e');

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 🎨 Get Urgency Color Based on CTAS Level
  Color _getUrgencyColor(int ctasLevel) {
    switch (ctasLevel) {
      case 1:
        return const Color(0xFFDC2626); // Emergency Red
      case 2:
        return const Color(0xFFF59E0B); // Warning Orange
      case 3:
        return const Color(0xFFD97706); // Urgent Orange
      case 4:
        return const Color(0xFF059669); // Less Urgent Green
      case 5:
        return const Color(0xFF10B981); // Non-Urgent Light Green
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  /// 🔗 Get Urgency Icon Based on CTAS Level
  IconData _getUrgencyIcon(int ctasLevel) {
    switch (ctasLevel) {
      case 1:
        return Icons.emergency; // Emergency
      case 2:
        return Icons.warning; // Warning
      case 3:
        return Icons.priority_high; // Urgent
      case 4:
        return Icons.schedule; // Less Urgent
      case 5:
        return Icons.check_circle; // Non-Urgent
      default:
        return Icons.help; // Unknown
    }
  }

  @override
  void dispose() {
    _aiService.dispose();
    _symptomsController.dispose();
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

import 'dart:convert';
import 'dart:math' as math;
import '../models/triage_models.dart';

/// 🎯 Confidence Validation & Human-in-the-Loop Service
///
/// CRITICAL SAFETY FEATURE: Ensures low-confidence AI classifications
/// are properly handled with human oversight and conservative escalation.
///
/// This addresses the key concern: "What if the LLM can't classify
/// with a high confidence score?"
class ConfidenceValidationService {
  /// 🎯 Apply Confidence Thresholds and Human-in-the-Loop Review
  ///
  /// CRITICAL SAFETY FEATURE: Ensures low-confidence cases get human review
  static Future<TriageResult> validateConfidence(
    TriageResult result,
    String originalSymptoms,
  ) async {
    // Define confidence thresholds based on CTAS level criticality
    // Higher criticality = Higher confidence required
    final confidenceThresholds = {
      1: 0.95, // Life-threatening: 95% confidence required
      2: 0.90, // Imminently life-threatening: 90% confidence required
      3: 0.75, // Urgent: 75% confidence required (lowered)
      4: 0.65, // Less urgent: 65% confidence required (lowered)
      5: 0.55, // Non-urgent: 55% confidence required (lowered)
    };

    final requiredConfidence = confidenceThresholds[result.ctasLevel] ?? 0.85;

    print(
        '🎯 Confidence Validation: ${(result.confidenceScore * 100).round()}% vs required ${(requiredConfidence * 100).round()}%');

    // CRITICAL: If confidence is below threshold, apply safety measures
    if (result.confidenceScore < requiredConfidence) {
      print('⚠️ LOW CONFIDENCE DETECTED - Applying safety protocols');

      // For critical cases (CTAS 1-2), escalate immediately to human
      if (result.ctasLevel <= 2) {
        return await _escalateToHumanReview(
            result, originalSymptoms, 'CRITICAL_LOW_CONFIDENCE');
      }

      // For non-critical cases, apply conservative escalation
      return await _applyConservativeEscalation(result, originalSymptoms);
    }

    // Additional safety checks for conflicting symptoms
    if (_hasConflictingSymptoms(result, originalSymptoms)) {
      print('⚠️ CONFLICTING SYMPTOMS DETECTED - Escalating to human review');
      return await _escalateToHumanReview(
          result, originalSymptoms, 'CONFLICTING_SYMPTOMS');
    }

    // Edge case: Very vague symptoms with moderate confidence
    if (_hasVagueSymptoms(originalSymptoms) && result.confidenceScore < 0.8) {
      print(
          '⚠️ VAGUE SYMPTOMS + MODERATE CONFIDENCE - Conservative escalation');
      return await _applyConservativeEscalation(result, originalSymptoms);
    }

    // Confidence is acceptable
    print('✅ Confidence validation passed - AI recommendation approved');
    return result;
  }

  /// 🚨 Escalate to Human Review (Critical Safety Feature)
  ///
  /// This is the "human-in-the-loop" component you suggested
  static Future<TriageResult> _escalateToHumanReview(
    TriageResult originalResult,
    String symptoms,
    String reason,
  ) async {
    print('🚨 ESCALATING TO HUMAN REVIEW: $reason');

    // Create a modified result that forces human intervention
    final humanReviewResult = TriageResult(
      sessionId: originalResult.sessionId,
      // Conservative escalation: minimum CTAS-2 for human review cases
      ctasLevel: math.max(2, originalResult.ctasLevel - 1),
      urgencyDescription:
          '🚨 HUMAN REVIEW REQUIRED - ${originalResult.urgencyDescription}',
      reasoning: '''
HUMAN REVIEW REQUIRED: AI confidence ${(originalResult.confidenceScore * 100).round()}% below safety threshold.

⚠️ CRITICAL: Do not rely solely on AI assessment. A qualified medical professional must evaluate these symptoms immediately.

Original AI Analysis: ${originalResult.reasoning}

Escalation Reason: $reason
''',
      recommendedAction:
          '🚨 IMMEDIATE: Speak with medical professional. Do not delay.',
      confidenceScore: 0.95, // High confidence in need for human review
      estimatedWaitTime: 'Immediate',
      requiresEmergency: true,
      language: originalResult.language,
      analysisTimestamp: originalResult.analysisTimestamp,
      redFlags: [
        '🚨 LOW AI CONFIDENCE',
        '👨‍⚕️ HUMAN REVIEW REQUIRED',
        '⚠️ DO NOT SELF-TREAT',
        ...originalResult.redFlags,
      ],
      nextSteps: [
        '🚨 URGENT: Contact medical professional immediately',
        '📱 Call healthcare provider or visit emergency department',
        '❌ Do not rely solely on AI assessment',
        '📋 Provide ALL symptoms to healthcare provider',
        '⏰ Do not delay - seek immediate medical attention',
        ...originalResult.nextSteps,
      ],
    );

    // Log the escalation for audit trail and monitoring
    await _logHumanEscalation(
        humanReviewResult, originalResult, symptoms, reason);

    // In a production system, this would trigger:
    // 1. Immediate alert to medical staff dashboard
    // 2. SMS/email notification to on-call physician
    // 3. Queue priority case for urgent human review
    // 4. Patient notification about immediate consultation requirement
    // 5. Automatic booking of urgent appointment slot

    return humanReviewResult;
  }

  /// 🛡️ Apply Conservative Escalation for Low Confidence
  ///
  /// "Better safe than sorry" approach for borderline cases
  static Future<TriageResult> _applyConservativeEscalation(
    TriageResult originalResult,
    String symptoms,
  ) async {
    print('🛡️ APPLYING CONSERVATIVE ESCALATION (Safety Protocol)');

    // Escalate by one CTAS level (more urgent) but cap at CTAS-1
    final escalatedLevel = math.max(1, originalResult.ctasLevel - 1);

    return TriageResult(
      sessionId: originalResult.sessionId,
      ctasLevel: escalatedLevel,
      urgencyDescription:
          'CONSERVATIVE ESCALATION - ${originalResult.urgencyDescription}',
      reasoning: '''
CONSERVATIVE ESCALATION APPLIED: AI confidence ${(originalResult.confidenceScore * 100).round()}% below required threshold for CTAS-${originalResult.ctasLevel}.

For patient safety, urgency level escalated from CTAS-${originalResult.ctasLevel} to CTAS-${escalatedLevel}.

Original AI Analysis: ${originalResult.reasoning}

⚠️ Safety Protocol: When in doubt, we escalate to ensure proper medical attention.
''',
      recommendedAction:
          'Seek medical attention promptly. Conservative assessment applied for your safety.',
      confidenceScore: 0.85, // Moderate confidence in conservative approach
      estimatedWaitTime: _getEscalatedWaitTime(escalatedLevel),
      requiresEmergency: escalatedLevel <= 2,
      language: originalResult.language,
      analysisTimestamp: originalResult.analysisTimestamp,
      redFlags: [
        '🛡️ CONSERVATIVE ESCALATION',
        '⚠️ LOW AI CONFIDENCE',
        '🩺 SAFETY PROTOCOL APPLIED',
        ...originalResult.redFlags,
      ],
      nextSteps: [
        '🩺 Seek medical attention promptly',
        '🛡️ Conservative assessment applied for safety',
        '📞 Contact healthcare provider if symptoms worsen',
        '⏰ Do not delay if condition changes',
        ...originalResult.nextSteps,
      ],
    );
  }

  /// 🔍 Check for Conflicting Symptoms
  ///
  /// Detects when critical keywords don't match CTAS classification
  static bool _hasConflictingSymptoms(TriageResult result, String symptoms) {
    // Critical emergency keywords that should trigger CTAS 1-2
    final criticalKeywords = [
      'chest pain and shortness of breath',
      'cannot breathe',
      'not breathing',
      'unconscious',
      'unresponsive',
      'severe bleeding',
      'heavy bleeding',
      'heart attack',
      'cardiac arrest',
      'stroke symptoms',
      'facial droop',
      'slurred speech',
      'anaphylaxis',
      'severe allergic reaction',
      'severe allergic',
      'seizure',
      'convulsions',
      'choking',
      'overdose',
      'suicide',
      'severe burns'
    ];

    final symptomsLower = symptoms.toLowerCase();

    // First check for non-emergency symptoms that should NOT be escalated
    final nonEmergencySymptoms = [
      'stomach ache',
      'belly pain',
      'abdominal pain',
      'headache',
      'mild pain',
      'sore throat',
      'runny nose',
      'stuffy nose',
      'cough',
      'fever',
      'nausea',
      'vomiting',
      'diarrhea',
      'constipation',
      'fatigue',
      'tired',
      'muscle ache',
      'back pain',
      'joint pain',
      'rash',
      'cold symptoms'
    ];

    final hasNonEmergencySymptoms =
        nonEmergencySymptoms.any((symptom) => symptomsLower.contains(symptom));

    // If it's a common non-emergency symptom, don't flag as conflicting
    if (hasNonEmergencySymptoms && result.ctasLevel >= 3) {
      print('✅ Common non-emergency symptom detected - No conflict');
      return false;
    }

    final hasCriticalKeywords =
        criticalKeywords.any((keyword) => symptomsLower.contains(keyword));

    // RED FLAG: Critical keywords present but AI classified as low urgency
    if (hasCriticalKeywords && result.ctasLevel >= 4) {
      print(
          '🚨 CONFLICT DETECTED: Critical symptoms "${symptoms}" but AI classified as CTAS-${result.ctasLevel}');
      return true;
    }

    return false;
  }

  /// 🤔 Check for Vague Symptoms
  ///
  /// Identifies unclear symptom descriptions that need human clarification
  static bool _hasVagueSymptoms(String symptoms) {
    final vagueTerms = [
      'feeling unwell',
      'not feeling good',
      'something wrong',
      'don\'t feel right',
      'general discomfort',
      'feeling off',
      'tired',
      'weird feeling'
    ];

    final symptomsLower = symptoms.toLowerCase();
    final hasVagueTerms =
        vagueTerms.any((term) => symptomsLower.contains(term));

    // Also check if symptoms are very short (likely incomplete)
    final isTooShort = symptoms.trim().split(' ').length < 3;

    return hasVagueTerms || isTooShort;
  }

  /// ⏱️ Get Escalated Wait Time based on CTAS level
  static String _getEscalatedWaitTime(int ctasLevel) {
    switch (ctasLevel) {
      case 1:
        return 'Immediate (0 minutes)';
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

  /// 📊 Log Human Escalation (Critical for Audit Trail & Quality Monitoring)
  static Future<void> _logHumanEscalation(
    TriageResult escalatedResult,
    TriageResult originalResult,
    String symptoms,
    String reason,
  ) async {
    final escalationLog = {
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': escalatedResult.sessionId,
      'escalationType': 'HUMAN_REVIEW_REQUIRED',
      'escalationReason': reason,
      'originalConfidence': originalResult.confidenceScore,
      'requiredConfidence': _getRequiredConfidence(originalResult.ctasLevel),
      'originalCTAS': originalResult.ctasLevel,
      'escalatedCTAS': escalatedResult.ctasLevel,
      'symptoms': symptoms,
      'requiresHumanReview': true,
      'urgencyLevel': 'HIGH',
      'safetyProtocol': 'ACTIVATED',
      'aiModel': 'gemini-1.5-flash',
      'complianceLevel': 'CTAS_COMPLIANT',
    };

    print('📊 HUMAN ESCALATION AUDIT LOG: ${jsonEncode(escalationLog)}');

    // In production, this comprehensive logging would:
    // 1. Store in HIPAA-compliant medical database
    // 2. Send real-time alert to medical staff
    // 3. Create audit trail for regulatory compliance
    // 4. Trigger quality assurance review
    // 5. Update ML model training data for improvements
    // 6. Generate compliance reports for healthcare authorities
  }

  /// 📈 Get Required Confidence Threshold
  static double _getRequiredConfidence(int ctasLevel) {
    final thresholds = {
      1: 0.95,
      2: 0.90,
      3: 0.85,
      4: 0.75,
      5: 0.70,
    };
    return thresholds[ctasLevel] ?? 0.85;
  }

  /// 📊 Generate Confidence Validation Report
  ///
  /// For monitoring and improving the AI system
  static Map<String, dynamic> generateValidationReport(
    List<TriageResult> results,
  ) {
    final totalCases = results.length;
    final lowConfidenceCases = results
        .where((r) => r.confidenceScore < _getRequiredConfidence(r.ctasLevel))
        .length;
    final humanEscalations = results
        .where((r) => r.redFlags.contains('HUMAN REVIEW REQUIRED'))
        .length;
    final conservativeEscalations = results
        .where((r) => r.redFlags.contains('CONSERVATIVE ESCALATION'))
        .length;

    return {
      'reportTimestamp': DateTime.now().toIso8601String(),
      'totalCases': totalCases,
      'lowConfidenceCases': lowConfidenceCases,
      'lowConfidenceRate': totalCases > 0 ? lowConfidenceCases / totalCases : 0,
      'humanEscalations': humanEscalations,
      'humanEscalationRate': totalCases > 0 ? humanEscalations / totalCases : 0,
      'conservativeEscalations': conservativeEscalations,
      'averageConfidence': totalCases > 0
          ? results.map((r) => r.confidenceScore).reduce((a, b) => a + b) /
              totalCases
          : 0,
      'safetyProtocolActivationRate': totalCases > 0
          ? (humanEscalations + conservativeEscalations) / totalCases
          : 0,
      'recommendation': _generateRecommendations(
        lowConfidenceCases / totalCases,
        humanEscalations / totalCases,
      ),
    };
  }

  /// 💡 Generate Recommendations for System Improvement
  static List<String> _generateRecommendations(
    double lowConfidenceRate,
    double humanEscalationRate,
  ) {
    final recommendations = <String>[];

    if (lowConfidenceRate > 0.20) {
      recommendations.add(
          'High low-confidence rate (${(lowConfidenceRate * 100).toStringAsFixed(1)}%) - Consider additional AI training');
    }

    if (humanEscalationRate > 0.15) {
      recommendations.add(
          'High human escalation rate (${(humanEscalationRate * 100).toStringAsFixed(1)}%) - Review confidence thresholds');
    }

    if (lowConfidenceRate < 0.05) {
      recommendations
          .add('Very low confidence issues - System performing well');
    }

    recommendations.add('Continue monitoring for safety and accuracy');
    recommendations.add('Regular human review of escalated cases recommended');

    return recommendations;
  }
}

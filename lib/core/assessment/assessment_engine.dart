import '../../models/unit_model.dart';

/// Result of a final unit assessment.
class AssessmentResult {
  final int totalQuestions;
  final int correctAnswers;
  final double score;
  final bool passed;

  const AssessmentResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.passed,
  });
}

/// Pure assessment logic kept separate from the quiz/training flow.
///
/// For very short assessments (1–2 questions), one correct answer is enough
/// to avoid turning a single mistake into a hard block for young learners.
/// Longer assessments keep the 70% mastery threshold.
class AssessmentEngine {
  static const double passThreshold = 0.70;
  static const double shortAssessmentThreshold = 0.50;

  const AssessmentEngine();

  double thresholdFor(int questionCount) {
    return questionCount <= 2 ? shortAssessmentThreshold : passThreshold;
  }

  AssessmentResult evaluate({
    required List<ChoiceQuestion> questions,
    required List<int> selectedAnswers,
  }) {
    if (questions.isEmpty) {
      return const AssessmentResult(
        totalQuestions: 0,
        correctAnswers: 0,
        score: 0,
        passed: false,
      );
    }

    final count = selectedAnswers.length < questions.length
        ? selectedAnswers.length
        : questions.length;
    var correct = 0;
    for (var i = 0; i < count; i++) {
      if (selectedAnswers[i] == questions[i].correctIndex) {
        correct++;
      }
    }

    final score = correct / questions.length;
    return AssessmentResult(
      totalQuestions: questions.length,
      correctAnswers: correct,
      score: score,
      passed: score >= thresholdFor(questions.length),
    );
  }
}

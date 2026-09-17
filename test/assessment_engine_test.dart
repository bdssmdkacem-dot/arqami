import 'package:flutter_test/flutter_test.dart';
import 'package:arqami/core/assessment/assessment_engine.dart';
import 'package:arqami/models/unit_model.dart';

ChoiceQuestion question(int correctIndex) => ChoiceQuestion(
      questionAr: 'سؤال',
      options: const ['أ', 'ب', 'ج'],
      correctIndex: correctIndex,
    );

void main() {
  const engine = AssessmentEngine();
  final questions = [question(0), question(1), question(2), question(0)];

  test('passes when score reaches the 70 percent threshold', () {
    final result = engine.evaluate(
      questions: questions,
      selectedAnswers: const [0, 1, 2, 1],
    );

    expect(result.totalQuestions, 4);
    expect(result.correctAnswers, 3);
    expect(result.score, 0.75);
    expect(result.passed, isTrue);
  });

  test('fails below the 70 percent threshold', () {
    final result = engine.evaluate(
      questions: questions,
      selectedAnswers: const [0, 1, 1, 1],
    );

    expect(result.correctAnswers, 2);
    expect(result.score, 0.5);
    expect(result.passed, isFalse);
  });

  test('an incomplete assessment cannot pass', () {
    final result = engine.evaluate(
      questions: questions,
      selectedAnswers: const [0, 1],
    );

    expect(result.correctAnswers, 2);
    expect(result.score, 0.5);
    expect(result.passed, isFalse);
  });

  test('a retry can pass after an earlier failure', () {
    final failed = engine.evaluate(
      questions: questions,
      selectedAnswers: const [0, 1, 1, 1],
    );
    final retried = engine.evaluate(
      questions: questions,
      selectedAnswers: const [0, 1, 2, 0],
    );

    expect(failed.passed, isFalse);
    expect(retried.passed, isTrue);
    expect(retried.correctAnswers, 4);
  });

  test('empty assessments never pass', () {
    final result = engine.evaluate(
      questions: const [],
      selectedAnswers: const [],
    );

    expect(result.passed, isFalse);
    expect(result.score, 0);
  });
}

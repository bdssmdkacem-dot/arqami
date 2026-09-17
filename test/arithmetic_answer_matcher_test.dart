import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/answer/arithmetic_answer_matcher.dart';
import 'package:arqami/models/unit_model.dart';

void main() {
  test('matches integer and decimal answers using Arabic and Western digits', () {
    expect(ArithmeticAnswerMatcher.matches(
      const ArithmeticQuestion(questionAr: '4 + 0 = ؟', correctAnswer: 4),
      '٤',
    ), isTrue);
    expect(ArithmeticAnswerMatcher.matches(
      const ArithmeticQuestion(questionAr: '0.5 = ؟', correctAnswer: 0.5),
      '٠٫٥',
    ), isTrue);
    expect(ArithmeticAnswerMatcher.matches(
      const ArithmeticQuestion(questionAr: '1.5 = ؟', correctAnswer: 1.5),
      '1,5',
    ), isTrue);
  });

  test('matches textual remainder answers despite spacing and digit variants', () {
    const question = ArithmeticQuestion(
      questionAr: '14 ÷ 3 = ؟',
      correctAnswerText: '4 والباقي 2',
    );
    expect(ArithmeticAnswerMatcher.matches(question, '٤ والباقي ٢'), isTrue);
    expect(ArithmeticAnswerMatcher.matches(question, '4 و الباقي 2'), isTrue);
    expect(ArithmeticAnswerMatcher.matches(question, '4  والباقي   2'), isTrue);
    expect(ArithmeticAnswerMatcher.matches(question, '4 والباقي 1'), isFalse);
  });

  test('does not accept invalid numeric answers', () {
    const question = ArithmeticQuestion(questionAr: '8 = ؟', correctAnswer: 8);
    expect(ArithmeticAnswerMatcher.matches(question, ''), isFalse);
    expect(ArithmeticAnswerMatcher.matches(question, '9'), isFalse);
  });
}

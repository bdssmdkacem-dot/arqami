import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/models/deep_curriculum_fixes.dart';
import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  setUp(applyDeepCurriculumFixes);

  test('unit 15 matching pairs have unique pedagogical targets', () {
    final unit = UnitsData.units[14];
    final matching = unit.sourceActivities.whereType<MatchingActivityConfig>().single;

    final targets = matching.pairs.map((pair) => pair.rightValue).toList();

    expect(targets, [4, 8, 0]);
    expect(targets.toSet().length, targets.length);
    expect(matching.pairs[0].rightType, MatchContentType.quantity);
    expect(matching.pairs[1].rightType, MatchContentType.quantity);
    expect(matching.pairs[2].rightType, MatchContentType.quantity);
  });

  test('unit 15 keeps assessment separate from training quiz', () {
    final unit = UnitsData.units[14];
    final quizzes = unit.sourceActivities.whereType<MultipleChoiceActivityConfig>().toList();
    final assessments = unit.sourceActivities.whereType<AssessmentActivityConfig>().toList();

    expect(quizzes, hasLength(1));
    expect(assessments, hasLength(1));
    expect(assessments.single.questions, hasLength(2));
    expect(assessments.single.questions.first.questionAr, '18 = ؟');
  });

  test('unit 41 does not use ambiguous multiplication matching', () {
    final unit = UnitsData.units[40];

    expect(unit.sourceActivities.whereType<MatchingActivityConfig>(), isEmpty);
    final arithmetic = unit.sourceActivities.whereType<ArithmeticActivityConfig>().single;
    expect(arithmetic.questions.map((q) => q.correctAnswer), [12, 20, 12]);
  });

  test('unit 44 does not use ambiguous division matching', () {
    final unit = UnitsData.units[43];

    expect(unit.sourceActivities.whereType<MatchingActivityConfig>(), isEmpty);
    final arithmetic = unit.sourceActivities.whereType<ArithmeticActivityConfig>().single;
    expect(arithmetic.questions.map((q) => q.correctAnswer), [4, 4, 4, 12]);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/models/deep_curriculum_fixes.dart';
import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  setUp(applyDeepCurriculumFixes);

  test('unit 15 matching pairs have unique pedagogical targets', () {
    final unit = UnitsData.units[14];
    final matching = unit.activities.whereType<MatchingActivityConfig>().single;

    final targets = matching.pairs.map((pair) => pair.rightValue).toList();

    expect(targets, [4, 8, 0]);
    expect(targets.toSet().length, targets.length);
    expect(matching.pairs[0].rightType, MatchContentType.quantity);
    expect(matching.pairs[1].rightType, MatchContentType.quantity);
    expect(matching.pairs[2].rightType, MatchContentType.quantity);
  });

  test('unit 15 keeps assessment separate from training quiz', () {
    final unit = UnitsData.units[14];
    final quizzes = unit.activities.whereType<MultipleChoiceActivityConfig>().toList();
    final assessments = unit.activities.whereType<AssessmentActivityConfig>().toList();

    expect(quizzes, hasLength(1));
    expect(assessments, hasLength(1));
    expect(assessments.single.questions, hasLength(2));
    expect(assessments.single.questions.first.questionAr, '18 = ؟');
  });
}

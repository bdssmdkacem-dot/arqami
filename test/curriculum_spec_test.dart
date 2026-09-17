import 'package:flutter_test/flutter_test.dart';
import 'package:arqami/models/curriculum_spec.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  test('all 52 units have a complete learning specification', () {
    expect(UnitsData.units.length, 52);

    for (final unit in UnitsData.units) {
      final spec = CurriculumSpecs.forUnit(unit);

      expect(spec.learningGoalAr.trim(), isNotEmpty, reason: 'unit ${unit.order}');
      expect(spec.objectivesAr.length, greaterThanOrEqualTo(2), reason: 'unit ${unit.order}');
      expect(spec.skillsAr.length, greaterThanOrEqualTo(2), reason: 'unit ${unit.order}');
      expect(spec.activityPlanAr.length, inInclusiveRange(4, 6), reason: 'unit ${unit.order}');
      expect(spec.finalChallengeAr.trim(), isNotEmpty, reason: 'unit ${unit.order}');
      expect(spec.estimatedMinutes, greaterThanOrEqualTo(7), reason: 'unit ${unit.order}');
      expect(spec.masteryTarget, inInclusiveRange(.7, 1.0), reason: 'unit ${unit.order}');
    }
  });

  test('unit activity source remains implemented', () {
    for (final unit in UnitsData.units) {
      expect(unit.isImplemented, isTrue, reason: 'unit ${unit.order}');
      expect(unit.sourceActivityCount, greaterThanOrEqualTo(4), reason: 'unit ${unit.order}');
    }
  });
}
test('curriculum activity planner executes a non-empty ordered plan for all 52 units', () {
    for (final unit in UnitsData.units) {
      final planned = CurriculumActivityPlanner.plan(unit);
      expect(planned, isNotEmpty, reason: 'unit ${unit.order}');
      expect(
        planned.length,
        lessThanOrEqualTo(unit.activities.length),
        reason: 'unit ${unit.order}',
      );

      final assessments = planned.whereType<AssessmentActivityConfig>().toList();
      if (assessments.isNotEmpty) {
        expect(planned.last, isA<AssessmentActivityConfig>(),
            reason: 'assessment must remain the final gate for unit ${unit.order}');
      }
    }
  });

}
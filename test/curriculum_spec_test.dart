import 'package:flutter_test/flutter_test.dart';

import '../lib/models/curriculum_spec.dart';
import '../lib/models/units_data.dart';

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

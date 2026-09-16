import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/models/final_curriculum_override.dart';
import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  setUpAll(applyFinalCurriculumStageSplit);

  test('ratio and algebra are independent final stages', () {
    final ratioUnits = UnitsData.units.where((unit) => unit.order >= 49 && unit.order <= 50).toList();
    final algebraUnits = UnitsData.units.where((unit) => unit.order >= 51 && unit.order <= 52).toList();
    expect(ratioUnits, hasLength(2));
    expect(algebraUnits, hasLength(2));
    expect(ratioUnits.every((u) => u.titleAr.contains('النسبة') || u.titleAr.contains('التناسب')), isTrue);
    expect(algebraUnits.every((u) => u.titleAr.contains('الجبر') || u.titleAr.contains('المتغيرات') || u.titleAr.contains('المعادلات')), isTrue);
    expect(ratioUnits.last.order, lessThan(algebraUnits.first.order));
    expect(UnitsData.units.last.order, 52);
  });

  test('each final-stage unit remains learnable and assessable', () {
    for (final unit in UnitsData.units.where((u) => u.order >= 49)) {
      expect(unit.activities, isNotEmpty);
      expect(unit.activities.whereType<LessonActivityConfig>(), isNotEmpty);
      expect(unit.activities.whereType<MultipleChoiceActivityConfig>(), isNotEmpty);
      expect(unit.activities.whereType<AssessmentActivityConfig>(), hasLength(1));
      expect(unit.activities.whereType<AssessmentActivityConfig>().single.questions.length, greaterThanOrEqualTo(2));
    }
  });
}

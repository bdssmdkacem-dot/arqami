import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/models/final_curriculum_override.dart';
import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  setUpAll(applyFinalCurriculumStageSplit);

  test('ratio and algebra are independent final stages', () {
    final ratioUnits = UnitsData.units.where((unit) => unit.order >= 49 && unit.order <= 51).toList();
    final algebraUnits = UnitsData.units.where((unit) => unit.order == 52).toList();
    expect(ratioUnits, hasLength(3));
    expect(algebraUnits, hasLength(1));
    expect(ratioUnits.any((u) => u.titleAr.contains('النسبة')), isTrue);
    expect(UnitsData.units.last.order, 52);
  });

  test('all 52 units exist in order', () {
    expect(UnitsData.units, hasLength(52));
    for (var i = 0; i < UnitsData.units.length; i++) {
      expect(UnitsData.units[i].order, i + 1);
      expect(UnitsData.units[i].id, 'unit_${(i + 1).toString().padLeft(2, '0')}');
      expect(UnitsData.units[i].activities, isNotEmpty);
    }
  });

  test('final-stage units remain learnable, interactive and assessable', () {
    for (final unit in UnitsData.units.where((u) => u.order >= 45)) {
      expect(unit.activities.whereType<LessonActivityConfig>(), isNotEmpty, reason: 'الوحدة ${unit.order} يجب أن تحتوي درساً');
      expect(unit.activities.whereType<MultipleChoiceActivityConfig>(), isNotEmpty, reason: 'الوحدة ${unit.order} يجب أن تحتوي Quiz');
      expect(unit.activities.whereType<AssessmentActivityConfig>(), hasLength(1), reason: 'الوحدة ${unit.order} يجب أن تحتوي Assessment واحداً');
      expect(unit.activities.whereType<AssessmentActivityConfig>().single.questions.length, greaterThanOrEqualTo(2));
    }
  });

  test('final units 45–52 use real subject activities instead of MCQ-only content', () {
    final u45 = UnitsData.units[44];
    final u46 = UnitsData.units[45];
    final u47 = UnitsData.units[46];
    final u48 = UnitsData.units[47];
    final u49 = UnitsData.units[48];
    final u50 = UnitsData.units[49];
    final u51 = UnitsData.units[50];
    final u52 = UnitsData.units[51];

    expect(u45.activities.whereType<ArithmeticActivityConfig>(), isNotEmpty);
    expect(u46.activities.whereType<WordProblemActivityConfig>(), isNotEmpty);
    expect(u47.activities.whereType<MultipleChoiceActivityConfig>().single.questions.length, greaterThanOrEqualTo(3));
    expect(u48.activities.whereType<ArithmeticActivityConfig>(), isNotEmpty);
    expect(u49.activities.whereType<ArithmeticActivityConfig>(), isNotEmpty);
    expect(u50.activities.whereType<ArithmeticActivityConfig>(), isNotEmpty);
    expect(u51.activities.whereType<ArithmeticActivityConfig>(), isNotEmpty);
    expect(u52.activities.whereType<ReviewActivityConfig>(), isNotEmpty);
    expect(u52.activities.whereType<ArithmeticActivityConfig>(), hasLength(2));
  });
}

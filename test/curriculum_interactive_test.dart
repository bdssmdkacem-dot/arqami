import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  UnitModel unit(int order) => UnitsData.units.singleWhere((u) => u.order == order);

  test('units 14-20 teach two-digit numbers with interactive practice', () {
    for (var order = 14; order <= 20; order++) {
      final activities = unit(order).activities;
      expect(activities.whereType<MatchingActivityConfig>(), isNotEmpty, reason: 'unit_$order needs number-building/matching practice');
      expect(activities.whereType<ComparisonActivityConfig>(), isNotEmpty, reason: 'unit_$order needs comparison practice');
      expect(activities.length, greaterThan(4), reason: 'unit_$order must not collapse to Lesson + MCQ + Assessment');
    }
  });

  test('unit 21 is a real gateway review before hundreds', () {
    final activities = unit(21).activities;
    expect(activities.whereType<ReviewActivityConfig>(), hasLength(1));
    expect(activities.whereType<MultipleChoiceActivityConfig>(), isNotEmpty);
    expect(activities.whereType<AssessmentActivityConfig>(), hasLength(1));
    expect(activities.length, greaterThan(4));
  });

  test('units 22-27 teach hundreds with place-value and comparison practice', () {
    for (var order = 22; order <= 27; order++) {
      final activities = unit(order).activities;
      expect(activities.whereType<MatchingActivityConfig>(), isNotEmpty, reason: 'unit_$order needs place-value/building practice');
      expect(activities.whereType<ComparisonActivityConfig>(), isNotEmpty, reason: 'unit_$order needs comparison practice');
      expect(activities.length, greaterThan(4), reason: 'unit_$order must not be MCQ-only');
    }
  });

  test('units 28-33 teach thousands with place-value and comparison practice', () {
    for (var order = 28; order <= 33; order++) {
      final activities = unit(order).activities;
      expect(activities.whereType<MatchingActivityConfig>(), isNotEmpty, reason: 'unit_$order needs four-digit construction practice');
      expect(activities.whereType<ComparisonActivityConfig>(), isNotEmpty, reason: 'unit_$order needs comparison practice');
      expect(activities.length, greaterThan(4), reason: 'unit_$order must not be MCQ-only');
    }
  });

  test('unit 34 is a comprehensive gateway review through 9999', () {
    final activities = unit(34).activities;
    expect(activities.whereType<ReviewActivityConfig>(), hasLength(1));
    expect(activities.whereType<AssessmentActivityConfig>(), hasLength(1));
    expect(activities.length, greaterThan(4));
  });

  test('units 35-40 use real arithmetic activities', () {
    for (var order = 35; order <= 40; order++) {
      final activities = unit(order).activities;
      final arithmetic = activities.whereType<ArithmeticActivityConfig>().toList();
      expect(arithmetic, hasLength(1), reason: 'unit_$order needs direct arithmetic');
      expect(arithmetic.single.questions.length, greaterThanOrEqualTo(3), reason: 'unit_$order needs multiple calculation exercises');
      expect(activities.length, greaterThan(4), reason: 'unit_$order must not be MCQ-only');
    }
  });

  test('units 37 and 40 convert word problems into actual calculation practice', () {
    for (final order in [37, 40]) {
      final activities = unit(order).activities;
      final wordProblems = activities.whereType<WordProblemActivityConfig>().toList();
      expect(wordProblems, hasLength(1), reason: 'unit_$order needs word-problem activity');
      expect(wordProblems.single.questions.length, greaterThanOrEqualTo(2));
      expect(wordProblems.single.questions.every((q) => q.correctAnswer != null), isTrue);
    }
  });

  test('units 41-44 build multiplication and division through non-MCQ practice', () {
    for (var order = 41; order <= 44; order++) {
      final activities = unit(order).activities;
      final arithmetic = activities.whereType<ArithmeticActivityConfig>().toList();
      expect(arithmetic, hasLength(1), reason: 'unit_$order needs direct numeric practice');
      expect(arithmetic.single.questions.length, greaterThanOrEqualTo(3), reason: 'unit_$order needs repeated calculation practice');
      expect(activities.length, greaterThan(4), reason: 'unit_$order must not be MCQ-only');
    }

    expect(unit(41).activities.whereType<MatchingActivityConfig>(), isNotEmpty);
    expect(unit(44).activities.whereType<MatchingActivityConfig>(), isNotEmpty);
  });

  test('units 35-44 contain meaningful operation-specific content', () {
    final expectedOperations = <int, String>{
      35: 'جمع بدون حمل',
      36: 'جمع مع الحمل',
      38: 'طرح بدون استلاف',
      39: 'طرح مع الاستلاف',
      41: 'الجمع المتكرر إلى الضرب',
      42: 'جداول الضرب 2–10',
      43: 'الضرب العمودي',
      44: 'القسمة والتوزيع المتساوي',
    };

    for (final entry in expectedOperations.entries) {
      final arithmetic = unit(entry.key).activities.whereType<ArithmeticActivityConfig>().single;
      expect(arithmetic.operation, entry.value, reason: 'unit_${entry.key}');
    }
  });
}

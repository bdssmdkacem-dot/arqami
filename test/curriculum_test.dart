import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/models/number_path.dart';
import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  test('curriculum covers 3-16 years with ordered units', () {
    expect(UnitsData.units.length, greaterThanOrEqualTo(50));

    for (var i = 0; i < UnitsData.units.length; i++) {
      final unit = UnitsData.units[i];
      expect(unit.order, i + 1);
      expect(unit.id, 'unit_${(i + 1).toString().padLeft(2, '0')}');
      expect(unit.activities, isNotEmpty);
      expect(unit.isImplemented, isTrue);
      expect(unit.ageRangeAr, isNotEmpty);
    }
  });

  test('curriculum progresses through core math domains', () {
    final titles = UnitsData.units.map((u) => u.titleAr).join(' | ');
    expect(titles, contains('الأعداد حتى 9,999'));
    expect(titles, contains('الجمع مع الحمل'));
    expect(titles, contains('الطرح مع الاستلاف'));
    expect(titles, contains('جداول الضرب 7 و8 و9'));
    expect(titles, contains('القسمة مع الباقي'));
    expect(titles, contains('مفهوم الكسور'));
    expect(titles, contains('الأعداد العشرية'));
    expect(titles, contains('النسبة المئوية'));
    expect(titles, contains('المتغيرات والتعبيرات الجبرية'));
    expect(titles, contains('المعادلات ذات الخطوتين'));
  });

  test('curriculum uses lessons, arithmetic, word problems and assessments', () {
    final activities = UnitsData.units.expand((u) => u.activities);
    expect(activities.whereType<LessonActivityConfig>(), isNotEmpty);
    expect(activities.whereType<ArithmeticActivityConfig>(), isNotEmpty);
    expect(activities.whereType<WordProblemActivityConfig>(), isNotEmpty);
    expect(activities.whereType<MultipleChoiceActivityConfig>(), isNotEmpty);
    expect(activities.whereType<AssessmentActivityConfig>(), isNotEmpty);
  });

  test('arithmetic model supports integers, decimals and compound answers', () {
    const integer = ArithmeticQuestion(questionAr: '3 + 4 = ؟', correctAnswer: 7);
    const decimal = ArithmeticQuestion(questionAr: '1.5 + 2.5 = ؟', correctAnswer: 4.0);
    const remainder = ArithmeticQuestion(
      questionAr: '14 ÷ 3 = ؟',
      correctAnswerText: '4 والباقي 2',
    );

    expect(integer.correctAnswer, 7);
    expect(decimal.correctAnswer, 4.0);
    expect(remainder.correctAnswerText, '4 والباقي 2');
  });

  test('decimal curriculum exercises have numeric answers', () {
    final unit44 = UnitsData.units.firstWhere((unit) => unit.id == 'unit_44');
    final activity = unit44.activities.whereType<ArithmeticActivityConfig>().single;
    expect(activity.questions, hasLength(2));
    expect(activity.questions.every((question) => question.correctAnswer != null), isTrue);
    expect(activity.questions.first.correctAnswer, 4);
    expect(activity.questions.last.correctAnswer, 5);
  });

  test('all digit paths 0-9 exist and contain valid points', () {
    for (var digit = 0; digit <= 9; digit++) {
      expect(NumberPathData.hasPath(digit), isTrue);
      final path = NumberPathData.getPath(digit);
      expect(path.points, isNotEmpty);
      expect(path.strokeSegments, isNotEmpty);

      for (final point in path.points) {
        expect(point.x, inInclusiveRange(0.0, 1.0));
        expect(point.y, inInclusiveRange(0.0, 1.0));
      }

      for (final breakIndex in path.strokeBreaks) {
        expect(breakIndex, greaterThan(0));
        expect(breakIndex, lessThan(path.points.length));
      }
    }
  });

  test('multi-stroke paths preserve the declared stroke order', () {
    final four = NumberPathData.getPath(4);
    expect(four.strokeBreaks, contains(3));
    expect(four.strokeSegments, hasLength(2));
    expect(four.strokeSegments[0], hasLength(3));
    expect(four.strokeSegments[1], hasLength(2));
    expect(four.strokeSegments[0].first.x, closeTo(0.60, 0.0001));
    expect(four.strokeSegments[1].first.x, closeTo(0.60, 0.0001));
  });
}

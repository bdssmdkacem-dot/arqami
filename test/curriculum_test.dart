import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/profile/learner_profile.dart';
import 'package:arqami/core/profile/age_activity_adapter.dart';
import 'package:arqami/models/number_path.dart';
import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  test('curriculum covers 3-16 years with 52 ordered units', () {
    expect(UnitsData.units.length, 52);

    for (var i = 0; i < UnitsData.units.length; i++) {
      final unit = UnitsData.units[i];
      expect(unit.order, i + 1);
      expect(unit.id, 'unit_${(i + 1).toString().padLeft(2, '0')}');
      expect(unit.activities, isNotEmpty);
      expect(unit.isImplemented, isTrue);
      expect(unit.ageRangeAr, isNotEmpty);
    }
  });

  test('every unit has a complete lesson, quiz and assessment', () {
    for (final unit in UnitsData.units) {
      final lessons = unit.activities.whereType<LessonActivityConfig>().toList();
      final quizzes = unit.activities.whereType<MultipleChoiceActivityConfig>().toList();
      final assessments = unit.activities.whereType<AssessmentActivityConfig>().toList();

      expect(lessons, isNotEmpty, reason: unit.id);
      expect(lessons.any((lesson) => lesson.titleAr.isNotEmpty), isTrue, reason: unit.id);
      expect(lessons.any((lesson) => lesson.explanationAr.isNotEmpty), isTrue, reason: unit.id);
      expect(assessments, hasLength(1), reason: unit.id);
      expect(assessments.single.questions.length, greaterThanOrEqualTo(2), reason: unit.id);
      expect(quizzes, isNotEmpty, reason: unit.id);
      expect(quizzes.any((quiz) => quiz.questions.length >= 2), isTrue, reason: unit.id);
    }
  });

  test('curriculum progresses through core math domains', () {
    final titles = UnitsData.units.map((u) => u.titleAr).join(' | ');

    expect(UnitsData.units.any((u) => u.order >= 14 && u.order <= 21), isTrue);
    expect(UnitsData.units.any((u) => u.order >= 22 && u.order <= 27), isTrue);
    expect(UnitsData.units.any((u) => u.order >= 28 && u.order <= 34), isTrue);
    expect(UnitsData.units.any((u) => u.order >= 35 && u.order <= 46), isTrue);
    expect(titles, contains('الكسور'));
    expect(titles, contains('العشرية'));
    expect(titles.contains('النسبة') || titles.contains('التناسب'), isTrue);
    expect(titles.contains('الجبر') || titles.contains('المعادلات'), isTrue);

    final fractionOrder = UnitsData.units
        .firstWhere((u) => u.titleAr.contains('الكسور'))
        .order;
    final decimalOrder = UnitsData.units
        .firstWhere((u) => u.titleAr.contains('العشرية'))
        .order;
    expect(decimalOrder, greaterThan(fractionOrder));
    expect(UnitsData.units.last.order, 52);
  });

  test('curriculum uses lessons, quizzes and assessments', () {
    final activities = UnitsData.units.expand((u) => u.activities);
    expect(activities.whereType<LessonActivityConfig>(), isNotEmpty);
    expect(activities.whereType<MultipleChoiceActivityConfig>(), isNotEmpty);
    expect(activities.whereType<AssessmentActivityConfig>(), isNotEmpty);
  });

  test('all user-facing curriculum digits are western digits only', () {
    final nonWesternDigits = RegExp(r'[٠-٩۰-۹]');

    for (final unit in UnitsData.units) {
      final texts = <String>[unit.titleAr, unit.ageRangeAr, unit.descriptionAr ?? ''];
      for (final activity in unit.activities) {
        if (activity is LessonActivityConfig) {
          texts.add(activity.titleAr);
          texts.add(activity.explanationAr);
          texts.addAll(activity.examplesAr);
        } else if (activity is MultipleChoiceActivityConfig || activity is AssessmentActivityConfig) {
          final questions = activity is MultipleChoiceActivityConfig
              ? activity.questions
              : (activity as AssessmentActivityConfig).questions;
          for (final question in questions) {
            texts.add(question.questionAr);
            texts.addAll(question.options);
            if (question.hintAr != null) texts.add(question.hintAr!);
          }
        } else if (activity is ArithmeticActivityConfig) {
          for (final question in activity.questions) {
            texts.add(question.questionAr);
            if (question.correctAnswerText != null) texts.add(question.correctAnswerText!);
            if (question.hintAr != null) texts.add(question.hintAr!);
          }
        } else if (activity is WordProblemActivityConfig) {
          for (final question in activity.questions) {
            texts.add(question.questionAr);
            if (question.correctAnswerText != null) texts.add(question.correctAnswerText!);
          }
        }
      }

      for (final text in texts) {
        expect(nonWesternDigits.hasMatch(text), isFalse, reason: '${unit.id}: $text');
      }
    }
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

  test('decimal curriculum contains numeric decimal examples and exercises', () {
    final decimalUnits = UnitsData.units.where(
      (unit) => unit.titleAr.contains('الأعداد العشرية'),
    ).toList();
    expect(decimalUnits, isNotEmpty);

    final decimalPattern = RegExp(r'\d+\.\d+');
    final decimalLessons = decimalUnits
        .expand((unit) => unit.sourceActivities)
        .whereType<LessonActivityConfig>();
    final decimalExamples = decimalLessons.expand((lesson) => lesson.examplesAr);
    expect(decimalExamples.any(decimalPattern.hasMatch), isTrue);

    final decimalQuizzes = decimalUnits
        .expand((unit) => unit.sourceActivities)
        .whereType<MultipleChoiceActivityConfig>();
    expect(decimalQuizzes, isNotEmpty);
    expect(
      decimalQuizzes.expand((quiz) => quiz.questions).any(
            (question) => question.options.any(decimalPattern.hasMatch),
          ),
      isTrue,
    );
  });


  test('each unit has real practice beyond lesson, quiz and assessment', () {
    for (final unit in UnitsData.units) {
      final practice = unit.sourceActivities.where((activity) =>
          activity is! LessonActivityConfig &&
          activity is! MultipleChoiceActivityConfig &&
          activity is! AssessmentActivityConfig);
      expect(practice, isNotEmpty, reason: '${unit.id} needs an interactive practice activity');
    }
  });

  test('assessments are separate from quizzes, not copied question-for-question', () {
    for (final unit in UnitsData.units) {
      final quizQuestions = unit.sourceActivities
          .whereType<MultipleChoiceActivityConfig>()
          .expand((quiz) => quiz.questions)
          .map((q) => q.questionAr)
          .toSet();
      final assessment = unit.sourceActivities.whereType<AssessmentActivityConfig>().single;
      final assessmentQuestions = assessment.questions.map((q) => q.questionAr).toSet();

      expect(
        assessmentQuestions.intersection(quizQuestions),
        isEmpty,
        reason: '${unit.id} assessment must measure transfer, not duplicate the quiz',
      );
    }
  });

  test('review exists at the major curriculum transition gates', () {
    const gates = [7, 13, 21, 34, 46, 50, 51, 52];
    for (final order in gates) {
      final unit = UnitsData.units[order - 1];
      expect(
        unit.sourceActivities.whereType<ReviewActivityConfig>(),
        isNotEmpty,
        reason: unit.id,
      );
    }
  });

  test('age bands genuinely change activity sequencing and workload', () {
    final unit = UnitsData.units[49]; // unit 50: decimals
    final early = AgeActivityPlan.forBand(AgeBand.early).adaptUnit(unit);
    final teen = AgeActivityPlan.forBand(AgeBand.teen).adaptUnit(unit);

    expect(early, isNotEmpty);
    expect(teen, isNotEmpty);
    expect(early.length, lessThanOrEqualTo(teen.length));
    expect(early.first, isA<LessonActivityConfig>());
    expect(teen.first, isA<LessonActivityConfig>());
    expect(
      early.indexWhere((a) => a is MultipleChoiceActivityConfig),
      lessThan(early.indexWhere((a) => a is ArithmeticActivityConfig)),
    );
    expect(
      teen.indexWhere((a) => a is ArithmeticActivityConfig),
      lessThan(teen.indexWhere((a) => a is MultipleChoiceActivityConfig)),
    );
  });

  test('late curriculum follows decimal then ratio then percentage and algebra', () {
    expect(UnitsData.units[49].titleAr, contains('العشرية'));
    expect(UnitsData.units[50].titleAr, contains('النسبة والتناسب'));
    expect(UnitsData.units[51].titleAr, contains('النسبة المئوية'));
    expect(UnitsData.units[51].titleAr, contains('الجبر'));

    final decimal = UnitsData.units[49].sourceActivities.expand((a) => a is LessonActivityConfig ? a.examplesAr : const <String>[]).join(' ');
    final ratio = UnitsData.units[50].descriptionAr ?? '';
    final algebra = UnitsData.units[51].descriptionAr ?? '';
    expect(decimal, contains('0.5'));
    expect(ratio, contains('تناسب'));
    expect(algebra, contains('المعادلات'));
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

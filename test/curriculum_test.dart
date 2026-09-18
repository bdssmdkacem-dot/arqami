import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/profile/learner_profile.dart';
import 'package:arqami/core/profile/age_activity_adapter.dart';
import 'package:arqami/models/curriculum_spec.dart';
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
    // Unit 50 is the canonical decimal stage; inspect source activities so
    // age adaptation cannot hide valid decimal content from this curriculum gate.
    final decimalUnit = UnitsData.units.singleWhere((unit) => unit.order == 50);
    expect(decimalUnit.titleAr, contains('العشرية'));

    final decimalPattern = RegExp(r'\d+\.\d+');
    final sourceTexts = <String>[];

    for (final activity in decimalUnit.sourceActivities) {
      if (activity is LessonActivityConfig) {
        sourceTexts.addAll(activity.examplesAr);
        sourceTexts.add(activity.explanationAr);
      } else if (activity is MultipleChoiceActivityConfig) {
        for (final question in activity.questions) {
          sourceTexts.add(question.questionAr);
          sourceTexts.addAll(question.options);
        }
      } else if (activity is ArithmeticActivityConfig) {
        for (final question in activity.questions) {
          sourceTexts.add(question.questionAr);
          if (question.correctAnswerText != null) {
            sourceTexts.add(question.correctAnswerText!);
          }
          if (question.correctAnswer != null) {
            sourceTexts.add(question.correctAnswer.toString());
          }
        }
      }
    }

    expect(
      sourceTexts.any(decimalPattern.hasMatch),
      isTrue,
      reason: 'unit 50 must expose at least one western decimal value in its source content',
    );

    final arithmetic = decimalUnit.sourceActivities
        .whereType<ArithmeticActivityConfig>()
        .expand((activity) => activity.questions);
    expect(
      arithmetic.any((question) =>
          decimalPattern.hasMatch(question.questionAr) ||
          (question.correctAnswer != null &&
              question.correctAnswer.toString().contains('.'))),
      isTrue,
      reason: 'unit 50 must contain an executable decimal exercise',
    );
  });


  test('late-stage assessments use independent scenarios', () {
    for (final order in [40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52]) {
      final unit = UnitsData.units.singleWhere((item) => item.order == order);
      final quiz = unit.sourceActivities
          .whereType<MultipleChoiceActivityConfig>()
          .expand((item) => item.questions)
          .map((item) => item.questionAr)
          .toSet();
      final assessment = unit.sourceActivities
          .whereType<AssessmentActivityConfig>()
          .single;

      expect(
        assessment.questions.any((item) => !quiz.contains(item.questionAr)),
        isTrue,
        reason: '${unit.id} assessment needs an independent scenario',
      );
    }
  });

  test('place-value stage has executable place-value practice in every unit', () {
    for (var order = 14; order <= 34; order++) {
      final unit = UnitsData.units.singleWhere((item) => item.order == order);
      final arithmetic = unit.sourceActivities.whereType<ArithmeticActivityConfig>();
      expect(arithmetic, isNotEmpty, reason: '${unit.id} needs place-value practice');
      expect(
        arithmetic.expand((activity) => activity.questions).length,
        greaterThanOrEqualTo(2),
        reason: '${unit.id} needs at least two place-value exercises',
      );
    }
  });

  test('ratio stage uses text answers for ratio forms and ratio review content', () {
    final ratio = UnitsData.units.singleWhere((unit) => unit.order == 51);
    final arithmetic = ratio.sourceActivities.whereType<ArithmeticActivityConfig>().single;

    expect(
      arithmetic.questions.any((question) => question.correctAnswerText == '4:6'),
      isTrue,
    );
    expect(
      arithmetic.questions.every(
        (question) => !question.questionAr.contains('النسبة') ||
            question.correctAnswer != 0,
      ),
      isTrue,
      reason: 'ratio questions must not use a placeholder numeric answer',
    );

    final review = ratio.sourceActivities.whereType<ReviewActivityConfig>().single;
    final reviewText = review.questions.map((question) => question.questionAr).join(' ');
    expect(reviewText, contains('نسبة'));
    expect(reviewText, contains('أقلام'));
  });

  test('ratio and percentage stages contain executable domain practice', () {
    final ratio = UnitsData.units.singleWhere((unit) => unit.order == 51);
    final ratioArithmetic =
        ratio.sourceActivities.whereType<ArithmeticActivityConfig>().single;
    expect(ratioArithmetic.questions.length, greaterThanOrEqualTo(4));
    expect(
      ratio.sourceActivities.whereType<WordProblemActivityConfig>(),
      isNotEmpty,
    );

    final percentage = UnitsData.units.singleWhere((unit) => unit.order == 52);
    final percentageArithmetic =
        percentage.sourceActivities.whereType<ArithmeticActivityConfig>().single;
    expect(percentageArithmetic.questions.length, greaterThanOrEqualTo(5));
    expect(
      percentage.sourceActivities.whereType<WordProblemActivityConfig>(),
      isNotEmpty,
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

  test('activity engine plans every unit and keeps assessment as final gate', () {
    for (final unit in UnitsData.units) {
      final planned = CurriculumActivityPlanner.plan(unit);
      expect(planned, isNotEmpty, reason: unit.id);
      expect(planned.last, isA<AssessmentActivityConfig>(), reason: unit.id);

      for (final band in AgeBand.values) {
        final adapted = AgeActivityPlan.forBand(band).adaptActivities(
          planned,
          domain: curriculumDomainForUnit(unit.order),
        );
        expect(adapted, isNotEmpty, reason: '${unit.id} / $band');
        expect(adapted.last, isA<AssessmentActivityConfig>(), reason: '${unit.id} / $band');
      }
    }
  });

  test('age-adapted player plan changes workload for young learners', () {
    final unit = UnitsData.units.singleWhere((item) => item.order == 50);
    final planned = CurriculumActivityPlanner.plan(unit);

    final early = AgeActivityPlan.forBand(AgeBand.early).adaptActivities(
      planned,
      domain: curriculumDomainForUnit(unit.order),
    );
    final teen = AgeActivityPlan.forBand(AgeBand.teen).adaptActivities(
      planned,
      domain: curriculumDomainForUnit(unit.order),
    );

    expect(early.length, lessThanOrEqualTo(teen.length));
    expect(
      early.whereType<ArithmeticActivityConfig>().single.questions.length,
      lessThanOrEqualTo(teen.whereType<ArithmeticActivityConfig>().single.questions.length),
    );
    expect(
      early.whereType<MultipleChoiceActivityConfig>().single.questions.length,
      lessThanOrEqualTo(teen.whereType<MultipleChoiceActivityConfig>().single.questions.length),
    );
  });
  test('learner ages map to the correct learning bands', () {
    expect(AgeBand.fromAge(3), AgeBand.early);
    expect(AgeBand.fromAge(5), AgeBand.early);
    expect(AgeBand.fromAge(6), AgeBand.primary);
    expect(AgeBand.fromAge(9), AgeBand.primary);
    expect(AgeBand.fromAge(10), AgeBand.middle);
    expect(AgeBand.fromAge(12), AgeBand.middle);
    expect(AgeBand.fromAge(13), AgeBand.teen);
    expect(AgeBand.fromAge(16), AgeBand.teen);
  });

  test('age plan is explicitly derived from the selected learner age', () {
    expect(AgeActivityPlan.forAge(3).band, AgeBand.early);
    expect(AgeActivityPlan.forAge(6).band, AgeBand.primary);
    expect(AgeActivityPlan.forAge(10).band, AgeBand.middle);
    expect(AgeActivityPlan.forAge(13).band, AgeBand.teen);
    expect(AgeActivityPlan.forAge(3).practiceQuestionLimit, 2);
    expect(AgeActivityPlan.forAge(6).practiceQuestionLimit, 3);
    expect(AgeActivityPlan.forAge(10).practiceQuestionLimit, 999);
    expect(AgeActivityPlan.forAge(13).practiceQuestionLimit, 999);
  });

  test('presentation is explicitly derived from the selected learner age', () {
    expect(AgeActivityPresentation.forAge(3).band, AgeBand.early);
    expect(AgeActivityPresentation.forAge(6).band, AgeBand.primary);
    expect(AgeActivityPresentation.forAge(10).band, AgeBand.middle);
    expect(AgeActivityPresentation.forAge(13).band, AgeBand.teen);
    expect(AgeActivityPresentation.forAge(3).showExtraGuidance, isTrue);
    expect(AgeActivityPresentation.forAge(13).showExtraGuidance, isFalse);
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

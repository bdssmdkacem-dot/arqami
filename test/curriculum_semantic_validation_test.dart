import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/models/deep_curriculum_fixes.dart';
import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';
import 'package:arqami/widgets/games/scene_explore_widget.dart';

void main() {
  setUp(applyDeepCurriculumFixes);

  test('all interactive activity lists are non-empty', () {
    for (final unit in UnitsData.units) {
      expect(unit.activities, isNotEmpty, reason: 'unit ${unit.order} has no activities');
      for (final activity in unit.activities) {
        switch (activity) {
          case MultipleChoiceActivityConfig a:
            expect(a.questions, isNotEmpty, reason: 'unit ${unit.order} has an empty quiz');
          case ReviewActivityConfig a:
            expect(a.questions, isNotEmpty, reason: 'unit ${unit.order} has an empty review');
          case AssessmentActivityConfig a:
            expect(a.questions, isNotEmpty, reason: 'unit ${unit.order} has an empty assessment');
          case ArithmeticActivityConfig a:
            expect(a.questions, isNotEmpty, reason: 'unit ${unit.order} has an empty arithmetic activity');
          case WordProblemActivityConfig a:
            expect(a.questions, isNotEmpty, reason: 'unit ${unit.order} has an empty word-problem activity');
          case MatchingActivityConfig a:
            expect(a.pairs, isNotEmpty, reason: 'unit ${unit.order} has an empty matching activity');
          case LessonActivityConfig _:
          case TraceActivityConfig _:
          case DragCountActivityConfig _:
          case ComparisonActivityConfig _:
          case SceneExploreActivityConfig _:
            break;
        }
      }
    }
  });

  test('all choice-based questions have valid answer indexes and usable options', () {
    for (final unit in UnitsData.units) {
      for (final activity in unit.activities) {
        final questions = switch (activity) {
          MultipleChoiceActivityConfig a => a.questions,
          ReviewActivityConfig a => a.questions,
          AssessmentActivityConfig a => a.questions,
          _ => const <ChoiceQuestion>[],
        };

        for (final question in questions) {
          expect(question.questionAr.trim(), isNotEmpty,
              reason: 'unit ${unit.order} has an empty question');
          expect(question.options.length, greaterThanOrEqualTo(2),
              reason: 'unit ${unit.order}: ${question.questionAr}');
          expect(question.correctIndex, inInclusiveRange(0, question.options.length - 1),
              reason: 'unit ${unit.order}: ${question.questionAr}');
          expect(question.options.every((option) => option.trim().isNotEmpty), isTrue,
              reason: 'unit ${unit.order}: ${question.questionAr}');
        }
      }
    }
  });

  test('all arithmetic questions contain an answer', () {
    for (final unit in UnitsData.units) {
      for (final activity in unit.activities) {
        final questions = switch (activity) {
          ArithmeticActivityConfig a => a.questions,
          WordProblemActivityConfig a => a.questions,
          _ => const <ArithmeticQuestion>[],
        };

        for (final question in questions) {
          expect(question.questionAr.trim(), isNotEmpty,
              reason: 'unit ${unit.order} has an empty arithmetic question');
          expect(question.correctAnswer != null || question.correctAnswerText != null, isTrue,
              reason: 'unit ${unit.order}: ${question.questionAr}');
          if (question.correctAnswerText != null) {
            expect(question.correctAnswerText!.trim(), isNotEmpty,
                reason: 'unit ${unit.order}: ${question.questionAr}');
          }
        }
      }
    }
  });

  test('matching activities use unique non-empty pair ids', () {
    for (final unit in UnitsData.units) {
      for (final activity in unit.activities.whereType<MatchingActivityConfig>()) {
        expect(activity.pairs, isNotEmpty, reason: 'unit ${unit.order}');
        final ids = activity.pairs.map((pair) => pair.id).toList();
        expect(ids.every((id) => id.trim().isNotEmpty), isTrue,
            reason: 'unit ${unit.order}');
        expect(ids.toSet().length, ids.length,
            reason: 'unit ${unit.order} has duplicate matching ids');
      }
    }
  });

  test('comparison activities have non-negative quantities and coherent equality', () {
    for (final unit in UnitsData.units) {
      for (final activity in unit.activities.whereType<ComparisonActivityConfig>()) {
        expect(activity.leftCount, greaterThanOrEqualTo(0), reason: 'unit ${unit.order}');
        expect(activity.rightCount, greaterThanOrEqualTo(0), reason: 'unit ${unit.order}');
        if (activity.question == ComparisonQuestionType.equal) {
          expect(activity.leftCount, activity.rightCount,
              reason: 'unit ${unit.order} labels unequal groups as equal');
        }
        if (activity.question == ComparisonQuestionType.more) {
          expect(activity.leftCount == activity.rightCount, isFalse,
              reason: 'unit ${unit.order} asks more for equal groups');
        }
        if (activity.question == ComparisonQuestionType.fewer) {
          expect(activity.leftCount == activity.rightCount, isFalse,
              reason: 'unit ${unit.order} asks fewer for equal groups');
        }
      }
    }
  });

  test('trace digits and drag-count targets stay inside widget domains', () {
    for (final unit in UnitsData.units) {
      for (final trace in unit.activities.whereType<TraceActivityConfig>()) {
        expect(trace.digit, inInclusiveRange(0, 9), reason: 'unit ${unit.order}');
      }
      for (final drag in unit.activities.whereType<DragCountActivityConfig>()) {
        expect(drag.targetCount, inInclusiveRange(0, 10), reason: 'unit ${unit.order}');
      }
    }
  });

  test('scene explore targets exist in their scene digit domain', () {
    for (final unit in UnitsData.units) {
      for (final activity in unit.activities.whereType<SceneExploreActivityConfig>()) {
        final validDigits = switch (activity.sceneType) {
          SceneType.clock => List<int>.generate(12, (index) => index + 1),
          SceneType.phone => List<int>.generate(10, (index) => index),
          SceneType.carPlate => const [4, 7, 2, 9, 1],
        };
        expect(validDigits, contains(activity.targetDigit),
            reason: 'unit ${unit.order} targets ${activity.targetDigit} in ${activity.sceneType}');
      }
    }
  });
}

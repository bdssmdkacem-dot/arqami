import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/models/final_curriculum_override.dart';
import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  setUpAll(applyFinalCurriculumStageSplit);

  test('all 52 units contain only activity types supported by UnitPlayerScreen', () {
    for (final unit in UnitsData.units) {
      expect(unit.activities, isNotEmpty, reason: unit.id);
      expect(unit.activities.first, isA<LessonActivityConfig>(), reason: unit.id);
      expect(unit.activities.last, isA<AssessmentActivityConfig>(), reason: unit.id);

      for (final activity in unit.activities) {
        expect(
          activity,
          anyOf(
            isA<LessonActivityConfig>(),
            isA<MultipleChoiceActivityConfig>(),
            isA<AssessmentActivityConfig>(),
            isA<ReviewActivityConfig>(),
            isA<ArithmeticActivityConfig>(),
            isA<WordProblemActivityConfig>(),
            isA<TraceActivityConfig>(),
            isA<MatchingActivityConfig>(),
            isA<ComparisonActivityConfig>(),
            isA<SceneExploreActivityConfig>(),
            isA<DragCountActivityConfig>(),
          ),
          reason: '${unit.id}: unsupported ${activity.runtimeType}',
        );
      }
    }
  });

  test('all choice activities have valid non-empty questions and answers', () {
    for (final unit in UnitsData.units) {
      for (final activity in unit.activities) {
        if (activity is MultipleChoiceActivityConfig) {
          _validateChoices(unit.id, activity.questions);
        } else if (activity is ReviewActivityConfig) {
          _validateChoices(unit.id, activity.questions);
        } else if (activity is AssessmentActivityConfig) {
          _validateChoices(unit.id, activity.questions);
        }
      }
    }
  });

  test('all direct-calculation activities have valid answer data', () {
    for (final unit in UnitsData.units) {
      for (final activity in unit.activities) {
        if (activity is ArithmeticActivityConfig) {
          expect(activity.questions, isNotEmpty, reason: unit.id);
          expect(activity.operation, isNotEmpty, reason: unit.id);
          for (final question in activity.questions) {
            expect(question.questionAr, isNotEmpty, reason: unit.id);
            expect(
              question.correctAnswer != null || question.correctAnswerText != null,
              isTrue,
              reason: '${unit.id}: ${question.questionAr}',
            );
          }
        } else if (activity is WordProblemActivityConfig) {
          expect(activity.questions, isNotEmpty, reason: unit.id);
          for (final question in activity.questions) {
            expect(question.questionAr, isNotEmpty, reason: unit.id);
            expect(
              question.correctAnswer != null || question.correctAnswerText != null,
              isTrue,
              reason: '${unit.id}: ${question.questionAr}',
            );
          }
        }
      }
    }
  });
}

void _validateChoices(String unitId, List<ChoiceQuestion> questions) {
  expect(questions, isNotEmpty, reason: unitId);
  for (final question in questions) {
    expect(question.questionAr, isNotEmpty, reason: unitId);
    expect(question.options.length, greaterThanOrEqualTo(2), reason: unitId);
    expect(question.correctIndex, inInclusiveRange(0, question.options.length - 1), reason: unitId);
    expect(question.options.every((option) => option.isNotEmpty), isTrue, reason: unitId);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:arqami/models/curriculum_spec.dart';
import 'package:arqami/models/units_data.dart';
import 'package:arqami/models/unit_model.dart';

void main() {
  test('all 52 units have a complete learning specification', () {
    expect(UnitsData.units.length, 52);

    for (final unit in UnitsData.units) {
      final spec = CurriculumSpecs.forUnit(unit);

      expect(spec.learningGoalAr.trim(), isNotEmpty, reason: 'unit ${unit.order}');
      expect(spec.objectivesAr.length, greaterThanOrEqualTo(2), reason: 'unit ${unit.order}');
      expect(spec.skillsAr.length, greaterThanOrEqualTo(2), reason: 'unit ${unit.order}');
      expect(spec.activityPlanAr.length, inInclusiveRange(4, 6), reason: 'unit ${unit.order}');
      expect(spec.activityKinds, isNotEmpty, reason: 'unit ${unit.order}');
      expect(
        spec.activityKinds.length,
        greaterThanOrEqualTo(3),
        reason: 'unit ${unit.order}',
      );
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


  test('every declared activity kind exists in the executable source for all 52 units', () {
    for (final unit in UnitsData.units) {
      final source = unit.sourceActivities;
      final kinds = CurriculumSpecs.activityKindsForUnit(unit);
      for (final kind in kinds) {
        final exists = source.any((activity) {
          switch (kind) {
            case CurriculumActivityKind.lesson:
              return activity is LessonActivityConfig;
            case CurriculumActivityKind.trace:
              return activity is TraceActivityConfig;
            case CurriculumActivityKind.dragCount:
              return activity is DragCountActivityConfig;
            case CurriculumActivityKind.matching:
              return activity is MatchingActivityConfig;
            case CurriculumActivityKind.comparison:
              return activity is ComparisonActivityConfig;
            case CurriculumActivityKind.sceneExplore:
              return activity is SceneExploreActivityConfig;
            case CurriculumActivityKind.quiz:
              return activity is MultipleChoiceActivityConfig;
            case CurriculumActivityKind.review:
              return activity is ReviewActivityConfig;
            case CurriculumActivityKind.arithmetic:
              return activity is ArithmeticActivityConfig;
            case CurriculumActivityKind.wordProblem:
              return activity is WordProblemActivityConfig;
          }
        });
        expect(
          exists,
          isTrue,
          reason: 'unit ${unit.order} must implement $kind',
        );
      }
    }
  });

  test('curriculum activity planner executes a non-empty ordered plan for all 52 units', () {
    for (final unit in UnitsData.units) {
      final spec = CurriculumSpecs.forUnit(unit);
      final planned = CurriculumActivityPlanner.plan(unit);
      expect(planned, isNotEmpty, reason: 'unit ${unit.order}');
      expect(
        CurriculumSpecs.activityKindsForUnit(unit),
        orderedEquals(spec.activityKinds),
        reason: 'structured plan must be the source of the executable activity plan for unit ${unit.order}',
      );
      expect(
        planned.length,
        lessThanOrEqualTo(unit.sourceActivityCount),
        reason: 'unit ${unit.order}',
      );

      final assessments = planned.whereType<AssessmentActivityConfig>().toList();
      if (assessments.isNotEmpty) {
        expect(
          planned.last,
          isA<AssessmentActivityConfig>(),
          reason: 'assessment must remain the final gate for unit ${unit.order}',
        );
      }
    }
  });
}

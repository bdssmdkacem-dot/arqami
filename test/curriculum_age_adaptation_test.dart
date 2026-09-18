import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/profile/age_activity_adapter.dart';
import 'package:arqami/core/profile/learner_profile.dart';
import 'package:arqami/models/unit_model.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  ChoiceQuestion q(String text) => ChoiceQuestion(
        questionAr: text,
        options: const ['أ', 'ب', 'ج'],
        correctIndex: 0,
      );

  test('curriculum domains cover the complete 52-unit progression', () {
    expect(curriculumDomainForUnit(1), CurriculumDomain.foundation);
    expect(curriculumDomainForUnit(13), CurriculumDomain.foundation);
    expect(curriculumDomainForUnit(14), CurriculumDomain.placeValue);
    expect(curriculumDomainForUnit(34), CurriculumDomain.placeValue);
    expect(curriculumDomainForUnit(35), CurriculumDomain.additionSubtraction);
    expect(curriculumDomainForUnit(40), CurriculumDomain.additionSubtraction);
    expect(curriculumDomainForUnit(41), CurriculumDomain.multiplicationDivision);
    expect(curriculumDomainForUnit(46), CurriculumDomain.multiplicationDivision);
    expect(curriculumDomainForUnit(47), CurriculumDomain.fractionsDecimals);
    expect(curriculumDomainForUnit(50), CurriculumDomain.fractionsDecimals);
    expect(curriculumDomainForUnit(51), CurriculumDomain.ratioProportion);
    expect(curriculumDomainForUnit(52), CurriculumDomain.algebra);
  });

  test('curriculum difficulty rises with the mathematical progression', () {
    final levels = [
      curriculumDifficultyForUnit(1),
      curriculumDifficultyForUnit(14),
      curriculumDifficultyForUnit(21),
      curriculumDifficultyForUnit(35),
      curriculumDifficultyForUnit(41),
      curriculumDifficultyForUnit(47),
      curriculumDifficultyForUnit(51),
    ];
    for (var i = 1; i < levels.length; i++) {
      expect(levels[i], greaterThan(levels[i - 1]));
    }
  });

  test('early learners get concrete-first activities for place value', () {
    final source = <ActivityConfig>[
      MultipleChoiceActivityConfig([q('24 = ؟')]),
      const ComparisonActivityConfig(leftCount: 2, rightCount: 4),
      const LessonActivityConfig(titleAr: 'العشرات', explanationAr: 'شرح'),
      const MatchingActivityConfig([]),
      const AssessmentActivityConfig(titleAr: 'تقييم', questions: []),
    ];

    final result = AgeActivityPlan.forBand(AgeBand.early).adaptActivities(
      source,
      domain: CurriculumDomain.placeValue,
    );

    expect(result[0], isA<LessonActivityConfig>());
    expect(result[1], isA<MatchingActivityConfig>());
    expect(result[2], isA<ComparisonActivityConfig>());
    expect(result.last, isA<AssessmentActivityConfig>());
  });

  test('middle learners put the mathematical operation before quiz', () {
    final source = <ActivityConfig>[
      MultipleChoiceActivityConfig([q('12 + 8 = ؟')]),
      ArithmeticActivityConfig(
        operation: '+',
        questions: const [
          ArithmeticQuestion(questionAr: '12 + 8 = ؟', correctAnswer: 20),
        ],
      ),
      const LessonActivityConfig(titleAr: 'الجمع', explanationAr: 'شرح'),
      const AssessmentActivityConfig(titleAr: 'تقييم', questions: []),
    ];

    final result = AgeActivityPlan.forBand(AgeBand.middle).adaptActivities(
      source,
      domain: CurriculumDomain.additionSubtraction,
    );
    final types = result.map((activity) => activity.runtimeType).toList();

    expect(types.indexOf(ArithmeticActivityConfig), lessThan(types.indexOf(MultipleChoiceActivityConfig)));
    expect(result.last, isA<AssessmentActivityConfig>());
  });

  test('training questions are selected by mathematical difficulty, not only position', () {
    final source = MultipleChoiceActivityConfig([
      q('ما العدد 1000؟'),
      q('ما العدد 5؟'),
      q('ما العدد 100؟'),
      q('ما العدد 10؟'),
    ]);

    final early = AgeActivityPlan.forBand(AgeBand.early)
        .adaptActivities([source])
        .single as MultipleChoiceActivityConfig;
    final primary = AgeActivityPlan.forBand(AgeBand.primary)
        .adaptActivities([source])
        .single as MultipleChoiceActivityConfig;

    expect(early.questions.map((item) => item.questionAr), ['ما العدد 5؟', 'ما العدد 10؟']);
    expect(primary.questions.map((item) => item.questionAr), ['ما العدد 5؟', 'ما العدد 10؟', 'ما العدد 100؟']);
  });

  test('real curriculum units expose domain-aware adapted activities', () {
    final placeValue = UnitsData.units[13];
    final placeTypes = AgeActivityPlan.forBand(AgeBand.early)
        .adaptUnit(placeValue)
        .map((activity) => activity.runtimeType)
        .toList();
    expect(placeTypes.first, LessonActivityConfig);

    final arithmetic = UnitsData.units[34];
    final arithmeticTypes = AgeActivityPlan.forBand(AgeBand.middle)
        .adaptUnit(arithmetic)
        .map((activity) => activity.runtimeType)
        .toList();
    expect(arithmeticTypes.first, LessonActivityConfig);
    expect(arithmeticTypes.last, AssessmentActivityConfig);
  });
}

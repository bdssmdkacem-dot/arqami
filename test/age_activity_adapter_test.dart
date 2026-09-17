import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/profile/age_activity_adapter.dart';
import 'package:arqami/core/profile/learner_profile.dart';
import 'package:arqami/models/unit_model.dart';

void main() {
  ChoiceQuestion q(String text, int correct) => ChoiceQuestion(
        questionAr: text,
        options: const ['أ', 'ب', 'ج'],
        correctIndex: correct,
      );

  ArithmeticQuestion a(String text, num answer) => ArithmeticQuestion(
        questionAr: text,
        correctAnswer: answer,
      );

  final mixed = <ActivityConfig>[
    const LessonActivityConfig(
      titleAr: 'درس',
      explanationAr: 'شرح',
    ),
    MultipleChoiceActivityConfig([q('1', 0), q('2', 1), q('3', 2), q('4', 0)]),
    ArithmeticActivityConfig(
      operation: '+',
      questions: [a('1+1', 2), a('2+2', 4), a('3+3', 6), a('4+4', 8)],
    ),
    WordProblemActivityConfig([
      a('مسألة 1', 2),
      a('مسألة 2', 4),
      a('مسألة 3', 6),
    ]),
    const TraceActivityConfig(3),
    AssessmentActivityConfig(titleAr: 'تقييم', questions: [q('تقييم', 0)]),
  ];

  test('early learners prioritize concrete activities and keep assessment last', () {
    final plan = AgeActivityPlan.forBand(AgeBand.early);
    final result = plan.adaptActivities(
      mixed,
      domain: CurriculumDomain.foundation,
    );
    final types = result.map((activity) => activity.runtimeType).toList();

    expect(result[0], isA<LessonActivityConfig>());
    expect(result[1], isA<TraceActivityConfig>());
    expect(
      types.indexOf(TraceActivityConfig),
      lessThan(types.indexOf(MultipleChoiceActivityConfig)),
    );
    expect(result.last, isA<AssessmentActivityConfig>());
    expect(
      (result.whereType<MultipleChoiceActivityConfig>().single).questions.length,
      2,
    );
    expect(
      (result.whereType<ArithmeticActivityConfig>().single).questions.length,
      2,
    );
  });

  test('primary learners retain a wider practice set', () {
    final plan = AgeActivityPlan.forBand(AgeBand.primary);
    final result = plan.adaptActivities(mixed);
    final quiz = result.whereType<MultipleChoiceActivityConfig>().single;
    final arithmetic = result.whereType<ArithmeticActivityConfig>().single;

    expect(quiz.questions.length, 3);
    expect(arithmetic.questions.length, 3);
    expect(result.last, isA<AssessmentActivityConfig>());
  });

  test('middle and teen learners prioritize problem solving and keep all practice', () {
    for (final band in [AgeBand.middle, AgeBand.teen]) {
      final result = AgeActivityPlan.forBand(band).adaptActivities(mixed);
      final types = result.map((activity) => activity.runtimeType).toList();

      expect(
        types.indexOf(ArithmeticActivityConfig),
        lessThan(types.indexOf(MultipleChoiceActivityConfig)),
      );
      expect(
        types.indexOf(WordProblemActivityConfig),
        lessThan(types.indexOf(MultipleChoiceActivityConfig)),
      );
      expect(
        (result.whereType<MultipleChoiceActivityConfig>().single)
            .questions
            .length,
        4,
      );
      expect(
        (result.whereType<ArithmeticActivityConfig>().single).questions.length,
        4,
      );
      expect(result.last, isA<AssessmentActivityConfig>());
    }
  });

  test('unit model exposes adapted activities without changing source activity count', () {
    const unit = UnitModel(
      id: 'test',
      order: 1,
      titleAr: 'اختبار',
      activities: [
        LessonActivityConfig(titleAr: 'درس', explanationAr: 'شرح'),
        TraceActivityConfig(1),
        AssessmentActivityConfig(titleAr: 'تقييم', questions: []),
      ],
    );

    expect(unit.sourceActivityCount, 3);
    expect(unit.isImplemented, isTrue);
    expect(unit.activities.length, 3);
  });
}

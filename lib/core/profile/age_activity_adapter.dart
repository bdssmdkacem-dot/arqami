import 'learner_profile.dart';
import '../../models/unit_model.dart';

/// يحول نفس محتوى المنهج إلى تجربة مختلفة بحسب العمر.
/// لا يضيف وحدات جديدة ولا يحذف محتوى التقييم النهائي؛ التكييف هنا في
/// ترتيب نوع النشاط، حجم التدريب، ومستوى التوجيه.
class AgeActivityPlan {
  final AgeBand band;
  final int practiceQuestionLimit;
  final int arithmeticQuestionLimit;
  final bool showHints;
  final bool prioritizeConcreteActivities;
  final bool prioritizeProblemSolving;

  const AgeActivityPlan({
    required this.band,
    required this.practiceQuestionLimit,
    required this.arithmeticQuestionLimit,
    required this.showHints,
    required this.prioritizeConcreteActivities,
    required this.prioritizeProblemSolving,
  });

  factory AgeActivityPlan.forBand(AgeBand band) {
    switch (band) {
      case AgeBand.early:
        return const AgeActivityPlan(
          band: AgeBand.early,
          practiceQuestionLimit: 2,
          arithmeticQuestionLimit: 2,
          showHints: true,
          prioritizeConcreteActivities: true,
          prioritizeProblemSolving: false,
        );
      case AgeBand.primary:
        return const AgeActivityPlan(
          band: AgeBand.primary,
          practiceQuestionLimit: 3,
          arithmeticQuestionLimit: 3,
          showHints: true,
          prioritizeConcreteActivities: true,
          prioritizeProblemSolving: false,
        );
      case AgeBand.middle:
        return const AgeActivityPlan(
          band: AgeBand.middle,
          practiceQuestionLimit: 999,
          arithmeticQuestionLimit: 999,
          showHints: false,
          prioritizeConcreteActivities: false,
          prioritizeProblemSolving: true,
        );
      case AgeBand.teen:
        return const AgeActivityPlan(
          band: AgeBand.teen,
          practiceQuestionLimit: 999,
          arithmeticQuestionLimit: 999,
          showHints: false,
          prioritizeConcreteActivities: false,
          prioritizeProblemSolving: true,
        );
    }
  }

  factory AgeActivityPlan.current() => AgeActivityPlan.forBand(
        AgeBand.fromAge(LearnerProfile.age ?? 6),
      );

  /// يعيد ترتيب الأنشطة فقط عندما توجد أنشطة متعددة من أنواع مختلفة.
  /// المحتوى نفسه يبقى كما هو، والتقييم النهائي يبقى في النهاية.
  List<ActivityConfig> orderActivities(List<ActivityConfig> activities) {
    final indexed = activities.asMap().entries.toList();
    indexed.sort((a, b) {
      final pa = _priority(a.value);
      final pb = _priority(b.value);
      if (pa != pb) return pa.compareTo(pb);
      return a.key.compareTo(b.key);
    });
    return indexed.map((entry) => entry.value).toList(growable: false);
  }

  int _priority(ActivityConfig activity) {
    if (activity is AssessmentActivityConfig) return 100;

    if (prioritizeConcreteActivities) {
      if (activity is LessonActivityConfig) return 0;
      if (activity is TraceActivityConfig) return 1;
      if (activity is DragCountActivityConfig) return 2;
      if (activity is MatchingActivityConfig) return 3;
      if (activity is ComparisonActivityConfig) return 4;
      if (activity is SceneExploreActivityConfig) return 5;
      if (activity is MultipleChoiceActivityConfig) return 6;
      if (activity is ReviewActivityConfig) return 7;
      if (activity is ArithmeticActivityConfig) return 8;
      if (activity is WordProblemActivityConfig) return 9;
    }

    if (prioritizeProblemSolving) {
      if (activity is LessonActivityConfig) return 0;
      if (activity is ArithmeticActivityConfig) return 1;
      if (activity is WordProblemActivityConfig) return 2;
      if (activity is ComparisonActivityConfig) return 3;
      if (activity is MultipleChoiceActivityConfig) return 4;
      if (activity is ReviewActivityConfig) return 5;
      if (activity is TraceActivityConfig) return 6;
      if (activity is MatchingActivityConfig) return 7;
      if (activity is DragCountActivityConfig) return 8;
      if (activity is SceneExploreActivityConfig) return 9;
    }

    return 50;
  }

  List<ChoiceQuestion> practiceChoices(List<ChoiceQuestion> questions) {
    if (questions.length <= practiceQuestionLimit) return questions;
    return questions.take(practiceQuestionLimit).toList(growable: false);
  }

  List<ArithmeticQuestion> practiceArithmetic(List<ArithmeticQuestion> questions) {
    if (questions.length <= arithmeticQuestionLimit) return questions;
    return questions.take(arithmeticQuestionLimit).toList(growable: false);
  }
}

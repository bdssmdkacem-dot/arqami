import 'learner_profile.dart';
import '../../models/unit_model.dart';

enum CurriculumDomain {
  foundation,
  placeValue,
  additionSubtraction,
  multiplicationDivision,
  fractionsDecimals,
  ratioProportion,
  algebra,
}

CurriculumDomain curriculumDomainForUnit(int order) {
  if (order <= 13) return CurriculumDomain.foundation;
  if (order <= 34) return CurriculumDomain.placeValue;
  if (order <= 40) return CurriculumDomain.additionSubtraction;
  if (order <= 46) return CurriculumDomain.multiplicationDivision;
  if (order <= 50) return CurriculumDomain.fractionsDecimals;
  if (order == 51) return CurriculumDomain.ratioProportion;
  return CurriculumDomain.algebra;
}

int curriculumDifficultyForUnit(int order) {
  if (order <= 13) return 1;
  if (order <= 20) return 2;
  if (order <= 34) return 3;
  if (order <= 40) return 4;
  if (order <= 46) return 5;
  if (order <= 50) return 6;
  if (order == 51) return 7;
  return 8;
}

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

  factory AgeActivityPlan.forAge(int age) => AgeActivityPlan.forBand(AgeBand.fromAge(age));

  factory AgeActivityPlan.current() => AgeActivityPlan.forAge(LearnerProfile.age ?? 6);

  List<ActivityConfig> orderActivities(List<ActivityConfig> activities, {CurriculumDomain? domain}) {
    final indexed = activities.asMap().entries.toList();
    indexed.sort((a, b) {
      final pa = _priority(a.value, domain: domain);
      final pb = _priority(b.value, domain: domain);
      if (pa != pb) return pa.compareTo(pb);
      return a.key.compareTo(b.key);
    });
    return indexed.map((entry) => entry.value).toList(growable: false);
  }

  List<ActivityConfig> adaptUnit(UnitModel unit) => adaptActivities(
        unit.sourceActivities,
        domain: curriculumDomainForUnit(unit.order),
      );

  List<ActivityConfig> adaptActivities(
    List<ActivityConfig> source, {
    CurriculumDomain? domain,
  }) {
    final ordered = orderActivities(source, domain: domain);
    return ordered.map((activity) {
      if (activity is AssessmentActivityConfig) return activity;
      if (activity is MultipleChoiceActivityConfig) {
        return MultipleChoiceActivityConfig(practiceChoices(activity.questions));
      }
      if (activity is ReviewActivityConfig) {
        return ReviewActivityConfig(
          titleAr: activity.titleAr,
          questions: practiceChoices(activity.questions),
        );
      }
      if (activity is ArithmeticActivityConfig) {
        return ArithmeticActivityConfig(
          operation: activity.operation,
          questions: practiceArithmetic(activity.questions),
        );
      }
      if (activity is WordProblemActivityConfig) {
        return WordProblemActivityConfig(practiceArithmetic(activity.questions));
      }
      return activity;
    }).toList(growable: false);
  }

  int _priority(ActivityConfig activity, {CurriculumDomain? domain}) {
    if (activity is AssessmentActivityConfig) return 100;

    if (band == AgeBand.early && domain != null) {
      switch (domain) {
        case CurriculumDomain.foundation:
          if (activity is LessonActivityConfig) return 0;
          if (activity is TraceActivityConfig) return 1;
          if (activity is DragCountActivityConfig) return 2;
          if (activity is MatchingActivityConfig) return 3;
          if (activity is ComparisonActivityConfig) return 4;
          break;
        case CurriculumDomain.placeValue:
          if (activity is LessonActivityConfig) return 0;
          if (activity is MatchingActivityConfig) return 1;
          if (activity is ComparisonActivityConfig) return 2;
          if (activity is DragCountActivityConfig) return 3;
          break;
        default:
          if (activity is LessonActivityConfig) return 0;
          if (activity is ComparisonActivityConfig) return 1;
          if (activity is MatchingActivityConfig) return 2;
          break;
      }
    }

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
    return _selectByDifficulty<ChoiceQuestion>(questions, practiceQuestionLimit);
  }

  List<ArithmeticQuestion> practiceArithmetic(List<ArithmeticQuestion> questions) {
    if (questions.length <= arithmeticQuestionLimit) return questions;
    return _selectByDifficulty<ArithmeticQuestion>(questions, arithmeticQuestionLimit);
  }

  List<T> _selectByDifficulty<T extends Object>(List<T> questions, int limit) {
    final indexed = questions.asMap().entries.toList();
    indexed.sort((a, b) {
      final da = _questionDifficulty(a.value);
      final db = _questionDifficulty(b.value);
      if (da != db) return da.compareTo(db);
      return a.key.compareTo(b.key);
    });
    return indexed.take(limit).map((entry) => entry.value).toList(growable: false);
  }

  int _questionDifficulty(Object question) {
    final text = question is ChoiceQuestion
        ? question.questionAr
        : (question as ArithmeticQuestion).questionAr;
    final normalized = _normalizeDigits(text);
    final numbers = RegExp(r'\d+(?:\.\d+)?')
        .allMatches(normalized)
        .map((match) => double.tryParse(match.group(0)!) ?? 0)
        .toList();
    final maxNumber = numbers.isEmpty ? 0 : numbers.reduce((a, b) => a > b ? a : b);
    var score = maxNumber >= 1000
        ? 6
        : maxNumber >= 100
            ? 5
            : maxNumber >= 20
                ? 4
                : maxNumber >= 10
                    ? 3
                    : maxNumber >= 5
                        ? 2
                        : 1;
    if (text.contains('×') || text.contains('ضرب')) score += 1;
    if (text.contains('÷') || text.contains('قسمة')) score += 1;
    if (text.contains('٪') || text.contains('%') || text.contains('نسبة')) score += 1;
    if (text.contains('كسر') || text.contains('عشري') || text.contains('متباين') || text.contains('معادلة')) score += 1;
    if (text.contains('؟') && text.length > 24) score += 1;
    return score;
  }

  String _normalizeDigits(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const eastern = '۰۱۲۳۴۵۶۷۸۹';
    var result = value;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(arabic[i], '$i');
      result = result.replaceAll(eastern[i], '$i');
    }
    return result;
  }
}

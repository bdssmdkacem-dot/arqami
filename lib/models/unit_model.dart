import '../core/profile/age_activity_adapter.dart';
import '../widgets/games/scene_explore_widget.dart' show SceneType;

/// وصف عام لنشاط داخل وحدة. كل وحدة تتكون من قائمة أنشطة مرتبة،
/// والطفل يكملها بالترتيب قبل اعتبار الوحدة منتهية.
abstract class ActivityConfig {
  const ActivityConfig();
}

/// نشاط تتبّع رقم واحد (يستهلك TraceWidget).
class TraceActivityConfig extends ActivityConfig {
  final int digit; // 0-9
  const TraceActivityConfig(this.digit);
}

enum MatchContentType { number, quantity }

class MatchPairSpec {
  final String id;
  final MatchContentType leftType;
  final int leftValue;
  final MatchContentType rightType;
  final int rightValue;

  const MatchPairSpec({
    required this.id,
    required this.leftType,
    required this.leftValue,
    required this.rightType,
    required this.rightValue,
  });
}

class MatchingActivityConfig extends ActivityConfig {
  final List<MatchPairSpec> pairs;
  const MatchingActivityConfig(this.pairs);
}

class DragCountActivityConfig extends ActivityConfig {
  final int targetCount;
  const DragCountActivityConfig(this.targetCount);
}

enum ComparisonQuestionType { more, fewer, equal }

class ComparisonActivityConfig extends ActivityConfig {
  final int leftCount;
  final int rightCount;
  final ComparisonQuestionType question;

  const ComparisonActivityConfig({
    required this.leftCount,
    required this.rightCount,
    this.question = ComparisonQuestionType.more,
  });
}

class SceneExploreActivityConfig extends ActivityConfig {
  final SceneType sceneType;
  final int targetDigit;

  const SceneExploreActivityConfig({
    required this.sceneType,
    required this.targetDigit,
  });
}

class LessonActivityConfig extends ActivityConfig {
  final String titleAr;
  final String explanationAr;
  final List<String> examplesAr;

  const LessonActivityConfig({
    required this.titleAr,
    required this.explanationAr,
    this.examplesAr = const [],
  });
}

class ChoiceQuestion {
  final String questionAr;
  final List<String> options;
  final int correctIndex;
  final String? hintAr;

  const ChoiceQuestion({
    required this.questionAr,
    required this.options,
    required this.correctIndex,
    this.hintAr,
  });
}

class MultipleChoiceActivityConfig extends ActivityConfig {
  final List<ChoiceQuestion> questions;

  const MultipleChoiceActivityConfig(this.questions);
}

/// تمرين حسابي مباشر.
/// correctAnswer يدعم الأعداد الصحيحة والعشرية، بينما correctAnswerText
/// يسمح بإجابات تعليمية مركبة مثل: "4 والباقي 2".
class ArithmeticQuestion {
  final String questionAr;
  final num? correctAnswer;
  final String? correctAnswerText;
  final String? hintAr;

  const ArithmeticQuestion({
    required this.questionAr,
    this.correctAnswer,
    this.correctAnswerText,
    this.hintAr,
  }) : assert(correctAnswer != null || correctAnswerText != null);
}

class ArithmeticActivityConfig extends ActivityConfig {
  final String operation;
  final List<ArithmeticQuestion> questions;

  const ArithmeticActivityConfig({
    required this.operation,
    required this.questions,
  });
}

class WordProblemActivityConfig extends ActivityConfig {
  final List<ArithmeticQuestion> questions;

  const WordProblemActivityConfig(this.questions);
}

class ReviewActivityConfig extends ActivityConfig {
  final String titleAr;
  final List<ChoiceQuestion> questions;

  const ReviewActivityConfig({
    required this.titleAr,
    required this.questions,
  });
}

class AssessmentActivityConfig extends ActivityConfig {
  final String titleAr;
  final List<ChoiceQuestion> questions;

  const AssessmentActivityConfig({
    required this.titleAr,
    required this.questions,
  });
}

class UnitModel {
  final String id;
  final int order;
  final String titleAr;
  final String? descriptionAr;
  final String ageRangeAr;
  final List<ActivityConfig> _activities;

  const UnitModel({
    required this.id,
    required this.order,
    required this.titleAr,
    required List<ActivityConfig> activities,
    this.descriptionAr,
    this.ageRangeAr = '3–16 سنة',
  }) : _activities = activities;

  /// الأنشطة التي يراها المتعلم بعد تكييفها للعمر ومفهوم الوحدة.
  /// المصدر الأصلي يبقى محفوظاً داخل الوحدة، لذلك لا يتغير المنهج نفسه.
  List<ActivityConfig> get activities => AgeActivityPlan.current().adaptUnit(this);

  /// الأنشطة الأصلية قبل أي تكييف عمري. تستخدمها اختبارات سلامة المنهج.
  List<ActivityConfig> get sourceActivities => List.unmodifiable(_activities);

  /// العدد الأصلي لأنشطة الوحدة، مفيد للتحقق من سلامة المنهج والاختبارات.
  int get sourceActivityCount => _activities.length;

  bool get isImplemented => _activities.isNotEmpty;
}

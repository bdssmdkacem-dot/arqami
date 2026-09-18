import 'learner_profile.dart';

/// قيم عرض وتفاعل الأنشطة بحسب عمر المتعلم.
/// لا تغيّر المنهج نفسه؛ تجعل طريقة الإجابة مناسبة لقدرة الطفل.
class AgeActivityPresentation {
  final AgeBand band;
  final double traceAccuracyThreshold;
  final double traceToleranceRadius;
  final double choiceTextSize;
  final double questionTextSize;
  final double choiceHeight;
  final bool showExtraGuidance;
  final bool useShortFeedback;

  const AgeActivityPresentation({
    required this.band,
    required this.traceAccuracyThreshold,
    required this.traceToleranceRadius,
    required this.choiceTextSize,
    required this.questionTextSize,
    required this.choiceHeight,
    required this.showExtraGuidance,
    required this.useShortFeedback,
  });

  factory AgeActivityPresentation.forBand(AgeBand band) {
    switch (band) {
      case AgeBand.early:
        return const AgeActivityPresentation(
          band: AgeBand.early,
          traceAccuracyThreshold: 0.52,
          traceToleranceRadius: 0.09,
          choiceTextSize: 23,
          questionTextSize: 25,
          choiceHeight: 68,
          showExtraGuidance: true,
          useShortFeedback: false,
        );
      case AgeBand.primary:
        return const AgeActivityPresentation(
          band: AgeBand.primary,
          traceAccuracyThreshold: 0.60,
          traceToleranceRadius: 0.08,
          choiceTextSize: 21,
          questionTextSize: 23,
          choiceHeight: 62,
          showExtraGuidance: true,
          useShortFeedback: false,
        );
      case AgeBand.middle:
        return const AgeActivityPresentation(
          band: AgeBand.middle,
          traceAccuracyThreshold: 0.66,
          traceToleranceRadius: 0.07,
          choiceTextSize: 19,
          questionTextSize: 22,
          choiceHeight: 56,
          showExtraGuidance: false,
          useShortFeedback: true,
        );
      case AgeBand.teen:
        return const AgeActivityPresentation(
          band: AgeBand.teen,
          traceAccuracyThreshold: 0.70,
          traceToleranceRadius: 0.065,
          choiceTextSize: 18,
          questionTextSize: 21,
          choiceHeight: 52,
          showExtraGuidance: false,
          useShortFeedback: true,
        );
    }
  }

  factory AgeActivityPresentation.forAge(int age) {
    return AgeActivityPresentation.forBand(AgeBand.fromAge(age));
  }

  factory AgeActivityPresentation.current() => forAge(LearnerProfile.age ?? 6);
}

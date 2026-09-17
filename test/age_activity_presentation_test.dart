import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/profile/age_activity_presentation.dart';
import 'package:arqami/core/profile/learner_profile.dart';

void main() {
  test('early learners get the most forgiving tracing and largest choices', () {
    final p = AgeActivityPresentation.forBand(AgeBand.early);
    expect(p.traceAccuracyThreshold, lessThan(0.60));
    expect(p.traceToleranceRadius, greaterThan(0.08));
    expect(p.choiceHeight, greaterThan(60));
    expect(p.showExtraGuidance, isTrue);
  });

  test('teen learners get compact presentation and stricter tracing', () {
    final p = AgeActivityPresentation.forBand(AgeBand.teen);
    expect(p.traceAccuracyThreshold, greaterThan(0.65));
    expect(p.choiceHeight, lessThan(56));
    expect(p.showExtraGuidance, isFalse);
    expect(p.useShortFeedback, isTrue);
  });
}

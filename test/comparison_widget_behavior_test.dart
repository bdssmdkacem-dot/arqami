import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/widgets/games/comparison_widget.dart';

void main() {
  testWidgets('equal comparison completes when either group is tapped', (tester) async {
    var completed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComparisonWidget(
            leftCount: 5,
            rightCount: 5,
            question: ComparisonQuestion.equal,
            onComplete: () => completed++,
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('مجموعة فيها 5 عناصر، اختر للتأكيد على التساوي').first);
    await tester.pump();

    expect(completed, 1);
  });

  testWidgets('equal comparison rejects unequal groups', (tester) async {
    var completed = 0;
    var wrong = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComparisonWidget(
            leftCount: 5,
            rightCount: 4,
            question: ComparisonQuestion.equal,
            onComplete: () => completed++,
            onWrongAttempt: () => wrong++,
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('مجموعة فيها 5 عناصر، اختر للتأكيد على التساوي').first);
    await tester.pump();

    expect(completed, 0);
    expect(wrong, 1);

    // The widget clears the wrong-answer highlight after 400ms.
    // Advance the fake clock so the test does not finish with a pending timer.
    await tester.pump(const Duration(milliseconds: 400));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/widgets/games/comparison_widget.dart';

void main() {
  testWidgets('equal quantities complete the comparison from either side', (tester) async {
    var completed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComparisonWidget(
            leftCount: 4,
            rightCount: 4,
            question: ComparisonQuestion.more,
            onComplete: () => completed++,
          ),
        ),
      ),
    );

    expect(find.text('هل الكومتان متساويتان؟'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('مجموعة فيها 4 عناصر')).first);
    await tester.pump();

    expect(completed, 1);
  });
}

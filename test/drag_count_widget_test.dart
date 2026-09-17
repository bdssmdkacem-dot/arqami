import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/widgets/games/drag_count_widget.dart';

void main() {
  testWidgets('zero-count activity opens the answer choices immediately', (tester) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DragCountWidget(
            targetCount: 0,
            onComplete: () => completed = true,
          ),
        ),
      ),
    );

    expect(find.text('كم عنصراً؟ لا توجد عناصر.'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.widgetWithText(GestureDetector, '0'));
    await tester.pump();

    expect(completed, isTrue);
  });

  testWidgets('non-zero activity does not expose the answer before all items are dropped', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DragCountWidget(
            targetCount: 2,
            onComplete: () {},
          ),
        ),
      ),
    );

    expect(find.text('كم عنصر جمعت؟'), findsNothing);
    expect(find.byType(Draggable<int>), findsNWidgets(2));
  });
}

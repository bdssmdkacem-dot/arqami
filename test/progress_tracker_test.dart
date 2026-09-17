import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/progress/progress_tracker.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  final tracker = ProgressTracker.instance;

  setUpAll(() async {
    await tracker.init();
    await tracker.resetAll();
  });

  tearDown(() async {
    await tracker.resetAll();
  });

  test('first unit is unlocked and next unit starts at unit 1', () {
    expect(tracker.isUnitUnlocked(UnitsData.units.first.id), isTrue);
    expect(tracker.isUnitUnlocked(UnitsData.units[1].id), isFalse);
    expect(tracker.getNextUnit()?.id, 'unit_01');
  });

  test('completing a unit unlocks only the following unit', () async {
    await tracker.markUnitComplete('unit_01', stars: 2);

    expect(tracker.getUnitProgress('unit_01').completed, isTrue);
    expect(tracker.getUnitProgress('unit_01').stars, 2);
    expect(tracker.isUnitUnlocked('unit_02'), isTrue);
    expect(tracker.isUnitUnlocked('unit_03'), isFalse);
    expect(tracker.getNextUnit()?.id, 'unit_02');
  });

  test('best stars are preserved and never downgraded', () async {
    await tracker.markUnitComplete('unit_01', stars: 3);
    await tracker.markUnitComplete('unit_01', stars: 1);

    expect(tracker.getUnitProgress('unit_01').completed, isTrue);
    expect(tracker.getUnitProgress('unit_01').stars, 3);
  });

  test('failed assessment attempt can be recorded without completing unit', () async {
    await tracker.recordAttempt('unit_01');

    final progress = tracker.getUnitProgress('unit_01');
    expect(progress.completed, isFalse);
    expect(progress.stars, 0);
    expect(progress.attemptsCount, 1);
    expect(tracker.isUnitUnlocked('unit_02'), isFalse);
  });

  test('overall progress counts completed units across all 52 units', () async {
    await tracker.markUnitComplete('unit_01', stars: 3);
    await tracker.markUnitComplete('unit_02', stars: 2);
    await tracker.markUnitComplete('unit_03', stars: 1);

    expect(tracker.getCompletedUnitIds().length, 3);
    expect(tracker.getOverallProgress(UnitsData.units.length), closeTo(3 / 52, 0.000001));
  });

  test('getNextUnit returns null only after all 52 units are completed', () async {
    for (final unit in UnitsData.units) {
      await tracker.markUnitComplete(unit.id, stars: 1);
    }

    expect(tracker.getCompletedUnitIds().length, 52);
    expect(tracker.getNextUnit(), isNull);
    expect(tracker.getOverallProgress(52), 1.0);
  });
}

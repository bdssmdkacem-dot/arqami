import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/progress/progress_tracker.dart';
import 'package:arqami/models/stage_reward.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  final tracker = ProgressTracker.instance;
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('arqami_progress_test_');
    await tracker.init(hivePath: hiveDirectory.path);
    await tracker.resetAll();
  });

  tearDown(() async {
    await tracker.resetAll();
  });

  tearDownAll(() async {
    await tracker.resetAll();
    if (await hiveDirectory.exists()) {
      await hiveDirectory.delete(recursive: true);
    }
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

  test('skipping a unit is rejected by the progress layer', () async {
    expect(
      () => tracker.markUnitComplete('unit_02', stars: 3),
      throwsA(isA<StateError>()),
    );
    expect(tracker.getUnitProgress('unit_02').completed, isFalse);
    expect(tracker.getNextUnit()?.id, 'unit_01');
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
    expect(
      tracker.getOverallProgress(UnitsData.units.length),
      closeTo(3 / 52, 0.000001),
    );
  });

  test('getNextUnit returns null only after all 52 units are completed', () async {
    for (final unit in UnitsData.units) {
      await tracker.markUnitComplete(unit.id, stars: 1);
    }

    expect(tracker.getCompletedUnitIds().length, 52);
    expect(tracker.getNextUnit(), isNull);
    expect(tracker.getOverallProgress(52), 1.0);
  });

  test('stage reward stays locked until every stage unit is complete', () async {
    expect(tracker.getStageRewardStatus(1), StageRewardStatus.locked);
    for (var order = 1; order < 13; order++) {
      await tracker.markUnitComplete('unit_${order.toString().padLeft(2, '0')}', stars: 1);
    }
    expect(tracker.getStageRewardStatus(1), StageRewardStatus.locked);
    await tracker.markUnitComplete('unit_13', stars: 3);
    expect(tracker.getStageRewardStatus(1), StageRewardStatus.available);
  });

  test('stage reward can be claimed exactly once and unlocks its achievement', () async {
    for (final unit in UnitsData.units.take(13)) {
      await tracker.markUnitComplete(unit.id, stars: 3);
    }

    expect(await tracker.claimStageReward(1), isTrue);
    expect(tracker.getStageRewardStatus(1), StageRewardStatus.claimed);
    expect(tracker.isAchievementUnlocked('stage_master_01'), isTrue);
    expect(await tracker.claimStageReward(1), isFalse);
    expect(tracker.getClaimedStageRewards(), contains(1));
  });

  test('claimed stage reward remains persisted in Hive', () async {
    for (final unit in UnitsData.units.take(13)) {
      await tracker.markUnitComplete(unit.id, stars: 1);
    }
    await tracker.claimStageReward(1);

    // Re-read through the same persistent tracker/box after the write.
    expect(tracker.isStageRewardClaimed(1), isTrue);
    expect(tracker.isAchievementUnlocked(StageRewards.forStage(1).achievementId), isTrue);
  });

  test('achievement is not unlocked by merely completing a stage', () async {
    for (final unit in UnitsData.units.take(13)) {
      await tracker.markUnitComplete(unit.id, stars: 1);
    }

    expect(tracker.getStageRewardStatus(1), StageRewardStatus.available);
    expect(tracker.isAchievementUnlocked('stage_master_01'), isFalse);
  });
}

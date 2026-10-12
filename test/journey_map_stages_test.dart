import 'package:flutter_test/flutter_test.dart';
import 'package:arqami/models/stage_reward.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  test('all 52 curriculum units are represented by seven contiguous map stages', () {
    expect(StageRewards.all, hasLength(7));
    var expectedStart = 1;
    for (var i = 0; i < StageRewards.all.length; i++) {
      final stage = StageRewards.all[i];
      expect(stage.stage, i + 1);
      expect(stage.startOrder, expectedStart, reason: 'Stage ${stage.stage} must continue the previous stage');
      expect(stage.endOrder, greaterThanOrEqualTo(stage.startOrder));
      expect(stage.endOrder, lessThanOrEqualTo(UnitsData.totalUnits));
      expectedStart = stage.endOrder + 1;
    }
    expect(expectedStart, UnitsData.totalUnits + 1);
  });

  test('map stage boundaries match the seven educational worlds', () {
    expect(
      StageRewards.all.map((stage) => [stage.startOrder, stage.endOrder]).toList(),
      [
        [1, 13],
        [14, 20],
        [21, 30],
        [31, 38],
        [39, 44],
        [45, 46],
        [47, 52],
      ],
    );
    expect(StageRewards.all.map((stage) => stage.titleAr).toSet(), hasLength(7));
  });
}

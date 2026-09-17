/// Pure-Dart definition/state for collectible stage rewards.
enum StageRewardStatus { locked, available, claimed }

class StageRewardDefinition {
  final int stage;
  final int startOrder;
  final int endOrder;
  final String id;
  final String titleAr;
  final String achievementId;
  final int stars;

  const StageRewardDefinition({
    required this.stage,
    required this.startOrder,
    required this.endOrder,
    required this.id,
    required this.titleAr,
    required this.achievementId,
    this.stars = 3,
  });

  StageRewardStatus status({required bool stageComplete, required bool claimed}) {
    if (claimed) return StageRewardStatus.claimed;
    if (stageComplete) return StageRewardStatus.available;
    return StageRewardStatus.locked;
  }
}

class StageRewards {
  static const List<StageRewardDefinition> all = [
    StageRewardDefinition(stage: 1, startOrder: 1, endOrder: 13, id: 'stage_reward_01', titleAr: 'نجمة الأعداد', achievementId: 'stage_master_01'),
    StageRewardDefinition(stage: 2, startOrder: 14, endOrder: 20, id: 'stage_reward_02', titleAr: 'وسام العشرات', achievementId: 'stage_master_02'),
    StageRewardDefinition(stage: 3, startOrder: 21, endOrder: 30, id: 'stage_reward_03', titleAr: 'تاج المئات والآلاف', achievementId: 'stage_master_03'),
    StageRewardDefinition(stage: 4, startOrder: 31, endOrder: 38, id: 'stage_reward_04', titleAr: 'وسام الجمع والطرح', achievementId: 'stage_master_04'),
    StageRewardDefinition(stage: 5, startOrder: 39, endOrder: 44, id: 'stage_reward_05', titleAr: 'كأس الضرب', achievementId: 'stage_master_05'),
    StageRewardDefinition(stage: 6, startOrder: 45, endOrder: 46, id: 'stage_reward_06', titleAr: 'كأس القسمة', achievementId: 'stage_master_06'),
    StageRewardDefinition(stage: 7, startOrder: 47, endOrder: 52, id: 'stage_reward_07', titleAr: 'تاج أبطال الرياضيات', achievementId: 'stage_master_07'),
  ];

  static StageRewardDefinition forStage(int stage) => all.firstWhere(
        (reward) => reward.stage == stage,
        orElse: () => throw ArgumentError.value(stage, 'stage', 'المرحلة غير موجودة'),
      );
}

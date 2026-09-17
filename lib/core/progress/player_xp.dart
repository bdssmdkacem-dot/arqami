import 'progress_tracker.dart';

/// نظام XP محلي مشتق من التقدم المحفوظ.
/// لا يضيف حالة ثانية قد تتعارض مع Hive؛ يمكن إعادة حسابه دائمًا من التقدم.
class PlayerXp {
  PlayerXp._();

  static const int unitBaseXp = 100;
  static const int starBonusXp = 25;
  static const int stageRewardXp = 250;
  static const int achievementXp = 50;
  static const int xpPerLevel = 500;

  static int totalXp(ProgressTracker tracker) {
    final unitXp = tracker.getCompletedUnitIds().fold<int>(0, (sum, id) {
      final progress = tracker.getUnitProgress(id);
      return sum + unitBaseXp + (progress.stars * starBonusXp);
    });
    final rewardXp =
        tracker.getClaimedStageRewards().length * stageRewardXp;
    final achievementXpTotal =
        tracker.getUnlockedAchievementsCount() * achievementXp;
    return unitXp + rewardXp + achievementXpTotal;
  }

  static int levelFromXp(int xp) => (xp ~/ xpPerLevel) + 1;

  static double levelProgress(int xp) =>
      (xp % xpPerLevel) / xpPerLevel;

  static int xpIntoLevel(int xp) => xp % xpPerLevel;

  static int xpToNextLevel(int xp) => xpPerLevel - xpIntoLevel(xp);
}

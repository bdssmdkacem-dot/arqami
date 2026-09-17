import 'package:hive_flutter/hive_flutter.dart';

import '../../models/achievement.dart';
import '../../models/stage_reward.dart';
import '../../models/unit_model.dart';
import '../../models/units_data.dart';
import 'unit_progress.dart';

/// متتبع تقدم الطفل فوق Hive.
///
/// لا يعتمد هذا الكلاس على UI أو الصوت؛ فهو مسؤول فقط عن التقدم
/// والمكافآت والإنجازات وحفظها محلياً.
class ProgressTracker {
  ProgressTracker._internal();
  static final ProgressTracker instance = ProgressTracker._internal();

  static const String _boxName = 'arqami_progress';
  static const String _rewardsBoxName = 'arqami_stage_rewards';
  static const String _achievementPrefix = 'achievement:';
  static const String _achievementDatePrefix = 'achievement_unlocked_at:';

  late Box<UnitProgress> _box;
  late Box<dynamic> _rewardsBox;
  bool _initialized = false;

  Future<void> init({String? hivePath}) async {
    if (_initialized) return;

    if (hivePath == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(hivePath);
    }

    if (!Hive.isAdapterRegistered(UnitProgressAdapter().typeId)) {
      Hive.registerAdapter(UnitProgressAdapter());
    }

    _box = await Hive.openBox<UnitProgress>(_boxName);
    _rewardsBox = await Hive.openBox<dynamic>(_rewardsBoxName);
    _initialized = true;
    await syncAchievements();
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'ProgressTracker.init() لم يُستدعَ بعد. نادِ عليه في main() قبل runApp().',
      );
    }
  }

  UnitProgress getUnitProgress(String unitId) {
    _ensureInitialized();
    return _box.get(unitId) ?? UnitProgress(unitId: unitId);
  }

  bool isUnitUnlocked(String unitId) {
    _ensureInitialized();
    final index = UnitsData.units.indexWhere((unit) => unit.id == unitId);
    if (index < 0) return false;
    if (index == 0) return true;
    return getUnitProgress(UnitsData.units[index - 1].id).completed;
  }

  bool isStageComplete(int startOrder, int endOrder) {
    _ensureInitialized();
    final stageUnits = UnitsData.units.where(
      (unit) => unit.order >= startOrder && unit.order <= endOrder,
    );
    return stageUnits.isNotEmpty &&
        stageUnits.every((unit) => getUnitProgress(unit.id).completed);
  }

  StageRewardStatus getStageRewardStatus(int stage) {
    _ensureInitialized();
    final reward = StageRewards.forStage(stage);
    final claimed = isStageRewardClaimed(stage);
    final complete = isStageComplete(reward.startOrder, reward.endOrder);
    return reward.status(stageComplete: complete, claimed: claimed);
  }

  bool isStageRewardClaimed(int stage) {
    _ensureInitialized();
    final reward = StageRewards.forStage(stage);
    return _rewardsBox.get(reward.id) == true;
  }

  bool isAchievementUnlocked(String achievementId) {
    _ensureInitialized();
    return _rewardsBox.get('$_achievementPrefix$achievementId') == true ||
        _rewardsBox.get('$_achievementDatePrefix$achievementId') != null;
  }

  DateTime? getAchievementUnlockedAt(String achievementId) {
    _ensureInitialized();
    final raw = _rewardsBox.get('$_achievementDatePrefix$achievementId');
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  int getTotalStars() {
    _ensureInitialized();
    return _box.values.fold<int>(0, (sum, progress) => sum + progress.stars);
  }

  int getCompletedStages() {
    _ensureInitialized();
    return StageRewards.all
        .where(
          (reward) => isStageComplete(reward.startOrder, reward.endOrder),
        )
        .length;
  }

  int getUnlockedAchievementsCount() {
    _ensureInitialized();
    return Achievements.all.where((a) => isAchievementUnlocked(a.id)).length;
  }

  int getAchievementProgress(String achievementId) {
    _ensureInitialized();
    final achievement = Achievements.byId(achievementId);

    if (achievement.stage != null) {
      if (achievement.id == 'all_rewards') return getClaimedStageRewards().length;
      final reward = StageRewards.forStage(achievement.stage!);
      return getCompletedUnitCountInRange(reward.startOrder, reward.endOrder);
    }

    switch (achievement.id) {
      case 'first_step':
      case 'five_units':
      case 'ten_units':
      case 'first_stage':
      case 'twenty_five_units':
      case 'half_curriculum':
      case 'all_units':
        return getCompletedUnitIds().length;
      case 'three_star_unit':
        return _box.values.where((progress) => progress.stars >= 3).length;
      case 'ten_stars':
      case 'thirty_stars':
        return getTotalStars();
      default:
        return 0;
    }
  }

  int getCompletedUnitCountInRange(int startOrder, int endOrder) {
    _ensureInitialized();
    return UnitsData.units
        .where((unit) => unit.order >= startOrder && unit.order <= endOrder)
        .where((unit) => getUnitProgress(unit.id).completed)
        .length;
  }

  List<String> getUnlockedAchievementIds() {
    _ensureInitialized();
    return Achievements.all
        .map((achievement) => achievement.id)
        .where(isAchievementUnlocked)
        .toList();
  }

  Future<bool> claimStageReward(int stage) async {
    _ensureInitialized();
    final reward = StageRewards.forStage(stage);
    if (getStageRewardStatus(stage) != StageRewardStatus.available) {
      return false;
    }

    await _rewardsBox.put(reward.id, true);
    await _rewardsBox.put('$_achievementPrefix${reward.achievementId}', true);
    await _markAchievementUnlocked(reward.achievementId);
    await syncAchievements();
    return true;
  }

  Future<void> _markAchievementUnlocked(String achievementId) async {
    if (isAchievementUnlocked(achievementId) &&
        getAchievementUnlockedAt(achievementId) != null) {
      return;
    }
    await _rewardsBox.put(
      '$_achievementDatePrefix$achievementId',
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> syncAchievements() async {
    _ensureInitialized();
    for (final achievement in Achievements.all) {
      final progress = getAchievementProgress(achievement.id);
      var unlocked = progress >= achievement.target;

      if (achievement.stage != null && achievement.id != 'all_rewards') {
        final reward = StageRewards.forStage(achievement.stage!);
        unlocked = isStageComplete(reward.startOrder, reward.endOrder);
      }

      if (unlocked) {
        await _markAchievementUnlocked(achievement.id);
      }
    }
  }

  List<int> getClaimedStageRewards() {
    _ensureInitialized();
    return StageRewards.all
        .where((reward) => isStageRewardClaimed(reward.stage))
        .map((reward) => reward.stage)
        .toList();
  }

  UnitModel? getNextUnit() {
    _ensureInitialized();
    for (final unit in UnitsData.units) {
      if (!getUnitProgress(unit.id).completed) return unit;
    }
    return null;
  }

  Future<void> markUnitComplete(String unitId, {int stars = 1}) async {
    _ensureInitialized();

    final unitIndex = UnitsData.units.indexWhere((unit) => unit.id == unitId);
    if (unitIndex < 0) {
      throw ArgumentError.value(
        unitId,
        'unitId',
        'الوحدة غير موجودة في المنهج',
      );
    }
    if (!isUnitUnlocked(unitId)) {
      throw StateError('لا يمكن إكمال $unitId قبل إكمال الوحدة السابقة.');
    }

    final current = getUnitProgress(unitId);
    final safeStars = stars.clamp(1, 3).toInt();
    final updated = current.copyWith(
      completed: true,
      stars: safeStars > current.stars ? safeStars : current.stars,
      lastAttemptAt: DateTime.now(),
      attemptsCount: current.attemptsCount + 1,
    );
    await _box.put(unitId, updated);
    await syncAchievements();
  }

  Future<void> recordAttempt(String unitId) async {
    _ensureInitialized();
    final current = getUnitProgress(unitId);
    final updated = current.copyWith(
      lastAttemptAt: DateTime.now(),
      attemptsCount: current.attemptsCount + 1,
    );
    await _box.put(unitId, updated);
  }

  List<String> getCompletedUnitIds() {
    _ensureInitialized();
    return _box.values
        .where((progress) => progress.completed)
        .map((progress) => progress.unitId)
        .toList();
  }

  double getOverallProgress(int totalUnitsCount) {
    if (totalUnitsCount == 0) return 0.0;
    final completedCount = getCompletedUnitIds().length;
    return completedCount / totalUnitsCount;
  }

  Future<void> resetAll() async {
    _ensureInitialized();
    await _box.clear();
    await _rewardsBox.clear();
  }
}

import 'package:hive_flutter/hive_flutter.dart';

import '../../models/unit_model.dart';
import '../../models/units_data.dart';
import 'unit_progress.dart';

/// متتبع تقدم الطفل فوق Hive.
///
/// قاعدة التقدم:
/// - الوحدة الأولى متاحة دائماً.
/// - كل وحدة لاحقة تحتاج إكمال الوحدة السابقة.
/// - إكمال الوحدة لا يحدث إلا بعد المرور بكل أنشطتها، بما فيها الـQuiz
///   والـAssessment الموجودان في UnitsData.
/// - النجوم تحفظ أفضل نتيجة للوحدة.
class ProgressTracker {
  ProgressTracker._internal();
  static final ProgressTracker instance = ProgressTracker._internal();

  static const String _boxName = 'arqami_progress';
  late Box<UnitProgress> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(UnitProgressAdapter().typeId)) {
      Hive.registerAdapter(UnitProgressAdapter());
    }

    _box = await Hive.openBox<UnitProgress>(_boxName);
    _initialized = true;
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

  /// هل يمكن للطفل فتح وحدة معينة؟
  bool isUnitUnlocked(String unitId) {
    _ensureInitialized();
    final index = UnitsData.units.indexWhere((unit) => unit.id == unitId);
    if (index < 0) return false;
    if (index == 0) return true;
    return getUnitProgress(UnitsData.units[index - 1].id).completed;
  }

  /// هل أُنجزت كل وحدات المرحلة المحددة؟
  bool isStageComplete(int startOrder, int endOrder) {
    _ensureInitialized();
    final stageUnits = UnitsData.units.where(
      (unit) => unit.order >= startOrder && unit.order <= endOrder,
    );
    return stageUnits.isNotEmpty &&
        stageUnits.every((unit) => getUnitProgress(unit.id).completed);
  }

  /// أول وحدة لم تكتمل بعد، وهي نقطة الاستئناف الطبيعية للطفل.
  UnitModel? getNextUnit() {
    _ensureInitialized();
    for (final unit in UnitsData.units) {
      if (!getUnitProgress(unit.id).completed) return unit;
    }
    return null;
  }

  Future<void> markUnitComplete(String unitId, {int stars = 1}) async {
    _ensureInitialized();
    final current = getUnitProgress(unitId);
    final safeStars = stars.clamp(1, 3).toInt();
    final updated = current.copyWith(
      completed: true,
      stars: safeStars > current.stars ? safeStars : current.stars,
      lastAttemptAt: DateTime.now(),
      attemptsCount: current.attemptsCount + 1,
    );
    await _box.put(unitId, updated);
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
  }
}

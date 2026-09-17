import 'package:hive/hive.dart';

class LearnerProfile {
  static const _boxName = 'arqami_learner_profile';
  static const _ageKey = 'age';

  static Box? _box;

  static Future<void> init() async {
    _box ??= await Hive.openBox(_boxName);
  }

  static int? get age => _box?.get(_ageKey) as int?;

  static bool get isConfigured => age != null;

  static Future<void> setAge(int value) async {
    if (value < 3 || value > 16) {
      throw ArgumentError.value(value, 'value', 'العمر يجب أن يكون بين 3 و16 سنة');
    }
    await init();
    await _box!.put(_ageKey, value);
  }

  static Future<void> clear() async {
    await init();
    await _box!.delete(_ageKey);
  }

  static AgeBand get band => AgeBand.fromAge(age ?? 6);
}

enum AgeBand {
  early,
  primary,
  middle,
  teen,

  ;

  static AgeBand fromAge(int age) {
    if (age <= 5) return AgeBand.early;
    if (age <= 9) return AgeBand.primary;
    if (age <= 12) return AgeBand.middle;
    return AgeBand.teen;
  }

  String get labelAr => switch (this) {
        AgeBand.early => '3–5 سنوات',
        AgeBand.primary => '6–9 سنوات',
        AgeBand.middle => '10–12 سنة',
        AgeBand.teen => '13–16 سنة',
      };
}

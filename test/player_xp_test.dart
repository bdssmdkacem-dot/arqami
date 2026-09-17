import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/progress/player_xp.dart';

void main() {
  group('PlayerXp', () {
    test('starts at level 1', () {
      expect(PlayerXp.levelFromXp(0), 1);
      expect(PlayerXp.levelProgress(0), 0);
      expect(PlayerXp.xpToNextLevel(0), 500);
    });

    test('moves to the next level at each 500 XP', () {
      expect(PlayerXp.levelFromXp(499), 1);
      expect(PlayerXp.levelFromXp(500), 2);
      expect(PlayerXp.levelFromXp(999), 2);
      expect(PlayerXp.levelFromXp(1000), 3);
    });

    test('calculates progress inside the current level', () {
      expect(PlayerXp.xpIntoLevel(625), 125);
      expect(PlayerXp.levelProgress(625), closeTo(.25, .0001));
      expect(PlayerXp.xpToNextLevel(625), 375);
    });
  });
}

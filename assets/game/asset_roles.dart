/// أدوار الأصول البصرية والصوتية في خريطة أرقامي.
///
/// هذه الطبقة لا تعتمد على ملفات بعينها حتى نستطيع استبدال/تحديث
/// الأصول دون ربط المنهج التعليمي بها.
enum GameAssetRole {
  mapBackground,
  companionCharacter,
  levelNode,
  completedNode,
  lockedNode,
  stars,
  reward,
  unlockEffect,
  successEffect,
  tapSound,
  unlockSound,
  successSound,
}

class GameAssetSet {
  const GameAssetSet({
    required this.background,
    required this.companion,
    required this.node,
    required this.completedNode,
    required this.lockedNode,
    required this.stars,
    required this.reward,
    required this.unlockEffect,
    required this.successEffect,
    required this.tapSound,
    required this.unlockSound,
    required this.successSound,
  });

  final String background;
  final String companion;
  final String node;
  final String completedNode;
  final String lockedNode;
  final String stars;
  final String reward;
  final String unlockEffect;
  final String successEffect;
  final String tapSound;
  final String unlockSound;
  final String successSound;
}

/// أسماء المسارات المتوقعة بعد تنزيل الملفات الفعلية من الحزم المعتمدة.
/// تبقى الأسماء في طبقة واحدة لتجنب انتشار المسارات داخل Widgets.
const arqamiGameAssetSet = GameAssetSet(
  background: 'assets/game/backgrounds/world_map.png',
  companion: 'assets/game/characters/companion.png',
  node: 'assets/game/ui/level_node.png',
  completedNode: 'assets/game/ui/level_node_completed.png',
  lockedNode: 'assets/game/ui/level_node_locked.png',
  stars: 'assets/game/rewards/stars.png',
  reward: 'assets/game/rewards/reward_badge.png',
  unlockEffect: 'assets/game/effects/unlock.png',
  successEffect: 'assets/game/effects/success.png',
  tapSound: 'assets/game/sounds/tap.ogg',
  unlockSound: 'assets/game/sounds/unlock.ogg',
  successSound: 'assets/game/sounds/success.ogg',
);

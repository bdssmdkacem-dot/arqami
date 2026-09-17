import 'package:flutter/widgets.dart';

import 'game_theme.dart';

/// Motion constants and small helpers used by the game UI.
class GameAnimations {
  GameAnimations._();

  static const Duration tap = GameTheme.tapMotion;
  static const Duration pop = GameTheme.popMotion;
  static const Duration celebration = GameTheme.celebrationMotion;

  static Curve get playfulCurve => Curves.easeOutBack;
  static Curve get softCurve => Curves.easeOutCubic;
  static Curve get settleCurve => Curves.easeInOutCubic;

  static Widget popIn({
    required Animation<double> animation,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: .88, end: 1).animate(
        CurvedAnimation(parent: animation, curve: playfulCurve),
      ),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

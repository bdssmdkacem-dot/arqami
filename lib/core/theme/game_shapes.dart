import 'package:flutter/material.dart';

import 'game_theme.dart';

/// Reusable shapes for the Arqami game world.
class GameShapes {
  GameShapes._();

  static RoundedRectangleBorder card({double radius = GameTheme.cardRadius}) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      );

  static RoundedRectangleBorder pill() =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(999));

  static BoxDecoration worldCard({
    Color color = GameTheme.paper,
    Color? accent,
    double radius = GameTheme.cardRadius,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (accent ?? Colors.black).withValues(alpha: .08),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: (accent ?? GameTheme.ocean).withValues(alpha: .14),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }

  static BoxDecoration rewardBadge({Color color = GameTheme.sunshine}) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: .30),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}

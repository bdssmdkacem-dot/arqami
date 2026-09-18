import 'package:flutter/material.dart';

import 'game_theme.dart';

class GameShapes {
  GameShapes._();

  static RoundedRectangleBorder card({double radius = GameTheme.cardRadius}) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  static RoundedRectangleBorder pill() =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(GameTheme.chipRadius));

  static BoxDecoration worldCard({
    Color color = GameTheme.paper,
    Color? accent,
    double radius = GameTheme.cardRadius,
  }) {
    final edge = accent ?? GameTheme.ocean;
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: edge.withValues(alpha: .12), width: 1.4),
      boxShadow: [
        BoxShadow(
          color: edge.withValues(alpha: .13),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration softPanel({Color accent = GameTheme.ocean}) =>
      BoxDecoration(
        color: GameTheme.paper,
        borderRadius: BorderRadius.circular(GameTheme.cardRadius),
        border: Border.all(color: accent.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .09),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      );

  static BoxDecoration rewardBadge({Color color = GameTheme.sunshine}) =>
      BoxDecoration(
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

  static BoxDecoration statusPill(Color color) => BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(GameTheme.chipRadius),
        border: Border.all(color: color.withValues(alpha: .22)),
      );
}

import 'package:flutter/material.dart';

/// Design system المركزي للهوية البصرية لأرقامي.
/// كل شاشة ولعبة ومكافأة تستخدم هذه اللغة حتى تبدو التجربة لعبة واحدة.
class GameTheme {
  GameTheme._();

  static const Color sky = Color(0xFFEAF8FF);
  static const Color skyDeep = Color(0xFFBDEBFF);
  static const Color cloud = Color(0xFFFFFFFF);
  static const Color sunshine = Color(0xFFFFD447);
  static const Color mango = Color(0xFFFFA62B);
  static const Color coral = Color(0xFFFF6F61);
  static const Color berry = Color(0xFFEA5B9A);
  static const Color mint = Color(0xFF54D6B2);
  static const Color ocean = Color(0xFF3CA7E8);
  static const Color violet = Color(0xFF8067D9);
  static const Color paper = Color(0xFFFFFEF9);
  static const Color paperWarm = Color(0xFFFFF7E8);
  static const Color ink = Color(0xFF24334A);
  static const Color inkSoft = Color(0xFF63738A);
  static const Color success = Color(0xFF35B875);
  static const Color danger = Color(0xFFEF625F);
  static const Color warning = Color(0xFFFFB52E);

  static const List<Color> worldColors = [
    ocean, mint, sunshine, mango, coral, violet, berry,
  ];

  static Color worldColor(int stage) =>
      worldColors[(stage - 1).abs() % worldColors.length];

  static const double cardRadius = 28;
  static const double smallRadius = 18;
  static const double buttonRadius = 20;
  static const double chipRadius = 999;

  static const EdgeInsets screenPadding =
      EdgeInsets.fromLTRB(16, 12, 16, 20);

  static const Duration tapMotion = Duration(milliseconds: 140);
  static const Duration popMotion = Duration(milliseconds: 260);
  static const Duration celebrationMotion = Duration(milliseconds: 520);

  static const Curve playfulCurve = Curves.easeOutBack;
  static const Curve softCurve = Curves.easeOutCubic;

  static TextStyle get displayNumber => const TextStyle(
        fontSize: 48,
        height: 1,
        fontWeight: FontWeight.w900,
        color: ink,
      );

  static TextStyle get title => const TextStyle(
        fontSize: 22,
        height: 1.15,
        fontWeight: FontWeight.w900,
        color: ink,
      );

  static TextStyle get sectionTitle => const TextStyle(
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w900,
        color: ink,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w600,
        color: inkSoft,
      );

  static LinearGradient worldGradient(int stage) {
    final primary = worldColor(stage);
    final secondary = worldColor(stage + 1);
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [primary.withValues(alpha: .20), secondary.withValues(alpha: .08)],
    );
  }
}

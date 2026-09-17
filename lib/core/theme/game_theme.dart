import 'package:flutter/material.dart';

/// Visual language for the playful Arqami game world.
///
/// This layer intentionally stays independent from curriculum logic so the
/// same learning engine can be presented as a game without changing content.
class GameTheme {
  GameTheme._();

  // Sky / world colors.
  static const Color sky = Color(0xFFEAF8FF);
  static const Color skyDeep = Color(0xFFBDEBFF);
  static const Color cloud = Color(0xFFFFFFFF);

  // Character / reward colors.
  static const Color sunshine = Color(0xFFFFD447);
  static const Color mango = Color(0xFFFFA62B);
  static const Color coral = Color(0xFFFF6F61);
  static const Color berry = Color(0xFFEA5B9A);
  static const Color mint = Color(0xFF54D6B2);
  static const Color ocean = Color(0xFF3CA7E8);
  static const Color violet = Color(0xFF8067D9);

  // Game surfaces.
  static const Color paper = Color(0xFFFFFEF9);
  static const Color paperWarm = Color(0xFFFFF7E8);
  static const Color ink = Color(0xFF24334A);
  static const Color inkSoft = Color(0xFF63738A);
  static const Color success = Color(0xFF35B875);
  static const Color danger = Color(0xFFEF625F);

  static const List<Color> worldColors = [
    ocean,
    mint,
    sunshine,
    mango,
    coral,
    violet,
    berry,
  ];

  static Color worldColor(int stage) =>
      worldColors[(stage - 1).abs() % worldColors.length];

  /// Large, playful radius used by game cards and controls.
  static const double cardRadius = 28;
  static const double buttonRadius = 20;

  /// Standard motion timings. Keep feedback quick enough for children.
  static const Duration tapMotion = Duration(milliseconds: 140);
  static const Duration popMotion = Duration(milliseconds: 260);
  static const Duration celebrationMotion = Duration(milliseconds: 520);
}

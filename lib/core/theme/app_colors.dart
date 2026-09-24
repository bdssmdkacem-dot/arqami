import 'package:flutter/material.dart';

/// ألوان الهوية المرحة لأرقامي.
///
/// الهوية الجديدة مبنية على عالم ألعاب تعليمي مشرق: سماء، نعناع، شمسي،
/// مرجاني وبنفسجي. الألوان القديمة لا تُستخدم كهوية رئيسية حتى لا تبدو
/// الواجهة كلوحة تطبيق تقليدية.
class AppColors {
  AppColors._();

  // هوية العلامة: أخضر زمردي + ذهبي + كريمي.
  // تُستخدم للهوية والعناصر العامة، بينما تبقى GameTheme أكثر حيوية
  // داخل الألعاب والعوالم.
  static const Color brandEmerald = Color(0xFF0B3D2E);
  static const Color brandEmeraldSoft = Color(0xFF165A45);
  static const Color brandGold = Color(0xFFF4C430);
  static const Color brandGoldLight = Color(0xFFFFD966);
  static const Color brandCream = Color(0xFFFFF7E6);

  // الهوية الرئيسية للألعاب.
  static const Color primary = Color(0xFF3CA7E8);
  static const Color primaryDark = Color(0xFF247EBA);
  static const Color secondary = Color(0xFF54D6B2);
  static const Color accent = Color(0xFFFFA62B);
  static const Color sunshine = Color(0xFFFFD447);
  static const Color coral = Color(0xFFFF6F61);
  static const Color berry = Color(0xFFEA5B9A);
  static const Color violet = Color(0xFF8067D9);

  // الخلفيات.
  static const Color background = Color(0xFFEAF8FF);
  static const Color backgroundAlt = Color(0xFFFFF7E8);
  static const Color cardBackground = Color(0xFFFFFEF9);
  static const Color surfaceSoft = Color(0xFFE0F6EF);

  // حالات الوحدات والخريطة.
  static const Color locked = Color(0xFF9BA8B8);
  static const Color lockedSoft = Color(0xFFE6EBF0);
  static const Color inProgress = sunshine;
  static const Color completed = secondary;
  static const Color completedSoft = Color(0xFFDDF8EF);

  // تغذية راجعة.
  static const Color correct = Color(0xFF35B875);
  static const Color correctSoft = Color(0xFFE1F7EB);
  static const Color incorrect = Color(0xFFEF625F);
  static const Color incorrectSoft = Color(0xFFFFE9E7);

  // النصوص.
  static const Color textPrimary = Color(0xFF24334A);
  static const Color textSecondary = Color(0xFF63738A);
  static const Color textMuted = Color(0xFF91A0B2);

  // توافق اسمي محدود مع الشاشات القديمة.
  static const Color teal = primary;
  static const Color tealDark = primaryDark;
  static const Color tealLight = Color(0xFF7DD9FF);
  static const Color tealSoft = Color(0xFFDFF4FF);
  static const Color gold = accent;
  static const Color goldLight = sunshine;
  static const Color goldSoft = Color(0xFFFFF3CF);
  static const Color terracotta = coral;
  static const Color terracottaSoft = Color(0xFFFFE8E4);

  static const List<Color> worldPalette = [
    primary,
    secondary,
    sunshine,
    accent,
    coral,
    violet,
    berry,
  ];

  static const List<Color> itemPalette = [
    primary,
    secondary,
    sunshine,
    accent,
    coral,
    violet,
    berry,
  ];

  static Color itemColorFor(int index) =>
      itemPalette[index % itemPalette.length];

  static Color worldColorFor(int stage) =>
      worldPalette[(stage - 1).abs() % worldPalette.length];
}

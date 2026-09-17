import 'package:flutter/material.dart';

/// لوحة الألوان الموحدة لأرقامي.
/// الهوية تجمع بين الزليج المغربي والذهبي مع ألوان حالة واضحة،
/// وتبقى هادئة بما يكفي لتناسب التعلم ولا تتحول إلى واجهة مزدحمة.
class AppColors {
  AppColors._();

  // الهوية الأساسية
  static const Color teal = Color(0xFF00695C);
  static const Color tealDark = Color(0xFF004D40);
  static const Color tealLight = Color(0xFF4DB6AC);
  static const Color tealSoft = Color(0xFFE0F2F1);
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color goldSoft = Color(0xFFFFF3C4);
  static const Color terracotta = Color(0xFFD2691E);
  static const Color terracottaSoft = Color(0xFFFCE8D8);

  // خلفيات
  static const Color background = Color(0xFFFFF8E1);
  static const Color backgroundAlt = Color(0xFFFFFDF6);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF7F1DD);

  // حالات الوحدات والخريطة
  static const Color locked = Color(0xFF9E9E9E);
  static const Color lockedSoft = Color(0xFFE9E9E9);
  static const Color inProgress = gold;
  static const Color completed = teal;
  static const Color completedSoft = tealSoft;

  // تغذية راجعة
  static const Color correct = Color(0xFF2E7D32);
  static const Color correctSoft = Color(0xFFE8F5E9);
  static const Color incorrect = Color(0xFFD32F2F);
  static const Color incorrectSoft = Color(0xFFFFEBEE);

  // النصوص
  static const Color textPrimary = Color(0xFF3E2723);
  static const Color textSecondary = Color(0xFF6D4C41);
  static const Color textMuted = Color(0xFF8D7B72);

  // ألوان العوالم — تستعمل لاحقاً للخريطة والوحدات.
  static const List<Color> worldPalette = [
    teal,
    gold,
    terracotta,
    Color(0xFF5E6AB4),
    Color(0xFF7B5E8E),
    Color(0xFF3F7D68),
    Color(0xFFB06B3C),
  ];

  /// مجموعة ألوان للعناصر القابلة للعد/المقارنة.
  static const List<Color> itemPalette = [
    gold,
    teal,
    terracotta,
    tealLight,
    goldLight,
  ];

  static Color itemColorFor(int index) =>
      itemPalette[index % itemPalette.length];

  static Color worldColorFor(int stage) =>
      worldPalette[(stage - 1).abs() % worldPalette.length];
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Design system واحد لأرقامي: مرح، هادئ، واضح ومناسب للأطفال.
/// نستخدم خط النظام العربي لتفادي الاعتماد على خط غير مسجّل في pubspec.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.teal,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        error: AppColors.incorrect,
      ),
    );

    final text = base.textTheme.apply(
      fontFamily: 'sans-serif',
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.25),
        bodyLarge: text.bodyLarge?.copyWith(height: 1.45),
        bodyMedium: text.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0x14000000)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          side: const BorderSide(color: AppColors.teal, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.teal,
        linearTrackColor: Color(0x1A00695C),
      ),
    );
  }
}

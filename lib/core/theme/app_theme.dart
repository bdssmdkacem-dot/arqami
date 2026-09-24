import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'game_theme.dart';

/// Design system موحد لأرقامي: لعبة تعليمية مرحة، واضحة، وحيوية.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandEmerald,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.brandEmerald,
        onPrimary: Colors.white,
        primaryContainer: AppColors.brandCream,
        onPrimaryContainer: AppColors.brandEmerald,
        secondary: AppColors.brandGold,
        onSecondary: AppColors.brandEmerald,
        secondaryContainer: AppColors.brandCream,
        onSecondaryContainer: AppColors.brandEmerald,
        tertiary: AppColors.violet,
        onTertiary: Colors.white,
        surface: GameTheme.paper,
        onSurface: AppColors.textPrimary,
        error: AppColors.incorrect,
        errorContainer: AppColors.incorrectSoft,
      ),
    );

    final text = base.textTheme.apply(
      fontFamily: 'sans-serif',
      fontFamilyFallback: const ['Noto Sans Arabic', 'Arial'],
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text.copyWith(
        displayLarge: text.displayLarge?.copyWith(fontWeight: FontWeight.w900, height: 1.05),
        displaySmall: text.displaySmall?.copyWith(fontWeight: FontWeight.w900, height: 1.08),
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.12),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w900, height: 1.15),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
        bodyLarge: text.bodyLarge?.copyWith(height: 1.4),
        bodyMedium: text.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.35),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: .1),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 21,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: GameTheme.paper,
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: .13),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameTheme.cardRadius),
          side: const BorderSide(color: Color(0x12000000)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 58),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: .28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GameTheme.buttonRadius)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 58),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GameTheme.buttonRadius)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandEmerald,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GameTheme.buttonRadius)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: GameTheme.paper,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: GameTheme.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shadowColor: AppColors.primary.withValues(alpha: .16),
        indicatorColor: AppColors.primary.withValues(alpha: .16),
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: selected ? 25 : 23,
            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GameTheme.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSoft,
        selectedColor: AppColors.primary.withValues(alpha: .16),
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GameTheme.paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0x18000000))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0x18000000))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.primary, width: 2.5)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x12000000), thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
        linearTrackColor: Color(0x1A54D6B2),
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}

import 'package:flutter/material.dart';

import 'core/ads/ad_service.dart';
import 'core/audio/audio_service.dart';
import 'core/progress/progress_tracker.dart';
import 'core/theme/app_colors.dart';
import 'screens/units_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ProgressTracker.instance.init();
  await AudioService.instance.init();
  await AdService.instance.init();

  runApp(const ArqamiApp());
}

class ArqamiApp extends StatelessWidget {
  const ArqamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        primary: AppColors.teal,
        secondary: AppColors.gold,
        surface: AppColors.cardBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
    );

    return MaterialApp(
      title: 'أرقامي',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      theme: base.copyWith(
        textTheme: base.textTheme.apply(
          fontFamily: 'sans-serif',
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const UnitsMapScreen(),
    );
  }
}

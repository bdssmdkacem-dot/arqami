import 'package:flutter/material.dart';

import 'core/ads/ad_service.dart';
import 'core/audio/audio_service.dart';
import 'core/progress/progress_tracker.dart';
import 'core/theme/app_theme.dart';
import 'models/final_curriculum_override.dart';
import 'screens/units_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  applyFinalCurriculumStageSplit();
  await ProgressTracker.instance.init();
  await AudioService.instance.init();
  await AdService.instance.init();

  runApp(const ArqamiApp());
}

class ArqamiApp extends StatelessWidget {
  const ArqamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أرقامي',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const UnitsMapScreen(),
    );
  }
}

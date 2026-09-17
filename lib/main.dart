import 'dart:async';

import 'package:flutter/material.dart';

import 'core/ads/ad_service.dart';
import 'core/audio/audio_service.dart';
import 'core/profile/learner_profile.dart';
import 'core/progress/progress_tracker.dart';
import 'core/theme/app_theme.dart';
import 'models/deep_curriculum_fixes.dart';
import 'models/final_curriculum_override.dart';
import 'screens/arqami_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  applyFinalCurriculumStageSplit();
  applyDeepCurriculumFixes();
  await ProgressTracker.instance.init();
  await LearnerProfile.init();

  // لا نجعل خدمات الصوت والإعلانات الثانوية تمنع ظهور الواجهة.
  // أي فشل فيها لا يجب أن يغلق التطبيق عند بدء التشغيل.
  runApp(const ArqamiApp());

  unawaited(_initializeSecondaryServices());
}

Future<void> _initializeSecondaryServices() async {
  try {
    await AudioService.instance.init();
  } catch (error, stackTrace) {
    debugPrint('AudioService initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  try {
    await AdService.instance.init();
  } catch (error, stackTrace) {
    debugPrint('AdService initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
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
      home: const ArqamiHomeScreen(),
    );
  }
}

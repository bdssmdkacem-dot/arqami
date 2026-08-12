# أرقامي (Arqami)

تطبيق تعليمي بـ Flutter لتعلم الأرقام العربية للأطفال (4-6 سنوات) — الجزء الثاني من سلسلة تطبيقات تعليمية بعد **وقتي (Waqti)**.

## المميزات

- 13 وحدة تعليمية متدرجة: تتبّع الأرقام، العد، المطابقة، المقارنة البصرية، واستكشاف الأرقام في الحياة اليومية (ساعة، هاتف، لوحة سيارة)
- بدون أي صورة أو ملف صوتي خارجي: كل الرسومات مبنية بـ `CustomPainter`/أيقونات Material، وكل الأصوات عبر Text-to-Speech حي (`flutter_tts`)
- حفظ تقدم الطفل محلياً عبر Hive (بدون إنترنت)
- إعلانات AdMob بمعاملة **child-directed** إلزامية (بانر + إعلان بيني كل 3 وحدات)
- تخطيط متجاوب (Responsive) يتلاءم مع الهاتف والتابلت
- واجهة كاملة RTL بالعربية الفصحى

## البنية

```
lib/
├── core/
│   ├── ads/           # AdService — إعلانات AdMob بمعاملة child-directed
│   ├── audio/         # AudioService — نطق الأرقام + تغذية راجعة (TTS + SystemSound)
│   ├── progress/      # ProgressTracker — حفظ التقدم عبر Hive
│   └── theme/         # لوحة ألوان مغربية موحّدة + أدوات التخطيط المتجاوب
├── models/
│   ├── number_path.dart   # مسارات تتبّع الأرقام 0-9
│   ├── unit_model.dart    # نموذج الوحدة والأنشطة
│   └── units_data.dart    # محتوى الـ13 وحدة
├── screens/
│   ├── units_map_screen.dart   # خريطة الوحدات الرئيسية
│   └── unit_player_screen.dart # محرك تشغيل أي وحدة
├── widgets/
│   ├── games/    # TraceWidget, MatchingWidget, DragCountWidget,
│   │              # ComparisonWidget, SceneExploreWidget
│   └── shared/   # NumberDisplay, QuantityRow, BannerAdWidget
└── main.dart
```

## التشغيل

```bash
flutter pub get
flutter run
```

## ⚠️ ملاحظات مهمة قبل الإنتاج

1. **مسارات الأرقام** (`lib/models/number_path.dart`): إحداثيات تقريبية، تحتاج ضبط بصري دقيق (افتح كل رقم على الشاشة وعدّل النقاط حتى يطابق الشكل الفعلي).
2. **TypeId في Hive** (`lib/core/progress/unit_progress.dart`): معرّف كـ `10` لتفادي التعارض مع مشاريع أخرى فنفس الجهاز (مثل وقتي). تأكد من عدم التعارض قبل الدمج.
3. **flutter_tts**: يعتمد على محرك TTS العربي المثبت على الجهاز. جرّب على أجهزة Android متوسطة الفئة شائعة فالمغرب للتأكد من وضوح النطق.
4. **الخط**: `main.dart` يفترض خط `Cairo` — بدّله إذا كنت تستعمل خطاً آخر (زد الملفات فـ `pubspec.yaml` تحت `fonts`).
5. **AdMob** — مدمج بمعرّفات اختبار (`_testBannerUnitId`/`_testInterstitialUnitId` فـ `lib/core/ads/ad_service.dart`). قبل النشر:
   - عوّضهم بمعرّفاتك الحقيقية من لوحة تحكم AdMob
   - زد فـ `android/app/src/main/AndroidManifest.xml` داخل `<application>`:
     ```xml
     <meta-data
         android:name="com.google.android.gms.ads.APPLICATION_ID"
         android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
     ```
   - زد فـ `ios/Runner/Info.plist` نفس المعرّف تحت `GADApplicationIdentifier`
   - تأكد أن حساب AdMob مضبوط "Primarily child-directed" أو "Mixed audience" مع تفعيل معاملة الأطفال لكل وحدة إعلانية (الإعدادات فـ `AdService` ماشي كافية لوحدها لضمان الامتثال الكامل لـ COPPA)

## الحالة

13/13 وحدة قابلة للعب فعلياً. المشروع الثاني من سلسلة "أطفالي" التعليمية بعد وقتي.

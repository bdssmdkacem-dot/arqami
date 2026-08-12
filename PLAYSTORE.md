# دليل النشر على Google Play Store

⚠️ هاد الدليل خاصو يُتّبع **بعد** ما تكمّل خطوات `SETUP.md` (يعني عندك
مشروع Flutter كامل شغّال بـ `flutter run` بنجاح). النشر بلا تجربة
محلية ناجحة أولاً خطر.

## 1. توليد مفتاح التوقيع (Keystore)

```bash
keytool -genkey -v -keystore ~/arqami-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias arqami
```

**احتفظ بهاد الملف وكلمة السر فمكان آمن — إذا ضعتو، ما تقدرش تحدّث
التطبيق فالمستقبل، خاصك تنشر تطبيق جديد بمعرّف مختلف.**

## 2. ربط المفتاح بالمشروع

أنشئ `android/key.properties` (بلا ما تزيدو لـ git — موجود فـ
`.gitignore` بالأرشيف):

```properties
storePassword=<كلمة سر الـ keystore>
keyPassword=<كلمة سر الـ alias>
keyAlias=arqami
storeFile=/home/YOUR_USER/arqami-release-key.jks
```

فـ `android/app/build.gradle`، زد قبل `android {`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

وداخل `android { ... }` زد:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

## 3. أيقونة التطبيق

خاصك أيقونة 512×512px (PNG، بلا شفافية للمتجر). استعمل حزمة
`flutter_launcher_icons`:

```yaml
# زدها فـ pubspec.yaml تحت dev_dependencies
flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
```

```bash
flutter pub run flutter_launcher_icons
```

## 4. بناء نسخة الإصدار

```bash
flutter build appbundle --release
```

الملف الناتج: `build/app/outputs/bundle/release/app-release.aab`
(هذا اللي كترفعو لـ Play Console، ماشي APK).

## 5. ⚠️ متطلبات خاصة — تطبيق موجّه للأطفال (Families Policy)

بما أن أرقامي موجّه لأطفال 4-6 سنوات، Google كيطبّق قواعد إضافية
صارمة **إلزامية** قبل القبول:

- **Target API level**: لازم يكون أحدث إصدار مطلوب من Google (يتغيّر
  كل سنة — تحقق من [متطلبات Play Console](https://support.google.com/googleplay/android-developer/answer/11926878) وقت النشر)
- **Data Safety Form**: خاصك تصرّح بدقة بأي بيانات كيجمعها التطبيق.
  أرقامي كيجمع: معرّف إعلاني (عبر AdMob) للإعلانات — خاصك تصرّح بيه
- **سياسة الخصوصية (Privacy Policy)**: إلزامية، خاصها تكون مستضافة
  على رابط عام (موقع، GitHub Pages، إلخ) — راجع
  `PRIVACY_POLICY_TEMPLATE.md` بالأرشيف كنقطة انطلاق
- **Ads SDK Index**: تأكد `google_mobile_ads` مسجّل فـ
  [Ads SDK Index](https://support.google.com/googleplay/android-developer/answer/9283445) — عادة مسجّل تلقائياً كونه من Google نفسها
- **Target audience declaration**: فـ Play Console، صرّح أن التطبيق
  موجّه بشكل أساسي أو جزئي للأطفال تحت 13 سنة
- **الإعلانات**: خاصها تكون مصنّفة G وموجّهة للأطفال (already مضبوطة
  فـ `AdService`) — Google كيراجع هذا يدوياً أحياناً

## 6. قائمة تحقق نهائية قبل الرفع

- [ ] جرّبت التطبيق على جهاز Android حقيقي (ماشي إيموليتور فقط)
- [ ] بدّلت معرّفات AdMob التجريبية بالحقيقية فـ `ad_service.dart`
- [ ] بدّلت `APPLICATION_ID` فـ `AndroidManifest.xml` بمعرّفك الحقيقي
- [ ] رفعت سياسة الخصوصية على رابط عام وأضفتيه فـ Play Console
- [ ] عبّيت Data Safety Form بدقة
- [ ] صرّحت أن التطبيق موجّه للأطفال
- [ ] جهّزت 2-8 screenshots (1080×1920px تقريباً) + وصف التطبيق بالعربية
- [ ] رفعت `app-release.aab` (ماشي APK)

## المراجع الرسمية

- [Google Play Console](https://play.google.com/console)
- [Families Policy Requirements](https://support.google.com/googleplay/android-developer/answer/9893335)
- [Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469)

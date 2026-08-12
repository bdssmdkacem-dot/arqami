import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// خدمة موحّدة لإدارة إعلانات AdMob — بمعاملة **child-directed** إلزامية
/// لأن أرقامي موجّه للأطفال (4-6 سنوات)، بنفس السياسة المستعملة فوقتي.
///
/// ⚠️ قبل النشر على المتجر:
///   1. عوّض _testBannerUnitId و_testInterstitialUnitId بمعرّفات
///      AdMob الحقيقية ديالك (من لوحة تحكم AdMob).
///   2. تأكد أن حساب AdMob مضبوط كـ "Primarily child-directed" أو
///      "Mixed audience" مع تفعيل معاملة الأطفال لكل وحدة إعلانية،
///      وإلا فالإعدادات هنا (tagForChildDirectedTreatment) ما
///      كافيتش لوحدها للامتثال الكامل لـ COPPA.
///   3. زد فـ AndroidManifest.xml (android/app/src/main/AndroidManifest.xml):
///      ```xml
///      <meta-data
///          android:name="com.google.android.gms.ads.APPLICATION_ID"
///          android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
///      ```
///   4. زد فـ ios/Runner/Info.plist نفس المعرّف تحت GADApplicationIdentifier.
class AdService {
  AdService._internal();
  static final AdService instance = AdService._internal();

  // معرّفات اختبار رسمية من Google — آمنة للتطوير، ما كتولّدش دخل حقيقي
  static const String _testBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  /// عدّل هادو لمعرّفاتك الحقيقية قبل الإصدار للمتجر
  static const String bannerUnitId = _testBannerUnitId;
  static const String interstitialUnitId = _testInterstitialUnitId;

  InterstitialAd? _interstitialAd;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await MobileAds.instance.initialize();

    // معاملة إلزامية للأطفال — كتخبر Google تعامل مع كل الطلبات
    // الإعلانية كموجّهة للأطفال، وتمنع الإعلانات الشخصية والمحتوى
    // الغير مناسب
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );

    _initialized = true;
    _loadInterstitial();
  }

  AdRequest _childSafeRequest() => const AdRequest();

  /// ينشئ BannerAd جاهز للعرض (يُستهلك من BannerAdWidget فالواجهة)
  BannerAd createBannerAd({required VoidCallback onLoaded}) {
    return BannerAd(
      adUnitId: bannerUnitId,
      size: AdSize.banner,
      request: _childSafeRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: _childSafeRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// يعرض إعلان بيني إذا كان جاهز (يُستدعى بعد إكمال وحدة، ليس بعد
  /// كل نشاط — تفادياً لإزعاج الطفل/الأهل). كيعاود يحمّل واحد جديد
  /// تلقائياً بعد العرض.
  Future<void> maybeShowInterstitial() async {
    final ad = _interstitialAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial(); // نحمّل واحد جديد للمرة الجاية
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
    );
    await ad.show();
  }
}

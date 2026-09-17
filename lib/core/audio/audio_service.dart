import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// نظام الصوت في أرقامي.
///
/// يفصل بين:
/// - TTS: نطق الأرقام والتعليمات والتغذية الراجعة.
/// - SFX: أصوات اللعب القصيرة.
/// - Music: موسيقى العالم الاختيارية، مع تحكم مستقل في الصوت.
///
/// فشل أي ملف تجميلي لا يوقف التعلم؛ توجد دائماً آلية fallback بسيطة.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _muted = false;
  bool _initialized = false;
  double _sfxVolume = 1.0;
  double _musicVolume = .28;
  int _correctPhraseIndex = 0;

  bool get isMuted => _muted;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;

  static const Map<int, String> _numberWords = {
    0: 'صفر',
    1: 'واحد',
    2: 'اثنان',
    3: 'ثلاثة',
    4: 'أربعة',
    5: 'خمسة',
    6: 'ستة',
    7: 'سبعة',
    8: 'ثمانية',
    9: 'تسعة',
    10: 'عشرة',
    11: 'أحد عشر',
    12: 'اثنا عشر',
  };

  static const List<String> _correctPhrases = [
    'أحسنت',
    'ممتاز',
    'رائع',
    'برافو عليك',
  ];

  Future<void> init() async {
    if (_initialized) return;

    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(.42);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);

    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _sfxPlayer.setVolume(_sfxVolume);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);

    _initialized = true;
  }

  void setMuted(bool muted) {
    _muted = muted;
    if (muted) {
      _tts.stop();
      _sfxPlayer.stop();
      _musicPlayer.pause();
    } else if (_initialized) {
      // لا نشغل الموسيقى تلقائياً عند فك الكتم حتى لا يفاجأ الطفل بالصوت.
    }
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0).toDouble();
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0).toDouble();
    await _musicPlayer.setVolume(_musicVolume);
  }

  Future<void> playMusic(String asset) async {
    if (_muted || !_initialized || _musicVolume <= 0) return;
    try {
      await _musicPlayer.play(AssetSource(asset), volume: _musicVolume);
    } catch (_) {
      // الموسيقى اختيارية؛ لا تؤثر على اللعب إذا لم يوجد الملف.
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> _playSfx(String asset, {bool fallbackClick = false}) async {
    if (_muted || !_initialized || _sfxVolume <= 0) return;
    try {
      // أصوات اللعب قصيرة، لذلك نستبدل المؤثر السابق بدلاً من تكديس الأصوات.
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(asset), volume: _sfxVolume);
    } catch (_) {
      if (fallbackClick) {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  Future<void> playNumber(int digit) async {
    if (_muted) return;
    final word = _numberWords[digit];
    if (word == null) return;
    await _tts.stop();
    await _tts.speak(word);
  }

  Future<void> speak(String text) async {
    if (_muted) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> playTap() => _playSfx('assets/game/sounds/tap.wav', fallbackClick: true);

  void playTick() {
    if (_muted) return;
    SystemSound.play(SystemSoundType.click);
    _playSfx('assets/game/sounds/tap.wav');
  }

  Future<void> playCorrect() async {
    if (_muted) return;
    await _playSfx('assets/game/sounds/success.wav', fallbackClick: true);
    final phrase = _correctPhrases[_correctPhraseIndex % _correctPhrases.length];
    _correctPhraseIndex++;
    await _tts.stop();
    await _tts.speak(phrase);
  }

  Future<void> playTryAgain() async {
    if (_muted) return;
    await _playSfx('assets/game/sounds/tap.wav', fallbackClick: true);
    await _tts.stop();
    await _tts.speak('حاول مرة أخرى');
  }

  Future<void> playUnitComplete() async {
    if (_muted) return;
    await _playSfx('assets/game/sounds/success.wav', fallbackClick: true);
    await _tts.stop();
    await _tts.speak('أحسنت! أكملت الوحدة بنجاح');
  }

  Future<void> playReward() async {
    if (_muted) return;
    await _playSfx('assets/game/sounds/success.wav', fallbackClick: true);
    await _tts.stop();
    await _tts.speak('مكافأة رائعة!');
  }

  Future<void> playUnlock() async {
    if (_muted) return;
    await _playSfx('assets/game/sounds/success.wav', fallbackClick: true);
  }

  Future<void> dispose() async {
    await _tts.stop();
    await _sfxPlayer.dispose();
    await _musicPlayer.dispose();
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// خدمة الصوت الموحدة في أرقامي.
///
/// - الأرقام والعبارات التعليمية: TTS عربي.
/// - النقرات والنجاح وإكمال الوحدة: أصوات Kenney UI المحلية.
/// - إذا تعذر تحميل ملف صوتي، تبقى التجربة الصوتية الأساسية عبر TTS/SystemSound.
class AudioService {
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _uiPlayer = AudioPlayer();
  bool _muted = false;
  bool _initialized = false;

  bool get isMuted => _muted;

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

  int _correctPhraseIndex = 0;

  Future<void> init() async {
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.42);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
    await _uiPlayer.setReleaseMode(ReleaseMode.stop);
    _initialized = true;
  }

  void setMuted(bool muted) {
    _muted = muted;
    if (muted) {
      _tts.stop();
      _uiPlayer.stop();
    }
  }

  Future<void> _playUi(String asset) async {
    if (_muted || !_initialized) return;
    try {
      await _uiPlayer.stop();
      await _uiPlayer.play(AssetSource(asset));
    } catch (_) {
      // الصوت التجميلي ليس سبباً لتعطيل النشاط التعليمي.
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

  void playTick() {
    if (_muted) return;
    SystemSound.play(SystemSoundType.click);
    _playUi('assets/game/sounds/tap.wav');
  }

  Future<void> playCorrect() async {
    if (_muted) return;
    await _playUi('assets/game/sounds/success.wav');
    final phrase = _correctPhrases[_correctPhraseIndex % _correctPhrases.length];
    _correctPhraseIndex++;
    await _tts.stop();
    await _tts.speak(phrase);
  }

  Future<void> playTryAgain() async {
    if (_muted) return;
    await _playUi('assets/game/sounds/tap.wav');
    await _tts.stop();
    await _tts.speak('حاول مرة أخرى');
  }

  Future<void> playUnitComplete() async {
    if (_muted) return;
    await _playUi('assets/game/sounds/success.wav');
    await _tts.stop();
    await _tts.speak('أحسنت! أكملت الوحدة بنجاح');
  }

  Future<void> playUnlock() async {
    if (_muted) return;
    await _playUi('assets/game/sounds/success.wav');
  }

  Future<void> dispose() async {
    await _tts.stop();
    await _uiPlayer.dispose();
  }
}

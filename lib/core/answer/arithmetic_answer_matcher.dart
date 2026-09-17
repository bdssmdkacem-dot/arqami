import '../../models/unit_model.dart';

class ArithmeticAnswerMatcher {
  const ArithmeticAnswerMatcher._();

  static String normalize(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const eastern = '۰۱۲۳۴۵۶۷۸۹';
    var value = input.trim();
    for (var i = 0; i < 10; i++) {
      value = value.replaceAll(arabic[i], '$i').replaceAll(eastern[i], '$i');
    }
    value = value
        .replaceAll('٫', '.')
        // In answer fields commas are accepted as decimal separators.
        .replaceAll(',', '.')
        .replaceAll('،', '.')
        .replaceAll('٬', '.')
        .replaceAll('؛', ';')
        .replaceAll('؟', '?');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    value = value.replaceAll(RegExp(r'\s*و\s*الباقي\s*'), ' والباقي ');
    return value;
  }

  static String normalizeText(String input) {
    var value = normalize(input).toLowerCase();
    value = value.replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670]'), '');
    value = value
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي');
    value = value.replaceAll(RegExp(r'[\u200E\u200F]'), '');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return value;
  }

  static num? parseNumber(String input) {
    final normalized = normalize(input);
    if (normalized.isEmpty) return null;
    final direct = num.tryParse(normalized);
    if (direct != null) return direct;

    const words = <String, int>{
      'صفر': 0,
      'واحد': 1,
      'واحدة': 1,
      'اثنان': 2,
      'اثنين': 2,
      'اثنتان': 2,
      'اثنتين': 2,
      'ثلاثة': 3,
      'ثلاث': 3,
      'اربعة': 4,
      'أربعة': 4,
      'اربعه': 4,
      'خمسة': 5,
      'خمس': 5,
      'ستة': 6,
      'ست': 6,
      'سبعة': 7,
      'سبع': 7,
      'ثمانية': 8,
      'ثمان': 8,
      'تسعة': 9,
      'تسع': 9,
      'عشرة': 10,
      'عشر': 10,
    };
    return words[normalizeText(normalized)];
  }

  static bool matches(ArithmeticQuestion question, String rawInput) {
    if (question.correctAnswerText != null) {
      return normalizeText(rawInput) == normalizeText(question.correctAnswerText!);
    }
    final value = parseNumber(rawInput);
    final expected = question.correctAnswer;
    if (value == null || expected == null) return false;
    return (value - expected).abs() < 0.000001;
  }
}

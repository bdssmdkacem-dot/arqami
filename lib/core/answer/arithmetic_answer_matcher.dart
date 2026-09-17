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
    value = value.replaceAll('٫', '.').replaceAll(',', '.').replaceAll('،', '.');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    value = value.replaceAll(RegExp(r'\s*و\s*الباقي\s*'), ' والباقي ');
    return value;
  }

  static num? parseNumber(String input) {
    final normalized = normalize(input);
    if (normalized.isEmpty) return null;
    return num.tryParse(normalized);
  }

  static bool matches(ArithmeticQuestion question, String rawInput) {
    if (question.correctAnswerText != null) {
      return normalize(rawInput) == normalize(question.correctAnswerText!);
    }
    final value = parseNumber(rawInput);
    final expected = question.correctAnswer;
    if (value == null || expected == null) return false;
    return (value - expected).abs() < 0.000001;
  }
}

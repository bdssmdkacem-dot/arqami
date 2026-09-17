import 'package:flutter_test/flutter_test.dart';

void main() {
  String normalizeDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const eastern = '۰۱۲۳۴۵۶۷۸۹';
    var value = input.trim();
    for (var i = 0; i < 10; i++) {
      value = value.replaceAll(arabic[i], '$i').replaceAll(eastern[i], '$i');
    }
    return value.replaceAll('٫', '.').replaceAll(',', '.').replaceAll('،', '.');
  }

  num? parseNumber(String input) => num.tryParse(normalizeDigits(input));

  bool matchesNumeric(String input, num expected) {
    final value = parseNumber(input);
    return value != null && (value - expected).abs() < 0.000001;
  }

  bool matchesText(String input, String expected) {
    return normalizeDigits(input) == normalizeDigits(expected);
  }

  test('accepts decimal answers', () {
    expect(matchesNumeric('0.75', 0.75), isTrue);
    expect(matchesNumeric('١٫٨', 1.8), isTrue);
    expect(matchesNumeric('1,5', 1.5), isTrue);
  });

  test('accepts integer answers through numeric engine', () {
    expect(matchesNumeric('٤', 4), isTrue);
    expect(matchesNumeric('4', 4), isTrue);
  });

  test('accepts textual remainder answers with Arabic digits', () {
    expect(matchesText('4 والباقي 2', '4 والباقي 2'), isTrue);
    expect(matchesText('٤ والباقي ٢', '4 والباقي 2'), isTrue);
  });

  test('rejects incorrect numeric and textual answers', () {
    expect(matchesNumeric('0.7', 0.75), isFalse);
    expect(matchesText('4 والباقي 1', '4 والباقي 2'), isFalse);
  });

  test('trims answer whitespace', () {
    expect(matchesNumeric(' 0.75 ', 0.75), isTrue);
    expect(matchesText(' 4 والباقي 2 ', '4 والباقي 2'), isTrue);
  });
}

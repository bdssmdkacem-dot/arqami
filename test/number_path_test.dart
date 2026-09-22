import 'package:flutter_test/flutter_test.dart';
import 'package:arqami/models/number_path.dart';

void main() {
  test('all digits have a tracing path', () {
    for (var digit = 0; digit <= 9; digit++) {
      final path = NumberPathData.getPath(digit);
      expect(path.points, isNotEmpty);
    }
  });

  test('early digits use dense smooth reference points', () {
    expect(NumberPathData.getPath(0).points.length, greaterThan(12));
    expect(NumberPathData.getPath(1).points.length, greaterThan(6));
    expect(NumberPathData.getPath(2).points.length, greaterThan(12));
    expect(NumberPathData.getPath(3).points.length, greaterThan(12));
  });

  test('four keeps its two-stroke writing order', () {
    final path = NumberPathData.getPath(4);
    expect(path.strokeBreaks, [9]);
    expect(path.strokeSegments.length, 2);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/models/number_path.dart';
import 'package:arqami/models/units_data.dart';

void main() {
  test('curriculum contains 13 ordered playable units', () {
    expect(UnitsData.units, hasLength(13));

    for (var i = 0; i < UnitsData.units.length; i++) {
      final unit = UnitsData.units[i];
      expect(unit.order, i + 1);
      expect(unit.id, 'unit_${(i + 1).toString().padLeft(2, '0')}');
      expect(unit.activities, isNotEmpty);
      expect(unit.isImplemented, isTrue);
    }
  });

  test('all digit paths 0-9 exist and contain points', () {
    for (var digit = 0; digit <= 9; digit++) {
      expect(NumberPathData.hasPath(digit), isTrue);
      expect(NumberPathData.getPath(digit).points, isNotEmpty);
    }
  });

  test('multi-stroke paths declare their stroke breaks', () {
    final four = NumberPathData.getPath(4);
    expect(four.strokeBreaks, contains(3));
  });
}

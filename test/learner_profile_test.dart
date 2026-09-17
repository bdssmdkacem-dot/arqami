import 'package:flutter_test/flutter_test.dart';

import 'package:arqami/core/profile/learner_profile.dart';

void main() {
  test('maps ages to the four presentation bands', () {
    expect(AgeBand.fromAge(3), AgeBand.early);
    expect(AgeBand.fromAge(5), AgeBand.early);
    expect(AgeBand.fromAge(6), AgeBand.primary);
    expect(AgeBand.fromAge(9), AgeBand.primary);
    expect(AgeBand.fromAge(10), AgeBand.middle);
    expect(AgeBand.fromAge(12), AgeBand.middle);
    expect(AgeBand.fromAge(13), AgeBand.teen);
    expect(AgeBand.fromAge(16), AgeBand.teen);
  });
}

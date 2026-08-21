import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/data/pilot_characters.dart';

void main() {
  test('default roster contains requested playable original pilots', () {
    final playable = pilotCharacters.where((p) => p.availableByDefault).map((p) => p.id).toSet();
    expect(playable, containsAll({'yaalon', 'uzziah', 'nails', 'wild_brats', 'granny', 'george_monkey', 'rose_panther'}));
  });

  test('exact Pink Panther slot remains license gated', () {
    final licensed = pilotById('pink_panther_licensed');
    expect(licensed.availableByDefault, isFalse);
    expect(licensed.licenseNote, isNotEmpty);
  });

  test('every playable pilot has a signature race power', () {
    for (final pilot in pilotCharacters.where((p) => p.availableByDefault)) {
      expect(pilot.callSign, isNotEmpty);
      expect(pilot.personality, isNotEmpty);
    }
  });
}

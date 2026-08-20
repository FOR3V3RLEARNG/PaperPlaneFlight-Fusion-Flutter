import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/features/flight/flight_simulation.dart';

void main() {
  group('FlightSimulation', () {
    test('advances distance and regenerates energy', () {
      final simulation = FlightSimulation(seed: 42);
      final before = simulation.snapshot;

      simulation.tick(1);
      final after = simulation.snapshot;

      expect(after.distanceMeters, greaterThan(before.distanceMeters));
      expect(after.energy, greaterThanOrEqualTo(before.energy));
    });

    test('boost consumes energy and enters boost state', () {
      final simulation = FlightSimulation(seed: 42);
      final energyBefore = simulation.energy;

      final activated = simulation.boost();

      expect(activated, isTrue);
      expect(simulation.boosting, isTrue);
      expect(simulation.energy, lessThan(energyBefore));
    });

    test('steering target remains inside safe playfield', () {
      final simulation = FlightSimulation(seed: 42);

      simulation.steer(-8, 12);

      expect(simulation.targetX, inInclusiveRange(.08, .92));
      expect(simulation.targetY, inInclusiveRange(.52, .88));
    });
  });
}

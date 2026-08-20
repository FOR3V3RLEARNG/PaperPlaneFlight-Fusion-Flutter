import 'dart:math' as math;

class FlightPoint {
  const FlightPoint(this.x, this.y);

  final double x;
  final double y;
}

class FlightObject {
  FlightObject({required this.x, required this.y, required this.kind, this.collected = false});

  double x;
  double y;
  final FlightObjectKind kind;
  bool collected;
}

enum FlightObjectKind { ring, star }

enum FlightEvent { ring, star, boost, perfect }

class FlightSnapshot {
  const FlightSnapshot({
    required this.score,
    required this.distanceMeters,
    required this.energy,
    required this.combo,
    required this.stars,
  });

  final int score;
  final double distanceMeters;
  final double energy;
  final int combo;
  final int stars;
}

class FlightSimulation {
  FlightSimulation({int seed = 7}) : _random = math.Random(seed) {
    for (var i = 0; i < 7; i++) {
      objects.add(_spawnObject(i * .18 - .85, i.isEven ? FlightObjectKind.ring : FlightObjectKind.star));
    }
  }

  final math.Random _random;
  final List<FlightObject> objects = <FlightObject>[];
  final List<FlightPoint> trail = <FlightPoint>[];

  double planeX = .5;
  double planeY = .76;
  double targetX = .5;
  double targetY = .76;
  double elapsed = 0;
  double distanceMeters = 0;
  double energy = 78;
  double boostRemaining = 0;
  int score = 12840;
  int combo = 12;
  int stars = 0;

  bool get boosting => boostRemaining > 0;

  FlightSnapshot get snapshot => FlightSnapshot(
        score: score,
        distanceMeters: distanceMeters,
        energy: energy,
        combo: combo,
        stars: stars,
      );

  void steer(double x, double y) {
    targetX = x.clamp(.08, .92).toDouble();
    targetY = y.clamp(.52, .88).toDouble();
  }

  List<FlightEvent> tick(double dt) {
    final events = <FlightEvent>[];
    elapsed += dt;
    if (boostRemaining > 0) boostRemaining = math.max(0, boostRemaining - dt).toDouble();

    final speed = boosting ? 1.28 : 1.0;
    distanceMeters += (boosting ? 48 : 30) * dt;
    energy = math.min(100, energy + (boosting ? 1.0 : 3.8) * dt).toDouble();

    final smoothing = 1 - math.pow(.0008, dt).toDouble();
    planeX += (targetX - planeX) * smoothing;
    planeY += (targetY - planeY) * smoothing;

    trail.insert(0, FlightPoint(planeX, planeY));
    if (trail.length > 34) trail.removeLast();

    for (final object in objects) {
      object.y += dt * .34 * speed;
      final dx = object.x - planeX;
      final dy = object.y - planeY;
      final distance = math.sqrt(dx * dx + dy * dy);
      if (!object.collected && distance < (object.kind == FlightObjectKind.ring ? .10 : .075)) {
        object.collected = true;
        if (object.kind == FlightObjectKind.ring) {
          combo += 1;
          score += 180 * combo;
          events.add(FlightEvent.ring);
          if (combo % 5 == 0) events.add(FlightEvent.perfect);
        } else {
          stars += 1;
          score += 90;
          energy = math.min(100, energy + 7).toDouble();
          events.add(FlightEvent.star);
        }
      }
      if (object.y > 1.12) {
        final missedRing = object.kind == FlightObjectKind.ring && !object.collected;
        if (missedRing) combo = math.max(1, combo - 2).toInt();
        final replacement = _spawnObject(-.18 - _random.nextDouble() * .45, object.kind);
        object
          ..x = replacement.x
          ..y = replacement.y
          ..collected = false;
      }
    }
    return events;
  }

  bool boost() {
    if (energy < 14 || boosting) return false;
    energy -= 14;
    boostRemaining = 1.8;
    return true;
  }

  FlightObject _spawnObject(double y, FlightObjectKind kind) {
    return FlightObject(
      x: .16 + _random.nextDouble() * .68,
      y: y,
      kind: kind,
    );
  }
}

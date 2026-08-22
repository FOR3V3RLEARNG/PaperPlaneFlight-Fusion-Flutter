import 'dart:math' as math;

class RivalAiDecision {
  const RivalAiDecision({
    required this.targetX,
    required this.targetY,
    required this.boost,
    required this.usePower,
  });
  final double targetX, targetY;
  final bool boost, usePower;
}

class RaceDirector {
  RaceDirector(this.seed) : _rng = math.Random(seed);
  final int seed;
  final math.Random _rng;
  double _decisionTimer = 0;
  double _lane = .65;
  double _height = .50;

  RivalAiDecision update({
    required double dt,
    required double playerProgress,
    required double rivalProgress,
    required bool powerReady,
    required bool boss,
  }) {
    _decisionTimer -= dt;
    var boost = false;
    var power = false;
    if (_decisionTimer <= 0) {
      _decisionTimer = boss ? .58 : .82;
      _lane = .20 + _rng.nextDouble() * .60;
      _height = .36 + _rng.nextDouble() * .28;
      boost =
          rivalProgress < playerProgress - .035 ||
          (_rng.nextDouble() < (boss ? .32 : .18));
      power =
          powerReady &&
          playerProgress > rivalProgress - .06 &&
          _rng.nextDouble() < (boss ? .30 : .16);
    }
    return RivalAiDecision(
      targetX: _lane,
      targetY: _height,
      boost: boost,
      usePower: power,
    );
  }
}

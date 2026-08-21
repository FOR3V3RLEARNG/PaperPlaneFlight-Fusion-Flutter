import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'components/debris.dart';
import 'components/racer_plane.dart';
import 'models/race_models.dart';

class SplitRaceHudState {
  const SplitRaceHudState({
    required this.p1Progress,
    required this.p2Progress,
    required this.p1Integrity,
    required this.p2Integrity,
    required this.p1Wing,
    required this.p2Wing,
    required this.p1Banner,
    required this.p2Banner,
    required this.finished,
    required this.winner,
  });

  final double p1Progress;
  final double p2Progress;
  final double p1Integrity;
  final double p2Integrity;
  final int p1Wing;
  final int p2Wing;
  final String p1Banner;
  final String p2Banner;
  final bool finished;
  final int? winner;
}

class SplitScreenRaceGame extends FlameGame {
  SplitScreenRaceGame({
    required this.playerOneName,
    required this.playerTwoName,
    required this.playerOneCharacterId,
    required this.playerTwoCharacterId,
    required this.worldId,
    required this.playerOneWing,
    required this.playerTwoWing,
    required this.onFinished,
  });

  final String playerOneName;
  final String playerTwoName;
  final String playerOneCharacterId;
  final String playerTwoCharacterId;
  final String worldId;
  final int playerOneWing;
  final int playerTwoWing;
  final void Function(int winner, RaceResult result) onFinished;

  late RacerPlaneComponent playerOne;
  late RacerPlaneComponent playerTwo;
  final inputOne = Vector2.zero();
  final inputTwo = Vector2.zero();
  late final math.Random rng = math.Random(worldId.hashCode + playerOneWing * 31 + playerTwoWing * 17);

  final ValueNotifier<SplitRaceHudState> hud = ValueNotifier(
    const SplitRaceHudState(
      p1Progress: 0,
      p2Progress: 0,
      p1Integrity: 100,
      p2Integrity: 100,
      p1Wing: 1,
      p2Wing: 1,
      p1Banner: 'READY',
      p2Banner: 'READY',
      finished: false,
      winner: null,
    ),
  );

  double elapsed = 0;
  double p1Progress = 0;
  double p2Progress = 0;
  double spawnTimer = .55;
  double p1Slow = 0;
  double p2Slow = 0;
  double p1Distort = 0;
  double p2Distort = 0;
  double p1Boost = 0;
  double p2Boost = 0;
  int p1Score = 0;
  int p2Score = 0;
  bool done = false;
  String p1Banner = 'READY';
  String p2Banner = 'READY';
  double p1BannerTimer = 1.5;
  double p2BannerTimer = 1.5;
  final Map<int, Map<RacePowerType, double>> cooldowns = {
    1: {for (final p in RacePowerType.values) p: 0},
    2: {for (final p in RacePowerType.values) p: 0},
  };

  double get divider => size.x / 2;

  @override
  Color backgroundColor() => const Color(0xFF07549A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    playerOne = RacerPlaneComponent(
      racerName: playerOneName,
      characterId: playerOneCharacterId,
      playerControlled: true,
      wingLevel: playerOneWing,
      position: Vector2(size.x * .25, size.y * .70),
    );
    playerTwo = RacerPlaneComponent(
      racerName: playerTwoName,
      characterId: playerTwoCharacterId,
      playerControlled: false,
      wingLevel: playerTwoWing,
      position: Vector2(size.x * .75, size.y * .70),
    );
    add(playerOne);
    add(playerTwo);
  }

  void setInput(int player, double x, double y) {
    final target = player == 1 ? inputOne : inputTwo;
    target.setValues(x.clamp(-1, 1).toDouble(), y.clamp(-1, 1).toDouble());
  }

  void clearInput(int player) => (player == 1 ? inputOne : inputTwo).setZero();

  @override
  void update(double dt) {
    super.update(dt);
    if (done) return;
    elapsed += dt;
    p1BannerTimer -= dt;
    p2BannerTimer -= dt;
    p1Slow = math.max(0, p1Slow - dt).toDouble();
    p2Slow = math.max(0, p2Slow - dt).toDouble();
    p1Distort = math.max(0, p1Distort - dt).toDouble();
    p2Distort = math.max(0, p2Distort - dt).toDouble();
    p1Boost = math.max(0, p1Boost - dt).toDouble();
    p2Boost = math.max(0, p2Boost - dt).toDouble();
    for (final map in cooldowns.values) {
      for (final key in map.keys.toList()) {
        map[key] = math.max(0, (map[key] ?? 0) - dt).toDouble();
      }
    }

    _updateRacer(
      playerOne,
      inputOne,
      laneMin: 28,
      laneMax: divider - 28,
      dt: dt,
      distorted: p1Distort > 0,
      wing: playerOneWing,
    );
    _updateRacer(
      playerTwo,
      inputTwo,
      laneMin: divider + 28,
      laneMax: size.x - 28,
      dt: dt,
      distorted: p2Distort > 0,
      wing: playerTwoWing,
    );

    final p1Speed = .0110 * (1 + (playerOneWing - 1) * .018) * (p1Slow > 0 ? .68 : 1) * (p1Boost > 0 ? 1.34 : 1);
    final p2Speed = .0110 * (1 + (playerTwoWing - 1) * .018) * (p2Slow > 0 ? .68 : 1) * (p2Boost > 0 ? 1.34 : 1);
    p1Progress = (p1Progress + p1Speed * dt).clamp(0, 1).toDouble();
    p2Progress = (p2Progress + p2Speed * dt).clamp(0, 1).toDouble();

    spawnTimer -= dt;
    if (spawnTimer <= 0) {
      _spawnLaneDebris(1);
      _spawnLaneDebris(2);
      spawnTimer = .55 + rng.nextDouble() * .38;
    }

    for (final child in children.toList()) {
      if (child is DebrisComponent) {
        if (child.y > size.y + 50) {
          child.removeFromParent();
          continue;
        }
        _checkDebris(child);
      }
    }

    if (playerOne.integrity <= 0 && !done) {
      _finish(2, reason: '$playerOneName lost integrity');
    } else if (playerTwo.integrity <= 0 && !done) {
      _finish(1, reason: '$playerTwoName lost integrity');
    } else if (p1Progress >= 1 || p2Progress >= 1) {
      _finish(p1Progress >= p2Progress ? 1 : 2, reason: 'Finish line');
    }

    hud.value = SplitRaceHudState(
      p1Progress: p1Progress,
      p2Progress: p2Progress,
      p1Integrity: playerOne.integrity,
      p2Integrity: playerTwo.integrity,
      p1Wing: playerOneWing,
      p2Wing: playerTwoWing,
      p1Banner: p1BannerTimer > 0 ? p1Banner : '',
      p2Banner: p2BannerTimer > 0 ? p2Banner : '',
      finished: done,
      winner: done ? (p1Progress >= p2Progress ? 1 : 2) : null,
    );
  }

  void _updateRacer(
    RacerPlaneComponent racer,
    Vector2 rawInput, {
    required double laneMin,
    required double laneMax,
    required double dt,
    required bool distorted,
    required int wing,
  }) {
    final control = 1 + (wing - 1) * .022;
    final ix = distorted ? -rawInput.x * .82 : rawInput.x;
    final iy = distorted ? rawInput.y * .55 + math.sin(elapsed * 7) * .35 : rawInput.y;
    racer.velocity.x += ix * 700 * control * dt;
    racer.velocity.y += iy * 520 * control * dt;
    racer.velocity *= math.max(0, 1 - dt * 4.6).toDouble();
    racer.position += racer.velocity * dt;
    racer.x = racer.x.clamp(laneMin, laneMax).toDouble();
    racer.y = racer.y.clamp(size.y * .20, size.y * .86).toDouble();
    racer.angle += (racer.velocity.x / 180 * .48 - racer.angle) * math.min(1, dt * 7).toDouble();
  }

  void _spawnLaneDebris(int lane) {
    final minX = lane == 1 ? 30.0 : divider + 30;
    final maxX = lane == 1 ? divider - 30 : size.x - 30;
    final kinds = worldId == 'cosmic'
        ? ['asteroid', 'asteroid', 'scrap']
        : worldId == 'sky_islands'
            ? ['leaf', 'kite', 'scrap']
            : ['kite', 'scrap', 'leaf', 'asteroid'];
    add(
      DebrisComponent(
        position: Vector2(minX + rng.nextDouble() * math.max(1, maxX - minX), -30),
        kind: kinds[rng.nextInt(kinds.length)],
        drift: 14 + rng.nextDouble() * 32,
      ),
    );
  }

  void _checkDebris(DebrisComponent debris) {
    for (final entry in [(1, playerOne), (2, playerTwo)]) {
      final lane = entry.$1;
      final racer = entry.$2;
      final sameLane = lane == 1 ? debris.x < divider : debris.x >= divider;
      if (!sameLane) continue;
      final distance = (racer.position - debris.position).length;
      if (distance < 30) {
        debris.removeFromParent();
        racer.integrity = (racer.integrity - 13).clamp(0, 100).toDouble();
        racer.react(PilotMood.shocked);
        _banner(lane, 'DEBRIS HIT');
        break;
      }
      if (distance < 54 && debris.y > racer.y) {
        _banner(lane, 'CLOSE CALL +45');
        if (lane == 1) {
          p1Score += 45;
        } else {
          p2Score += 45;
        }
        racer.react(PilotMood.laughing);
      }
    }
  }

  void boost(int player) {
    if (player == 1) {
      p1Boost = 1.05;
      playerOne.boost = 1.05;
      playerOne.react(PilotMood.fistPump);
    } else {
      p2Boost = 1.05;
      playerTwo.boost = 1.05;
      playerTwo.react(PilotMood.fistPump);
    }
    _banner(player, 'TURBO!');
  }

  void usePower(int player, RacePowerType type) {
    final map = cooldowns[player]!;
    if ((map[type] ?? 0) > 0) return;
    map[type] = 3.2;
    final target = player == 1 ? playerTwo : playerOne;
    switch (type) {
      case RacePowerType.fireBurst:
        target.integrity = (target.integrity - 14).clamp(0, 100).toDouble();
        target.react(PilotMood.frustrated);
        _banner(player, 'FIRE HIT');
        _banner(player == 1 ? 2 : 1, 'SCORCHED!');
        break;
      case RacePowerType.distortionPulse:
        if (player == 1) {
          p2Distort = 2.2;
        } else {
          p1Distort = 2.2;
        }
        target.react(PilotMood.shocked);
        _banner(player, 'DISTORT');
        _banner(player == 1 ? 2 : 1, 'CONTROLS WARPED');
        break;
      case RacePowerType.slowWindField:
        if (player == 1) {
          p2Slow = 2.8;
        } else {
          p1Slow = 2.8;
        }
        target.react(PilotMood.frustrated);
        _banner(player, 'SLOW FIELD');
        _banner(player == 1 ? 2 : 1, 'HEADWIND!');
        break;
    }
  }

  void _banner(int player, String value) {
    if (player == 1) {
      p1Banner = value;
      p1BannerTimer = 1.4;
    } else {
      p2Banner = value;
      p2BannerTimer = 1.4;
    }
  }

  void _finish(int winner, {required String reason}) {
    if (done) return;
    done = true;
    final winnerPlane = winner == 1 ? playerOne : playerTwo;
    final loserPlane = winner == 1 ? playerTwo : playerOne;
    winnerPlane.react(PilotMood.celebrating);
    loserPlane.react(PilotMood.frustrated);
    _banner(winner, 'WINNER!');
    _banner(winner == 1 ? 2 : 1, 'RACE COMPLETE');
    pauseEngine();
    final result = RaceResult(
      playerWon: winner == 1,
      playerTime: elapsed,
      rivalTime: elapsed,
      score: (winner == 1 ? p1Score : p2Score) + 800,
      tokens: 0,
      worldId: worldId,
      bossRace: false,
    );
    Future<void>.delayed(const Duration(milliseconds: 700), () => onFinished(winner, result));
  }

  @override
  void render(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07549A), Color(0xFF46B9E5), Color(0xFFC8F7FF)],
        ).createShader(rect),
    );

    for (var i = 0; i < 10; i++) {
      final y = ((elapsed * 95 + i * 122) % (size.y + 180)) - 90;
      final alpha = i.isEven ? .07 : .11;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset((i * 113) % math.max(1, size.x.toInt()).toDouble(), y),
          width: 115 + (i % 3) * 28,
          height: 42 + (i % 2) * 18,
        ),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha),
      );
    }

    // Split-screen identity: two independent lanes share one deterministic race clock.
    canvas.drawRect(
      Rect.fromLTWH(divider - 2, 0, 4, size.y),
      Paint()..color = const Color(0xDD001A31),
    );
    canvas.drawLine(
      Offset(divider, 0),
      Offset(divider, size.y),
      Paint()
        ..color = const Color(0xFF75ECFF).withValues(alpha: .55)
        ..strokeWidth = 1.2,
    );

    super.render(canvas);
  }

  @override
  void onDispose() {
    hud.dispose();
    super.onDispose();
  }
}

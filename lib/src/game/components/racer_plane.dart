import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../data/pilot_characters.dart';
import '../models/race_models.dart';
import 'pilot_rider.dart';

class RacerPlaneComponent extends PositionComponent {
  RacerPlaneComponent({
    required this.racerName,
    required this.characterId,
    required this.playerControlled,
    required this.wingLevel,
    required super.position,
  }) : super(size: Vector2(78, 52), anchor: Anchor.center, priority: 30);

  final String racerName;
  final String characterId;
  final bool playerControlled;
  int wingLevel;
  final Vector2 velocity = Vector2.zero();
  double integrity = 100;
  double distortion = 0;
  double slow = 0;
  double boost = 0;
  double targetX = .5;
  double targetY = .65;
  late final PilotRiderComponent pilot;
  late final PilotCharacterDefinition character;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    character = pilotById(characterId);
    pilot = PilotRiderComponent(
      character: character,
      player: playerControlled,
      position: Vector2(size.x * .51, size.y * .38),
    );
    add(pilot);
  }

  @override
  void update(double dt) {
    super.update(dt);
    distortion = math.max(0, distortion - dt).toDouble();
    slow = math.max(0, slow - dt).toDouble();
    boost = math.max(0, boost - dt).toDouble();
  }

  void react(PilotMood mood) => pilot.mood = mood;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final tier = wingLevel <= 2 ? 0 : wingLevel <= 4 ? 1 : wingLevel <= 6 ? 2 : wingLevel <= 8 ? 3 : wingLevel == 9 ? 4 : 5;
    final main = playerControlled ? const Color(0xFFF7FBFF) : const Color(0xFFF2F4FF);
    final tierAccent = [
      character.primary,
      character.secondary,
      const Color(0xFFFFB347),
      const Color(0xFF3DDC84),
      const Color(0xFFFF5E8A),
      const Color(0xFFFFFFFF),
    ][tier];
    final path = Path()
      ..moveTo(2, size.y * .50)
      ..lineTo(size.x - 2, size.y * .12)
      ..lineTo(size.x * .60, size.y * .82)
      ..lineTo(size.x * .48, size.y * .60)
      ..lineTo(size.x * .17, size.y * .73)
      ..close();
    canvas.drawPath(path, Paint()..color = main);
    final fold = Path()
      ..moveTo(size.x * .34, size.y * .49)
      ..lineTo(size.x - 2, size.y * .12)
      ..lineTo(size.x * .49, size.y * .58)
      ..close();
    canvas.drawPath(fold, Paint()..color = tierAccent.withValues(alpha: .76));

    if (tier >= 2) {
      canvas.drawLine(Offset(9, size.y * .65), Offset(size.x * .38, size.y * .54), Paint()..color = tierAccent..strokeWidth = 2);
    }
    if (tier >= 4) canvas.drawCircle(Offset(size.x * .54, size.y * .48), 4, Paint()..color = tierAccent);
    if (tier >= 5) {
      canvas.drawLine(Offset(size.x * .18, size.y * .69), Offset(size.x * .04, size.y * .85), Paint()..color = character.secondary.withValues(alpha: .85)..strokeWidth = 2.4);
      canvas.drawLine(Offset(size.x * .58, size.y * .72), Offset(size.x * .71, size.y * .88), Paint()..color = character.secondary.withValues(alpha: .85)..strokeWidth = 2.4);
    }
    if (boost > 0) {
      canvas.drawLine(
        Offset(7, size.y * .55),
        Offset(-18, size.y * .62),
        Paint()
          ..shader = LinearGradient(colors: [tierAccent, const Color(0x0000E5FF)]).createShader(const Rect.fromLTWH(-20, 0, 30, 50))
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
    if (integrity < 55) canvas.drawLine(Offset(18, 24), Offset(29, 36), Paint()..color = const Color(0xFF55382F)..strokeWidth = 2);
  }
}

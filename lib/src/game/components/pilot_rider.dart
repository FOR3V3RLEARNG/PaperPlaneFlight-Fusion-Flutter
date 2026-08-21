import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../data/pilot_characters.dart';
import '../models/race_models.dart';

class PilotRiderComponent extends PositionComponent {
  PilotRiderComponent({
    required this.character,
    required this.player,
    required super.position,
  }) : super(size: Vector2(32, 38), anchor: Anchor.bottomCenter, priority: 40);

  final PilotCharacterDefinition character;
  final bool player;
  PilotMood mood = PilotMood.focused;
  double phase = 0;

  @override
  void update(double dt) {
    super.update(dt);
    phase += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final excited = mood == PilotMood.laughing || mood == PilotMood.fistPump || mood == PilotMood.celebrating;
    final bounce = math.sin(phase * (excited ? 9 : 6)) * (excited ? 2.4 : .7);
    canvas.save();
    canvas.translate(0, bounce);

    switch (character.species) {
      case PilotSpecies.human:
        _renderHuman(canvas);
        break;
      case PilotSpecies.pinkCat:
        _renderPinkCat(canvas);
        break;
      case PilotSpecies.monkey:
        _renderMonkey(canvas);
        break;
      case PilotSpecies.duo:
        _renderDuo(canvas);
        break;
    }
    _renderExpression(canvas, const Offset(16, 9));
    _renderArms(canvas);
    canvas.restore();
  }

  void _renderHuman(Canvas c) {
    c.drawCircle(const Offset(16, 9), 6.2, Paint()..color = character.skin);
    final hair = Paint()..color = character.hair;
    if (character.id == 'granny') {
      c.drawCircle(const Offset(16, 3), 4.2, hair);
      c.drawArc(const Rect.fromLTWH(10, 2, 12, 12), 3.2, 2.7, true, hair);
    } else {
      c.drawArc(const Rect.fromLTWH(9.5, 1.5, 13, 13), 3.15, 3.05, true, hair);
    }
    _renderBody(c, x: 10, width: 12);
    if (character.id == 'yaalon') {
      c.drawLine(const Offset(20, 18), const Offset(27, 22), Paint()..strokeWidth = 2.2..color = character.secondary);
    }
  }

  void _renderPinkCat(Canvas c) {
    final earPath = Path()
      ..moveTo(10, 6)
      ..lineTo(11, -1)
      ..lineTo(15, 5)
      ..moveTo(18, 5)
      ..lineTo(22, -1)
      ..lineTo(23, 7);
    c.drawPath(earPath, Paint()..style = PaintingStyle.fill..color = character.primary);
    c.drawCircle(const Offset(16, 9), 7, Paint()..color = character.skin);
    _renderBody(c, x: 9, width: 14);
    final tail = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round..color = character.primary;
    c.drawArc(const Rect.fromLTWH(21, 18, 10, 13), -.9, 3.2, false, tail);
  }

  void _renderMonkey(Canvas c) {
    c.drawCircle(const Offset(9.5, 8.5), 3.8, Paint()..color = character.primary);
    c.drawCircle(const Offset(22.5, 8.5), 3.8, Paint()..color = character.primary);
    c.drawCircle(const Offset(16, 9), 7, Paint()..color = character.primary);
    c.drawOval(const Rect.fromLTWH(11, 8, 10, 8), Paint()..color = character.skin);
    _renderBody(c, x: 9, width: 14);
    c.drawLine(const Offset(10, 19), const Offset(3, 24), Paint()..strokeWidth = 2.3..color = character.secondary);
  }

  void _renderDuo(Canvas c) {
    c.drawCircle(const Offset(11.5, 9), 5.5, Paint()..color = character.skin);
    c.drawCircle(const Offset(20.5, 8), 5.5, Paint()..color = character.skin.withValues(alpha: .98));
    c.drawArc(const Rect.fromLTWH(6, 1.5, 11, 11), 3.2, 2.8, true, Paint()..color = character.hair);
    c.drawArc(const Rect.fromLTWH(15, .5, 11, 11), 3.2, 2.8, true, Paint()..color = character.secondary);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(7, 15, 18, 14), const Radius.circular(5)), Paint()..color = character.primary);
  }

  void _renderBody(Canvas c, {required double x, required double width}) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, 15, width, 14), const Radius.circular(5)),
      Paint()..color = character.primary,
    );
    c.drawRect(const Rect.fromLTWH(14.5, 16, 3, 12), Paint()..color = character.secondary.withValues(alpha: .72));
  }

  void _renderExpression(Canvas c, Offset center) {
    final ink = Paint()..color = const Color(0xFF132337);
    if (character.species == PilotSpecies.duo) return;
    if (mood == PilotMood.shocked) {
      c.drawCircle(center.translate(-2.2, -1.3), .9, ink);
      c.drawCircle(center.translate(2.2, -1.3), .9, ink);
      c.drawCircle(center.translate(0, 2.4), 1.35, ink);
      return;
    }
    if (mood == PilotMood.frustrated) {
      c.drawLine(center.translate(-4, -2), center.translate(-1, -1), ink..strokeWidth = 1.2);
      c.drawLine(center.translate(1, -1), center.translate(4, -2), ink..strokeWidth = 1.2);
    } else {
      c.drawCircle(center.translate(-2.1, -1.4), .8, ink);
      c.drawCircle(center.translate(2.1, -1.4), .8, ink);
    }
    final smile = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..strokeCap = StrokeCap.round..color = const Color(0xFF132337);
    final sweep = mood == PilotMood.laughing || mood == PilotMood.celebrating ? 2.7 : 2.0;
    c.drawArc(Rect.fromCenter(center: center.translate(0, .8), width: 7, height: 5), .25, sweep, false, smile);
  }

  void _renderArms(Canvas c) {
    final arm = Paint()..strokeWidth = 2.5..strokeCap = StrokeCap.round..color = character.skin;
    if (mood == PilotMood.fistPump || mood == PilotMood.celebrating) {
      c.drawLine(const Offset(11, 18), const Offset(5, 6), arm);
      c.drawLine(const Offset(21, 18), const Offset(27, 5), arm);
    } else if (mood == PilotMood.ducking) {
      c.drawLine(const Offset(10, 18), const Offset(7, 20), arm);
      c.drawLine(const Offset(22, 18), const Offset(25, 20), arm);
    } else {
      c.drawLine(const Offset(10, 18), const Offset(5, 25), arm);
      c.drawLine(const Offset(22, 18), const Offset(27, 25), arm);
    }
  }
}

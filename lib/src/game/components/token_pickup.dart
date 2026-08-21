import 'dart:ui';

import 'package:flame/components.dart';

/// A collectible currency token that drifts down the race lane.
/// Colliding with the player awards a token via [RivalRaceGame.collectToken].
class TokenPickupComponent extends PositionComponent {
  TokenPickupComponent({required super.position})
      : super(size: Vector2.all(22), anchor: Anchor.center, priority: 20);

  double phase = 0;

  @override
  void update(double dt) {
    super.update(dt);
    phase += dt;
    y += 120 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final r = size.x / 2;
    final center = Offset(r, r);
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFFFD24D));
    canvas.drawCircle(center, r * .62, Paint()..color = const Color(0xFFFFF3C4));
    canvas.drawCircle(center, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFB4831A));
  }
}

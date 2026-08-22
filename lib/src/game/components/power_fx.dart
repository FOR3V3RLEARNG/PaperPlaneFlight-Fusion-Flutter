import 'dart:ui';
import 'package:flame/components.dart';
import '../models/race_models.dart';

class PowerProjectile extends PositionComponent {
  PowerProjectile({
    required super.position,
    required this.type,
    required this.fromPlayer,
  }) : super(size: Vector2.all(28), anchor: Anchor.center, priority: 50);
  final RacePowerType type;
  final bool fromPlayer;
  @override
  void update(double dt) {
    super.update(dt);
    y += (fromPlayer ? -360 : 360) * dt;
    if (y < -60 || y > 1400) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final color = switch (type) {
      RacePowerType.fireBurst => const Color(0xFFFF6D3A),
      RacePowerType.distortionPulse => const Color(0xFF9A66FF),
      RacePowerType.slowWindField => const Color(0xFF5DEBFF),
    };
    if (type == RacePowerType.fireBurst) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        11,
        Paint()..color = color,
      );
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        16,
        Paint()..color = color.withValues(alpha: .25),
      );
    } else {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        12,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = color,
      );
    }
  }
}

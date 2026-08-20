import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import 'flight_simulation.dart';

class FlightScene extends StatefulWidget {
  const FlightScene({required this.onSnapshot, super.key});

  final ValueChanged<FlightSnapshot> onSnapshot;

  @override
  State<FlightScene> createState() => FlightSceneState();
}

class FlightSceneState extends State<FlightScene> with SingleTickerProviderStateMixin {
  late final FlightSimulation simulation;
  late final Ticker _ticker;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  Duration? _lastElapsed;
  double _snapshotAccumulator = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    simulation = FlightSimulation();
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSnapshot(simulation.snapshot));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void togglePause() {
    setState(() => _paused = !_paused);
    HapticFeedback.selectionClick();
  }

  void boost() {
    if (simulation.boost()) {
      HapticFeedback.mediumImpact();
      widget.onSnapshot(simulation.snapshot);
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _onTick(Duration elapsed) {
    final previous = _lastElapsed;
    _lastElapsed = elapsed;
    if (previous == null || _paused) return;
    final rawDt = (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond;
    final dt = rawDt.clamp(0.0, .05).toDouble();
    final events = simulation.tick(dt);
    for (final event in events) {
      switch (event) {
        case FlightEvent.ring:
          HapticFeedback.lightImpact();
          break;
        case FlightEvent.star:
          HapticFeedback.selectionClick();
          break;
        case FlightEvent.perfect:
          HapticFeedback.mediumImpact();
          break;
        case FlightEvent.boost:
          HapticFeedback.mediumImpact();
          break;
      }
    }
    _snapshotAccumulator += dt;
    if (_snapshotAccumulator >= .18) {
      _snapshotAccumulator = 0;
      widget.onSnapshot(simulation.snapshot);
    }
    _repaint.value++;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Semantics(
      label: 'Flight playfield. Swipe or drag to steer the paper plane through rings and stars.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (DragDownDetails details) => _steer(details.localPosition),
        onPanUpdate: (DragUpdateDetails details) => _steer(details.localPosition),
        onTapDown: (TapDownDetails details) => _steer(details.localPosition),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return CustomPaint(
              painter: _FlightScenePainter(
                simulation: simulation,
                repaint: _repaint,
                reduceMotion: reduceMotion,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }

  void _steer(Offset point) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    simulation.steer(point.dx / box.size.width, point.dy / box.size.height);
  }
}

class _FlightScenePainter extends CustomPainter {
  _FlightScenePainter({required this.simulation, required Listenable repaint, required this.reduceMotion})
      : super(repaint: repaint);

  final FlightSimulation simulation;
  final bool reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawClouds(canvas, size);
    _drawIslands(canvas, size);
    _drawObjects(canvas, size);
    _drawTrail(canvas, size);
    _drawPlane(canvas, size);
    if (simulation.boosting && !reduceMotion) _drawBoostBloom(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width * .5, 0),
          Offset(size.width * .5, size.height),
          const <Color>[Color(0xFF061C48), Color(0xFF0E69B4), Color(0xFF5EC8F3), Color(0xFFD6F2FF)],
          const <double>[0, .46, .78, 1],
        ),
    );
    final sun = Offset(size.width * .78, size.height * .16);
    canvas.drawCircle(
      sun,
      size.shortestSide * .07,
      Paint()
        ..color = const Color(0xFFFFD27A).withValues(alpha: .9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    for (var i = 0; i < 10; i++) {
      final phase = (simulation.elapsed * (.018 + i * .0015) + i * .129) % 1.2;
      final x = size.width * (phase - .10);
      final y = size.height * (.10 + (i % 5) * .16);
      final r = size.shortestSide * (.035 + (i % 3) * .018);
      final paint = Paint()..color = Colors.white.withValues(alpha: .10 + (i % 3) * .035);
      canvas.drawCircle(Offset(x, y), r, paint);
      canvas.drawCircle(Offset(x + r * .9, y + r * .08), r * .72, paint);
      canvas.drawCircle(Offset(x - r * .65, y + r * .16), r * .60, paint);
    }
  }

  void _drawIslands(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final x = size.width * (.08 + i * .28);
      final y = size.height * (.26 + (i % 2) * .22);
      final w = size.width * .16;
      final h = size.height * .09;
      final top = Path()
        ..moveTo(x - w * .5, y)
        ..quadraticBezierTo(x, y - h * .65, x + w * .5, y)
        ..quadraticBezierTo(x, y + h * .25, x - w * .5, y)
        ..close();
      canvas.drawPath(top, Paint()..color = const Color(0xFF4C8E74).withValues(alpha: .72));
      final rock = Path()
        ..moveTo(x - w * .34, y + h * .08)
        ..lineTo(x, y + h * 1.35)
        ..lineTo(x + w * .32, y + h * .08)
        ..close();
      canvas.drawPath(rock, Paint()..color = const Color(0xFF32526D).withValues(alpha: .55));
    }
  }

  void _drawObjects(Canvas canvas, Size size) {
    for (final object in simulation.objects) {
      if (object.collected) continue;
      final center = Offset(object.x * size.width, object.y * size.height);
      final perspective = .55 + object.y.clamp(0.0, 1.0).toDouble() * .55;
      if (object.kind == FlightObjectKind.ring) {
        final radius = size.shortestSide * .055 * perspective;
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9 * perspective
          ..color = FlightColors.sunOrange.withValues(alpha: .18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
        canvas.drawCircle(center, radius, glow);
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.6 * perspective
            ..color = FlightColors.sunOrange,
        );
      } else {
        _drawStar(canvas, center, size.shortestSide * .028 * perspective);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * .44;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(center.dx + math.cos(angle) * r, center.dy + math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = FlightColors.sunOrange
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
    );
  }

  void _drawTrail(Canvas canvas, Size size) {
    if (simulation.trail.length < 2) return;
    for (var pass = 0; pass < 3; pass++) {
      final path = Path();
      for (var i = 0; i < simulation.trail.length; i++) {
        final point = simulation.trail[i];
        final x = point.x * size.width + (pass - 1) * 7;
        final y = point.y * size.height + i * 3.8;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      final colors = <Color>[FlightColors.skyBlue, FlightColors.aeroCyan, FlightColors.violet];
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = simulation.boosting ? 6 : 3.5
          ..color = colors[pass].withValues(alpha: .58)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, simulation.boosting ? 7 : 4),
      );
    }
  }

  void _drawPlane(Canvas canvas, Size size) {
    final center = Offset(simulation.planeX * size.width, simulation.planeY * size.height);
    final s = size.shortestSide * .105;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    final tilt = (simulation.targetX - simulation.planeX) * .8;
    canvas.rotate(tilt.clamp(-.22, .22).toDouble());

    final plane = Path()
      ..moveTo(-s * .68, 0)
      ..lineTo(s * .72, -s * .38)
      ..lineTo(s * .18, s * .44)
      ..lineTo(-s * .08, s * .12)
      ..close();
    canvas.drawShadow(plane, Colors.black.withValues(alpha: .45), 14, true);
    canvas.drawPath(
      plane,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(-s, -s),
          Offset(s, s),
          const <Color>[
            Colors.white,
            Color(0xFFE6F3FF),
            FlightColors.violet,
          ],
          const <double>[0, .62, 1],
        ),
    );
    final fold = Path()
      ..moveTo(-s * .68, 0)
      ..lineTo(s * .72, -s * .38)
      ..lineTo(-s * .08, s * .12)
      ..close();
    canvas.drawPath(fold, Paint()..color = FlightColors.skyBlue.withValues(alpha: .55));
    canvas.restore();
  }

  void _drawBoostBloom(Canvas canvas, Size size) {
    final center = Offset(simulation.planeX * size.width, simulation.planeY * size.height + size.shortestSide * .11);
    canvas.drawCircle(
      center,
      size.shortestSide * .11,
      Paint()
        ..color = FlightColors.aeroCyan.withValues(alpha: .15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
  }

  @override
  bool shouldRepaint(covariant _FlightScenePainter oldDelegate) => true;
}

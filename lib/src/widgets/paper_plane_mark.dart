import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

class PaperPlaneMark extends StatelessWidget {
  const PaperPlaneMark({this.size = 96, this.glow = true, super.key});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Paper Plane Flight logo',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _PaperPlaneMarkPainter(glow: glow)),
      ),
    );
  }
}

class _PaperPlaneMarkPainter extends CustomPainter {
  const _PaperPlaneMarkPainter({required this.glow});

  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .5);
    if (glow) {
      final glowPaint = Paint()
        ..color = FlightColors.skyBlue.withValues(alpha: .22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(center, size.shortestSide * .38, glowPaint);
    }

    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.shortestSide * .022).toDouble()
      ..shader = const LinearGradient(
        colors: <Color>[FlightColors.sunOrange, FlightColors.aeroCyan, FlightColors.violet],
      ).createShader(Offset.zero & size);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: size.width * .82, height: size.height * .42),
      orbit,
    );

    final plane = Path()
      ..moveTo(size.width * .16, size.height * .50)
      ..lineTo(size.width * .86, size.height * .20)
      ..lineTo(size.width * .60, size.height * .80)
      ..lineTo(size.width * .48, size.height * .57)
      ..close();
    canvas.drawPath(
      plane,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Colors.white, FlightColors.cloudWhite, FlightColors.violet],
        ).createShader(Offset.zero & size),
    );

    final fold = Path()
      ..moveTo(size.width * .16, size.height * .50)
      ..lineTo(size.width * .86, size.height * .20)
      ..lineTo(size.width * .48, size.height * .57)
      ..close();
    canvas.drawPath(fold, Paint()..color = FlightColors.skyBlue.withValues(alpha: .52));
  }

  @override
  bool shouldRepaint(covariant _PaperPlaneMarkPainter oldDelegate) => oldDelegate.glow != glow;
}

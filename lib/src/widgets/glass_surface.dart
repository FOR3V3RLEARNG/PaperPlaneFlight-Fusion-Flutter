import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.highlight = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                (highlight ? FlightColors.glassHigh : FlightColors.glass).withValues(alpha: .92),
                FlightColors.nightBlue.withValues(alpha: .78),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: highlight ? const Color(0x663DB8FF) : const Color(0x333DB8FF),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

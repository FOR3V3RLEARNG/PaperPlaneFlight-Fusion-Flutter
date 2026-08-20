import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import 'glass_surface.dart';

class MorphingMetric extends StatefulWidget {
  const MorphingMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
    required this.details,
    this.icon = Icons.bolt_rounded,
    super.key,
  });

  final String label;
  final String value;
  final String unit;
  final Color accent;
  final IconData icon;
  final List<String> details;

  @override
  State<MorphingMetric> createState() => _MorphingMetricState();
}

class _MorphingMetricState extends State<MorphingMetric> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: _expanded,
      label: '${widget.label}, ${widget.value} ${widget.unit}. Tap for details.',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _expanded = !_expanded);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(minWidth: _expanded ? 250 : 150),
          child: GlassSurface(
            highlight: _expanded,
            padding: EdgeInsets.all(_expanded ? 20 : 14),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: _expanded ? _expandedContent(context) : _pillContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pillContent(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: widget.accent.withValues(alpha: .16), shape: BoxShape.circle),
          child: Icon(widget.icon, color: widget.accent, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(widget.value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(widget.unit, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _expandedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(widget.icon, color: widget.accent),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.label, style: Theme.of(context).textTheme.titleMedium)),
            const Icon(Icons.expand_less_rounded),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 620, end: 800),
              duration: const Duration(milliseconds: 320),
              builder: (BuildContext context, double weight, Widget? child) {
                return Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: 36,
                    color: FlightColors.cloudWhite,
                    fontVariations: <FontVariation>[FontVariation('wght', weight)],
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(widget.unit, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...widget.details.map(
          (String detail) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: <Widget>[
                Icon(Icons.auto_awesome_rounded, size: 14, color: widget.accent),
                const SizedBox(width: 7),
                Expanded(child: Text(detail, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../widgets/glass_surface.dart';
import '../../widgets/morphing_metric.dart';
import '../../widgets/paper_plane_mark.dart';

class HangarPage extends StatefulWidget {
  const HangarPage({super.key});

  @override
  State<HangarPage> createState() => _HangarPageState();
}

class _HangarPageState extends State<HangarPage> {
  int _selected = 1;

  static const planes = <(String, String, Color)>[
    ('Classic', 'Common', FlightColors.cloudWhite),
    ('Aegis Prime', 'Legendary', FlightColors.skyBlue),
    ('Cloud Glider', 'Epic', FlightColors.violet),
    ('Phoenix Fold', 'Legendary', FlightColors.sunOrange),
  ];

  @override
  Widget build(BuildContext context) {
    final plane = planes[_selected];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 120),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('HANGAR', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text('Your plane is a workspace, not a settings list. Tune identity and performance in one place.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: FlightColors.muted)),
              const SizedBox(height: 18),
              GlassSurface(
                highlight: true,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final wide = constraints.maxWidth >= 760;
                    final visual = Container(
                      constraints: const BoxConstraints(minHeight: 280),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: <Color>[plane.$3.withValues(alpha: .25), Colors.transparent],
                        ),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 360),
                          switchInCurve: Curves.easeOutCubic,
                          child: PaperPlaneMark(key: ValueKey<int>(_selected), size: wide ? 220 : 170),
                        ),
                      ),
                    );
                    final stats = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(plane.$1, style: Theme.of(context).textTheme.headlineLarge),
                        Text(plane.$2.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: plane.$3, letterSpacing: 1.3)),
                        const SizedBox(height: 18),
                        _PerformanceBar(label: 'Speed', value: _selected == 1 ? .92 : .82, color: FlightColors.leafGreen),
                        _PerformanceBar(label: 'Glide', value: .88, color: FlightColors.aeroCyan),
                        _PerformanceBar(label: 'Control', value: .91, color: FlightColors.skyBlue),
                        _PerformanceBar(label: 'Boost', value: .85, color: FlightColors.sunOrange),
                        const SizedBox(height: 16),
                        FilledButton.icon(onPressed: () => HapticFeedback.mediumImpact(), icon: const Icon(Icons.tune_rounded), label: const Text('Tune plane')),
                      ],
                    );
                    return wide
                        ? Row(children: <Widget>[Expanded(child: visual), const SizedBox(width: 26), Expanded(child: stats)])
                        : Column(children: <Widget>[visual, stats]);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _PlanePicker(selected: _selected, onSelected: (int index) => setState(() => _selected = index)),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  MorphingMetric(label: 'Speed', value: '92', unit: '/100', accent: FlightColors.leafGreen, details: <String>['Cruise 31 m/s', 'Boost peak 48 m/s', 'Acceleration +8%']),
                  MorphingMetric(label: 'Control', value: '91', unit: '/100', accent: FlightColors.skyBlue, details: <String>['Turn response 94%', 'Wind stability 89%', 'Magnet assist 72%']),
                  MorphingMetric(label: 'Glide', value: '88', unit: '/100', accent: FlightColors.violet, details: <String>['Lift efficiency 90%', 'Energy decay -7%', 'Stall tolerance high']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerformanceBar extends StatelessWidget {
  const _PerformanceBar({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          SizedBox(width: 72, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: value, minHeight: 8, color: color, backgroundColor: FlightColors.nightBlue),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 34, child: Text('${(value * 100).round()}')),
        ],
      ),
    );
  }
}

class _PlanePicker extends StatelessWidget {
  const _PlanePicker({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _HangarPageState.planes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final item = _HangarPageState.planes[index];
          final active = index == selected;
          return Semantics(
            button: true,
            selected: active,
            label: '${item.$1}, ${item.$2}',
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: active ? 178 : 142,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active ? item.$3.withValues(alpha: .14) : FlightColors.glass,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: active ? item.$3 : const Color(0x333DB8FF)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.send_rounded, color: item.$3, size: active ? 38 : 30),
                    const SizedBox(height: 8),
                    Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(item.$2, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

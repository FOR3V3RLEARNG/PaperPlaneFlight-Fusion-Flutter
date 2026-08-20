import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/theme.dart';
import '../../widgets/glass_surface.dart';

class Mission {
  const Mission({required this.title, required this.subtitle, required this.progress, required this.reward, required this.icon});

  final String title;
  final String subtitle;
  final double progress;
  final String reward;
  final IconData icon;
}

final missionsProvider = FutureProvider<List<Mission>>((_) async {
  await Future<void>.delayed(const Duration(milliseconds: 380));
  return const <Mission>[
    Mission(title: 'Ring Runner', subtitle: 'Fly through 25 rings', progress: .72, reward: '350 XP • 50 stars', icon: Icons.circle_outlined),
    Mission(title: 'Star Collector', subtitle: 'Collect 150 stars', progress: .69, reward: '250 XP • 40 stars', icon: Icons.star_outline_rounded),
    Mission(title: 'Perfect Line', subtitle: 'Complete one perfect run', progress: .0, reward: '500 XP • 80 stars', icon: Icons.auto_awesome_rounded),
    Mission(title: 'Boost Discipline', subtitle: 'Use boost 20 times', progress: .60, reward: '200 XP • 1 core', icon: Icons.bolt_outlined),
  ];
});

class MissionsPage extends ConsumerWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider);
    final data = missions.asData?.value ?? const <Mission>[
      Mission(title: 'Ring Runner', subtitle: 'Loading mission', progress: .5, reward: '---', icon: Icons.circle_outlined),
      Mission(title: 'Star Collector', subtitle: 'Loading mission', progress: .4, reward: '---', icon: Icons.star_outline_rounded),
      Mission(title: 'Perfect Line', subtitle: 'Loading mission', progress: .2, reward: '---', icon: Icons.auto_awesome_rounded),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 120),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('MISSIONS', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text('Progress is navigable: the compact mission ring unfolds into a timeline you can inspect and scrub.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: FlightColors.muted)),
              const SizedBox(height: 18),
              const _MorphingMissionProgress(),
              const SizedBox(height: 18),
              Skeletonizer(
                enabled: missions.isLoading,
                child: Column(
                  children: <Widget>[
                    for (final mission in data) ...<Widget>[
                      _MissionCard(mission: mission),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              if (missions.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () => ref.invalidate(missionsProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry missions'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MorphingMissionProgress extends StatefulWidget {
  const _MorphingMissionProgress();

  @override
  State<_MorphingMissionProgress> createState() => _MorphingMissionProgressState();
}

class _MorphingMissionProgressState extends State<_MorphingMissionProgress> {
  bool _expanded = false;
  double _timeline = .72;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: _expanded,
      label: 'Sky Explorer progress, 72 percent. Tap to ${_expanded ? 'collapse' : 'open interactive timeline'}.',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _expanded = !_expanded);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          child: GlassSurface(
            highlight: _expanded,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 340),
              curve: Curves.easeOutCubic,
              child: _expanded ? _timelineContent(context) : _compactContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _compactContent(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 74,
          height: 74,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              const CircularProgressIndicator(value: .72, strokeWidth: 7, color: FlightColors.aeroCyan, backgroundColor: FlightColors.nightBlue),
              Text('72%', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Sky Explorer', style: Theme.of(context).textTheme.titleLarge),
              Text('9 of 12 missions • Cloud Runner unlock', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const Icon(Icons.expand_more_rounded),
      ],
    );
  }

  Widget _timelineContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text('Sky Explorer timeline', style: Theme.of(context).textTheme.titleLarge)),
            const Icon(Icons.expand_less_rounded),
          ],
        ),
        const SizedBox(height: 6),
        Text('Scrub the journey to inspect milestones without leaving the mission workspace.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        Row(
          children: List<Widget>.generate(5, (int index) {
            final reached = index / 4 <= _timeline;
            return Expanded(
              child: Column(
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: reached ? 30 : 20,
                    height: reached ? 30 : 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: reached ? FlightColors.aeroCyan : FlightColors.nightBlue,
                      border: Border.all(color: reached ? FlightColors.aeroCyan : FlightColors.muted.withValues(alpha: .4)),
                    ),
                    child: reached ? const Icon(Icons.check_rounded, size: 16, color: FlightColors.deepNavy) : null,
                  ),
                  const SizedBox(height: 6),
                  Text('${index * 3}/12', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }),
        ),
        Slider(
          value: _timeline,
          onChanged: (double value) => setState(() => _timeline = value),
          onChangeEnd: (_) => HapticFeedback.selectionClick(),
        ),
        Text('Preview milestone: ${(12 * _timeline).round()} missions', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: FlightColors.aeroCyan)),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: FlightColors.skyBlue.withValues(alpha: .14), shape: BoxShape.circle),
            child: Icon(mission.icon, color: FlightColors.aeroCyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text(mission.title, style: Theme.of(context).textTheme.titleMedium)),
                    Text('${(mission.progress * 100).round()}%'),
                  ],
                ),
                Text(mission.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: mission.progress, minHeight: 7, color: FlightColors.skyBlue, backgroundColor: FlightColors.nightBlue),
                ),
                const SizedBox(height: 7),
                Text(mission.reward, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: FlightColors.sunOrange)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

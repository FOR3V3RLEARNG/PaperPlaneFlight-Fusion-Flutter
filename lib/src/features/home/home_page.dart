import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/progress_state.dart';
import '../../core/theme.dart';
import '../../widgets/glass_surface.dart';
import '../../widgets/morphing_metric.dart';
import '../../widgets/paper_plane_mark.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
            sliver: SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const PaperPlaneMark(size: 54),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('PAPER PLANE', style: Theme.of(context).textTheme.titleLarge),
                              Text(
                                'FLIGHT / SKY PILOT',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: FlightColors.aeroCyan,
                                      letterSpacing: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 54),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _HeroPanel(progress: progress),
                    const SizedBox(height: 18),
                    Text('LIVE METRICS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: FlightColors.aeroCyan)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const <Widget>[
                        MorphingMetric(
                          label: 'Best score',
                          value: '36,950',
                          unit: 'pts',
                          accent: FlightColors.sunOrange,
                          icon: Icons.star_rounded,
                          details: <String>['Top 8% this week', 'Best combo x27', 'Next target 40,000'],
                        ),
                        MorphingMetric(
                          label: 'Distance',
                          value: '128.6',
                          unit: 'km',
                          accent: FlightColors.aeroCyan,
                          icon: Icons.route_rounded,
                          details: <String>['12 worlds explored', 'Longest run 6.8 km', 'Sky Islands 72%'],
                        ),
                        MorphingMetric(
                          label: 'Mastery',
                          value: '72',
                          unit: '%',
                          accent: FlightColors.leafGreen,
                          icon: Icons.auto_graph_rounded,
                          details: <String>['Ring accuracy 91%', 'Boost control 84%', 'Glide efficiency 88%'],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _MissionStrip(completed: progress.completedMissions),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.progress});

  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final wide = constraints.maxWidth >= 760;
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'CHASE\nTHE WIND.',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Soar through living sky worlds. Thread rings, read the wind, and turn every flight into mastery.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: FlightColors.muted),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () => context.push('/flight'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Flight'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/map'),
                  icon: const Icon(Icons.public_rounded),
                  label: const Text('Explore World'),
                ),
              ],
            ),
          ],
        );

        final visual = Semantics(
          label: 'Sky Islands flight preview',
          image: true,
          child: SizedBox(
            height: wide ? 360 : 270,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned.fill(child: CustomPaint(painter: const _SkyPreviewPainter())),
                const PaperPlaneMark(size: 150),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: _LevelChip(level: progress.level, xp: progress.xp),
                ),
              ],
            ),
          ),
        );

        return GlassSurface(
          highlight: true,
          padding: EdgeInsets.zero,
          child: wide
              ? Row(
                  children: <Widget>[
                    Expanded(child: Padding(padding: const EdgeInsets.all(34), child: text)),
                    Expanded(child: visual),
                  ],
                )
              : Column(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.fromLTRB(24, 28, 24, 12), child: text),
                    visual,
                  ],
                ),
        ).animate().fadeIn(duration: 420.ms).slideY(begin: .04, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, required this.xp});

  final int level;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: FlightColors.deepNavy.withValues(alpha: .84),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x553DB8FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.workspace_premium_rounded, color: FlightColors.sunOrange),
          const SizedBox(width: 8),
          Text('LV $level', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: 10),
          Text('$xp XP', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MissionStrip extends StatelessWidget {
  const _MissionStrip({required this.completed});

  final int completed;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text('Sky Explorer', style: Theme.of(context).textTheme.titleLarge)),
              Text('$completed / 12', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: FlightColors.aeroCyan)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Complete 12 missions to unlock the Cloud Runner plane.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: completed / 12,
              backgroundColor: FlightColors.nightBlue,
              color: FlightColors.aeroCyan,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.go('/missions'),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Open mission timeline'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkyPreviewPainter extends CustomPainter {
  const _SkyPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF0A4AA8), Color(0xFF168AD8), Color(0xFFBDE8FF)],
        ).createShader(rect),
    );

    for (var i = 0; i < 7; i++) {
      final x = size.width * (.08 + i * .15);
      final y = size.height * (.18 + (i % 3) * .17);
      final radius = size.shortestSide * (.055 + (i % 2) * .018);
      final cloudPaint = Paint()..color = Colors.white.withValues(alpha: .14 + i * .015);
      canvas.drawCircle(Offset(x, y), radius, cloudPaint);
      canvas.drawCircle(Offset(x + radius * .8, y + 4), radius * .72, cloudPaint);
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = FlightColors.sunOrange
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(size.width * .76, size.height * .30), size.shortestSide * .09, ringPaint);

    final island = Path()
      ..moveTo(size.width * .68, size.height * .66)
      ..quadraticBezierTo(size.width * .78, size.height * .58, size.width * .90, size.height * .64)
      ..lineTo(size.width * .82, size.height * .82)
      ..lineTo(size.width * .71, size.height * .78)
      ..close();
    canvas.drawPath(island, Paint()..color = const Color(0xFF3B6C5C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

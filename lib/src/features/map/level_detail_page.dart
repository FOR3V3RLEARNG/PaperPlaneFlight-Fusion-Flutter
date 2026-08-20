import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../widgets/glass_surface.dart';
import '../../widgets/paper_plane_mark.dart';

class LevelDetailPage extends StatelessWidget {
  const LevelDetailPage({required this.levelId, super.key});

  final String levelId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    tooltip: 'Back to Sky Atlas',
                    onPressed: context.pop,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text('SKY ATLAS / LEVEL $levelId', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: FlightColors.aeroCyan)),
                ],
              ),
              const SizedBox(height: 20),
              GlassSurface(
                highlight: true,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final wide = constraints.maxWidth > 650;
                    final node = Hero(
                      tag: 'world-node-$levelId',
                      child: Container(
                        width: 118,
                        height: 118,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: <Color>[FlightColors.skyBlue, FlightColors.violet]),
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: FlightColors.aeroCyan.withValues(alpha: .25), blurRadius: 28),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(levelId, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                      ),
                    );
                    final detail = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('RING CANYON', style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 10),
                        Text(
                          'Cross alternating wind tunnels, chain six precision rings, then boost through the final canyon gate.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: FlightColors.muted),
                        ),
                        const SizedBox(height: 18),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            Chip(avatar: Icon(Icons.timer_outlined, size: 18), label: Text('2–4 min')),
                            Chip(avatar: Icon(Icons.air_rounded, size: 18), label: Text('Crosswind')),
                            Chip(avatar: Icon(Icons.star_outline_rounded, size: 18), label: Text('3 objectives')),
                          ],
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () => context.push('/flight'),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Launch this level'),
                        ),
                      ],
                    );
                    return wide
                        ? Row(
                            children: <Widget>[
                              node,
                              const SizedBox(width: 26),
                              Expanded(child: detail),
                              const PaperPlaneMark(size: 120),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[node, const SizedBox(height: 20), detail],
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

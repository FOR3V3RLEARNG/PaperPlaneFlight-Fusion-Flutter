import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/progress_state.dart';
import '../../core/theme.dart';
import '../../widgets/glass_surface.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playerProgressProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 120),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('PILOT', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 18),
              GlassSurface(
                highlight: true,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: <Color>[FlightColors.skyBlue, FlightColors.violet]),
                      ),
                      child: const Icon(Icons.person_rounded, size: 38),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('PaperPilot', style: Theme.of(context).textTheme.titleLarge),
                          Text('Sky Explorer • Level ${progress.level}', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (progress.xp % 12500) / 12500,
                            minHeight: 7,
                            color: FlightColors.aeroCyan,
                            backgroundColor: FlightColors.nightBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _StatCard(icon: Icons.star_rounded, label: 'Stars', value: '${progress.stars}', color: FlightColors.sunOrange),
                  _StatCard(icon: Icons.route_rounded, label: 'Distance', value: '${progress.totalDistanceKm.toStringAsFixed(1)} km', color: FlightColors.aeroCyan),
                  _StatCard(icon: Icons.emoji_events_rounded, label: 'Best score', value: '${progress.bestScore}', color: FlightColors.violet),
                  _StatCard(icon: Icons.diamond_outlined, label: 'Gems', value: '${progress.gems}', color: FlightColors.skyBlue),
                ],
              ),
              const SizedBox(height: 16),
              GlassSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Accessibility & comfort', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const _PreferenceTile(icon: Icons.motion_photos_off_outlined, title: 'Reduced motion', subtitle: 'Follows the system accessibility setting'),
                    const _PreferenceTile(icon: Icons.touch_app_outlined, title: 'Haptics', subtitle: 'Meaningful feedback only — not every tap'),
                    const _PreferenceTile(icon: Icons.text_fields_rounded, title: 'Scalable type', subtitle: 'Layouts remain usable at large text sizes'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width < 520 ? double.infinity : 210,
      child: GlassSurface(
        child: Row(
          children: <Widget>[
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: FlightColors.aeroCyan),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

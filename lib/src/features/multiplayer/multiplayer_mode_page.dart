import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../characters/character_select_page.dart';

class MultiplayerModePage extends StatelessWidget {
  const MultiplayerModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Race Mode')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('MULTIPLAYER FLIGHT', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text(
            'Race YAALON against an AI rival, a second player on the same device, or another phone/tablet.',
            style: TextStyle(color: Color(0xFFC7D9EA), height: 1.45),
          ),
          const SizedBox(height: 18),
          _ModeCard(
            icon: Icons.smart_toy_outlined,
            title: 'Rival Race',
            subtitle: 'Pick a world and wing level in the Hangar, then race an animated AI rival with debris, overtaking and powers.',
            accent: FlightColors.cyan,
            onTap: () => context.push('/hangar'),
          ),
          const SizedBox(height: 10),
          _ModeCard(
            icon: Icons.splitscreen_rounded,
            title: 'Local Split Screen',
            subtitle: 'Two players, one phone/tablet. Landscape left/right view with independent touch steering and powers.',
            accent: FlightColors.orange,
            onTap: () => context.push('/character-select', extra: const CharacterSelectLaunch(CharacterSelectMode.split)),
          ),
          const SizedBox(height: 10),
          _ModeCard(
            icon: Icons.devices_rounded,
            title: 'Separate Device Race',
            subtitle: 'Host or join a room code. Designed for two phones/tablets with low-latency state synchronization.',
            accent: FlightColors.violet,
            onTap: () => context.push('/character-select', extra: const CharacterSelectLaunch(CharacterSelectMode.remote)),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.icon, required this.title, required this.subtitle, required this.accent, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: FlightColors.panel,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: .32)),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Color(0xFFC7D9EA), height: 1.35)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

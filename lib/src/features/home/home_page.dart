import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../characters/character_select_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF03172E), Color(0xFF07549A), Color(0xFF46B9E5)])),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.near_me_rounded, size: 70, color: Colors.white),
                      const SizedBox(height: 12),
                      Text('PAPER PLANE', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
                      const Text('RIVAL RACE', textAlign: TextAlign.center, style: TextStyle(color: FlightColors.cyan, letterSpacing: 4, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      const Text('Choose your pilot. Upgrade wings. Race through living weather. Use powers. Beat the Wing Boss.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD2E4F1), height: 1.45)),
                      const SizedBox(height: 28),
                      FilledButton.icon(onPressed: () => context.push('/multiplayer'), icon: const Icon(Icons.sports_esports_rounded), label: const Text('Choose Race Mode'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(58))),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(onPressed: () => context.push('/character-select', extra: const CharacterSelectLaunch(CharacterSelectMode.rival)), icon: const Icon(Icons.face_rounded), label: const Text('Choose Pilot & Quick Race'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54))),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(onPressed: () => context.push('/hangar'), icon: const Icon(Icons.warehouse_rounded), label: const Text('Hangar — Upgrade Wings'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}


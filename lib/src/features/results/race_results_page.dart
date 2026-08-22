import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../game/models/race_models.dart';
import '../../game/systems/token_wallet.dart';
import '../../game/systems/wing_progression.dart';

class RaceResultsPage extends StatefulWidget {
  const RaceResultsPage({super.key, required this.result});
  final RaceResult? result;

  @override
  State<RaceResultsPage> createState() => _RaceResultsPageState();
}

class _RaceResultsPageState extends State<RaceResultsPage> {
  int? tokenBalance;

  @override
  void initState() {
    super.initState();
    _persist();
  }

  Future<void> _persist() async {
    final r = widget.result;
    if (r == null) return;
    final balance = await TokenWalletRepository().addTokens(r.tokens);
    if (r.bossRace && r.playerWon) {
      await WingProgressionRepository().markBossCleared(r.worldId);
    }
    if (mounted) setState(() => tokenBalance = balance);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final won = r?.playerWon ?? false;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07549A), FlightColors.deepNavy],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      won ? Icons.emoji_events_rounded : Icons.flag_rounded,
                      size: 70,
                      color: won ? FlightColors.orange : Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      won ? 'YOU WON!' : 'RACE COMPLETE',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 18),
                    _Metric(label: 'SCORE', value: '${r?.score ?? 0}'),
                    _Metric(
                      label: 'WORLD',
                      value: (r?.worldId ?? 'sky_islands')
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                    ),
                    _Metric(
                      label: 'BOSS RACE',
                      value: (r?.bossRace ?? false) ? 'YES' : 'NO',
                    ),
                    _Metric(label: 'TOKENS EARNED', value: '${r?.tokens ?? 0}'),
                    if (tokenBalance != null)
                      _Metric(label: 'TOKEN BALANCE', value: '$tokenBalance'),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => context.go('/hangar'),
                      icon: const Icon(Icons.warehouse_rounded),
                      label: const Text('Hangar — Upgrade Wings'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/multiplayer'),
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Race Again'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 7),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: FlightColors.panel.withValues(alpha: .82),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFFABC3D8),
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );
}

class SplitResultPayload {
  const SplitResultPayload({required this.winner, required this.result});
  final int winner;
  final RaceResult result;
}

class SplitRaceResultsPage extends StatelessWidget {
  const SplitRaceResultsPage({super.key, required this.payload});
  final SplitResultPayload? payload;
  @override
  Widget build(BuildContext context) {
    final winner = payload?.winner ?? 1;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 74,
                color: FlightColors.orange,
              ),
              const SizedBox(height: 12),
              Text(
                'PLAYER $winner WINS!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/multiplayer'),
                child: const Text('Race Again'),
              ),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

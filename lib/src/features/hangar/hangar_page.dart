import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/race_content.dart';
import '../../game/models/race_models.dart';
import '../../game/systems/token_wallet.dart';
import '../../game/systems/wing_progression.dart';
import '../characters/character_select_page.dart';

class HangarPage extends StatefulWidget {
  const HangarPage({super.key});

  @override
  State<HangarPage> createState() => _HangarPageState();
}

class _HangarPageState extends State<HangarPage> {
  final _progressionRepo = WingProgressionRepository();
  final _wallet = TokenWalletRepository();
  int tokens = 0;
  Map<String, WorldWingProgress> progress = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final balance = await _wallet.balance();
    final entries = await Future.wait(
      raceWorlds.map((w) => _progressionRepo.load(w.id)),
    );
    if (!mounted) return;
    setState(() {
      tokens = balance;
      progress = {for (final p in entries) p.worldId: p};
      loading = false;
    });
  }

  Future<void> _upgrade(String worldId) async {
    final result = await _progressionRepo.upgrade(worldId);
    if (!mounted) return;
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.reason ?? 'Upgrade failed')),
      );
    }
    await _load();
  }

  void _race(RaceWorld world, {required bool boss}) {
    context.push(
      '/character-select',
      extra: CharacterSelectLaunch(
        CharacterSelectMode.rival,
        worldId: world.id,
        bossRace: boss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hangar')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: FlightColors.panel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.toll_rounded,
                          color: FlightColors.orange,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$tokens TOKENS',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Earned in races',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFB8CBDC),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final world in raceWorlds)
                    _WorldCard(
                      world: world,
                      progress:
                          progress[world.id] ??
                          WorldWingProgress(
                            worldId: world.id,
                            wingLevel: 1,
                            bossCleared: false,
                          ),
                      tokens: tokens,
                      onUpgrade: () => _upgrade(world.id),
                      onRace: () => _race(world, boss: false),
                      onBossRace: () => _race(world, boss: true),
                    ),
                ],
              ),
            ),
    );
  }
}

class _WorldCard extends StatelessWidget {
  const _WorldCard({
    required this.world,
    required this.progress,
    required this.tokens,
    required this.onUpgrade,
    required this.onRace,
    required this.onBossRace,
  });

  final RaceWorld world;
  final WorldWingProgress progress;
  final int tokens;
  final VoidCallback onUpgrade;
  final VoidCallback onRace;
  final VoidCallback onBossRace;

  @override
  Widget build(BuildContext context) {
    final maxed = progress.wingLevel >= 10;
    final nextCost = maxed ? null : wingLevels()[progress.wingLevel].cost;
    final canAfford = nextCost != null && tokens >= nextCost;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlightColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  world.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: FlightColors.cyan.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'WING ${progress.wingLevel}',
                  style: const TextStyle(
                    color: FlightColors.cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${world.bossName} — ${world.bossTitle}',
            style: const TextStyle(fontSize: 11, color: Color(0xFFB8CBDC)),
          ),
          Text(
            world.weather,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF7E9AB2)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: maxed ? null : (canAfford ? onUpgrade : null),
                  child: Text(
                    maxed ? 'MAX WING' : 'UPGRADE • ${nextCost ?? 0}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: progress.bossUnlocked ? onBossRace : onRace,
                  style: progress.bossUnlocked
                      ? FilledButton.styleFrom(
                          backgroundColor: FlightColors.red,
                        )
                      : null,
                  child: Text(
                    progress.bossUnlocked ? 'CHALLENGE BOSS' : 'RACE',
                  ),
                ),
              ),
            ],
          ),
          if (progress.bossCleared)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'BOSS CLEARED',
                style: TextStyle(
                  fontSize: 9,
                  color: FlightColors.green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../game/models/race_models.dart';
import '../../game/rival_race_game.dart';

class RaceLaunch {
  const RaceLaunch({
    required this.worldId,
    required this.wingLevel,
    this.rivalWingLevel = 1,
    this.playerName = 'YAALON',
    this.rivalName = 'UZZIAH',
    this.playerCharacterId = 'yaalon',
    this.rivalCharacterId = 'uzziah',
    this.bossRace = false,
  });

  final String worldId;
  final String playerName;
  final String rivalName;
  final String playerCharacterId;
  final String rivalCharacterId;
  final int wingLevel;
  final int rivalWingLevel;
  final bool bossRace;
}

class RacePage extends StatefulWidget {
  const RacePage({super.key, required this.launch});
  final RaceLaunch launch;

  @override
  State<RacePage> createState() => _RacePageState();
}

class _RacePageState extends State<RacePage> {
  late final RivalRaceGame game;
  Offset velocity = Offset.zero;

  @override
  void initState() {
    super.initState();
    game = RivalRaceGame(
      playerName: widget.launch.playerName,
      playerCharacterId: widget.launch.playerCharacterId,
      rivalName: widget.launch.rivalName,
      rivalCharacterId: widget.launch.rivalCharacterId,
      worldId: widget.launch.worldId,
      wingLevel: widget.launch.wingLevel,
      rivalWingLevel: widget.launch.rivalWingLevel,
      bossRace: widget.launch.bossRace,
      onFinished: (result) {
        if (mounted) context.go('/results', extra: result);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) {
              velocity = Offset(
                (velocity.dx * .5 + details.delta.dx * .5)
                    .clamp(-7, 7)
                    .toDouble(),
                (velocity.dy * .5 + details.delta.dy * .5)
                    .clamp(-7, 7)
                    .toDouble(),
              );
              game.setInput(velocity.dx / 5.2, velocity.dy / 5.2);
            },
            onPanEnd: (_) {
              velocity = Offset.zero;
              game.clearInput();
            },
            onPanCancel: () {
              velocity = Offset.zero;
              game.clearInput();
            },
            child: GameWidget<RivalRaceGame>(game: game),
          ),
          SafeArea(
            child: _RaceHud(game: game, launch: widget.launch),
          ),
        ],
      ),
    );
  }
}

class _RaceHud extends StatelessWidget {
  const _RaceHud({required this.game, required this.launch});
  final RivalRaceGame game;
  final RaceLaunch launch;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RaceHudState>(
      valueListenable: game.hud,
      builder: (context, hud, _) {
        return Stack(
          children: [
            Positioned(
              left: 8,
              top: 4,
              child: IconButton.filledTonal(
                tooltip: 'Return to previous screen',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Positioned(
              left: 64,
              right: 64,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: FlightColors.deepNavy.withValues(alpha: .60),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        'RACE',
                        hud.position == RacePosition.first ? '1ST' : '2ND',
                      ),
                    ),
                    Expanded(child: _Stat('WING', 'LV ${hud.wingLevel}')),
                    Expanded(
                      child: _Stat(
                        'GAP',
                        '${(hud.gap * 100).toStringAsFixed(1)}%',
                      ),
                    ),
                    Expanded(child: _Stat('TOKENS', '${hud.tokens}')),
                  ],
                ),
              ),
            ),
            if (hud.banner.isNotEmpty)
              Positioned(
                left: 65,
                right: 65,
                top: 66,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FlightColors.deepNavy.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    hud.banner,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: FlightColors.orange,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 16,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Integrity(
                          name: launch.playerName,
                          value: hud.integrity,
                          color: FlightColors.cyan,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Integrity(
                          name: launch.rivalName,
                          value: hud.rivalIntegrity,
                          color: FlightColors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _PowerButton(
                        label: 'FIRE',
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFFFF6D3A),
                        onTap: () => game.usePower(RacePowerType.fireBurst),
                      ),
                      const SizedBox(width: 7),
                      _PowerButton(
                        label: 'WARP',
                        icon: Icons.blur_circular_rounded,
                        color: FlightColors.violet,
                        onTap: () =>
                            game.usePower(RacePowerType.distortionPulse),
                      ),
                      const SizedBox(width: 7),
                      _PowerButton(
                        label: 'SLOW',
                        icon: Icons.air_rounded,
                        color: FlightColors.cyan,
                        onTap: () => game.usePower(RacePowerType.slowWindField),
                      ),
                      const Spacer(),
                      Semantics(
                        button: true,
                        label: 'Turbo boost',
                        child: InkWell(
                          onTap: game.boostPlayer,
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: FlightColors.cyan,
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: FlightColors.deepNavy,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 7,
          color: Color(0xFFB8CEE0),
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class _Integrity extends StatelessWidget {
  const _Integrity({
    required this.name,
    required this.value,
    required this.color,
  });
  final String name;
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: FlightColors.deepNavy.withValues(alpha: .58),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          minHeight: 6,
          color: color,
          borderRadius: BorderRadius.circular(9),
          backgroundColor: Colors.white10,
        ),
      ],
    ),
  );
}

class _PowerButton extends StatelessWidget {
  const _PowerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Use $label power',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 57,
        height: 57,
        decoration: BoxDecoration(
          color: FlightColors.deepNavy.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: .45)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 21),
            Text(
              label,
              style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    ),
  );
}

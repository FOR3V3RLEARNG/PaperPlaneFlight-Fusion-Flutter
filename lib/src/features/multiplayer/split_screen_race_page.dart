import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../game/models/race_models.dart';
import '../../game/split_screen_race_game.dart';
import '../results/race_results_page.dart';


class SplitRaceLaunch {
  const SplitRaceLaunch({
    this.playerOneName = 'YAALON',
    this.playerTwoName = 'UZZIAH',
    this.playerOneCharacterId = 'yaalon',
    this.playerTwoCharacterId = 'uzziah',
    this.playerOneWing = 3,
    this.playerTwoWing = 3,
    this.worldId = 'sky_islands',
  });
  final String playerOneName;
  final String playerTwoName;
  final String playerOneCharacterId;
  final String playerTwoCharacterId;
  final int playerOneWing;
  final int playerTwoWing;
  final String worldId;
}

class SplitScreenRacePage extends StatefulWidget {
  const SplitScreenRacePage({super.key, required this.launch});
  final SplitRaceLaunch launch;

  @override
  State<SplitScreenRacePage> createState() => _SplitScreenRacePageState();
}

class _SplitScreenRacePageState extends State<SplitScreenRacePage> {
  late final SplitScreenRaceGame game;
  Offset velocityOne = Offset.zero;
  Offset velocityTwo = Offset.zero;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    game = SplitScreenRaceGame(
      playerOneName: widget.launch.playerOneName,
      playerTwoName: widget.launch.playerTwoName,
      playerOneCharacterId: widget.launch.playerOneCharacterId,
      playerTwoCharacterId: widget.launch.playerTwoCharacterId,
      worldId: widget.launch.worldId,
      playerOneWing: widget.launch.playerOneWing,
      playerTwoWing: widget.launch.playerTwoWing,
      onFinished: _finish,
    );
  }

  Future<void> _finish(int winner, RaceResult result) async {
    if (!mounted) return;
    await _restorePortrait();
    if (!mounted) return;
    context.go('/split-results', extra: SplitResultPayload(winner: winner, result: result));
  }

  Future<void> _restorePortrait() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _restorePortrait();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameWidget<SplitScreenRaceGame>(game: game),
          Row(
            children: [
              Expanded(child: _TouchZone(player: 1, onInput: _inputOne, onClear: () => game.clearInput(1))),
              Expanded(child: _TouchZone(player: 2, onInput: _inputTwo, onClear: () => game.clearInput(2))),
            ],
          ),
          SafeArea(child: _SplitHud(game: game, onExit: _exitRace)),
        ],
      ),
    );
  }

  void _inputOne(DragUpdateDetails details) {
    velocityOne = Offset(
      (velocityOne.dx * .48 + details.delta.dx * .52).clamp(-7, 7).toDouble(),
      (velocityOne.dy * .48 + details.delta.dy * .52).clamp(-7, 7).toDouble(),
    );
    game.setInput(1, velocityOne.dx / 5.0, velocityOne.dy / 5.0);
  }

  void _inputTwo(DragUpdateDetails details) {
    velocityTwo = Offset(
      (velocityTwo.dx * .48 + details.delta.dx * .52).clamp(-7, 7).toDouble(),
      (velocityTwo.dy * .48 + details.delta.dy * .52).clamp(-7, 7).toDouble(),
    );
    game.setInput(2, velocityTwo.dx / 5.0, velocityTwo.dy / 5.0);
  }

  Future<void> _exitRace() async {
    game.pauseEngine();
    await _restorePortrait();
    if (mounted) context.pop();
  }
}

class _TouchZone extends StatelessWidget {
  const _TouchZone({required this.player, required this.onInput, required this.onClear});
  final int player;
  final GestureDragUpdateCallback onInput;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Player $player flight steering zone',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: onInput,
        onPanEnd: (_) => onClear(),
        onPanCancel: onClear,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SplitHud extends StatelessWidget {
  const _SplitHud({required this.game, required this.onExit});
  final SplitScreenRaceGame game;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SplitRaceHudState>(
      valueListenable: game.hud,
      builder: (context, h, _) {
        return Stack(
          children: [
            Positioned(
              left: 8,
              top: 4,
              child: IconButton.filledTonal(
                tooltip: 'Exit split-screen race',
                onPressed: onExit,
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Positioned(
              left: 60,
              top: 8,
              child: _PlayerHeader(
                name: game.playerOneName,
                progress: h.p1Progress,
                integrity: h.p1Integrity,
                wing: h.p1Wing,
                color: FlightColors.cyan,
                banner: h.p1Banner,
              ),
            ),
            Positioned(
              right: 12,
              top: 8,
              child: _PlayerHeader(
                name: game.playerTwoName,
                progress: h.p2Progress,
                integrity: h.p2Integrity,
                wing: h.p2Wing,
                color: FlightColors.orange,
                banner: h.p2Banner,
                alignRight: true,
              ),
            ),
            Positioned(
              left: 14,
              bottom: 12,
              child: _PlayerControls(player: 1, game: game, accent: FlightColors.cyan),
            ),
            Positioned(
              right: 14,
              bottom: 12,
              child: _PlayerControls(player: 2, game: game, accent: FlightColors.orange, reverse: true),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: FlightColors.deepNavy.withValues(alpha: .80),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Center(
                      child: Text('VS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: FlightColors.orange)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.name, required this.progress, required this.integrity, required this.wing, required this.color, required this.banner, this.alignRight = false});
  final String name;
  final double progress;
  final double integrity;
  final int wing;
  final Color color;
  final String banner;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: FlightColors.deepNavy.withValues(alpha: .58),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: color.withValues(alpha: .32)),
          ),
          child: Column(
            crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: alignRight ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 7),
                  Text('WING $wing', style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(value: progress, minHeight: 5, color: color, backgroundColor: Colors.white12),
              const SizedBox(height: 4),
              LinearProgressIndicator(value: integrity / 100, minHeight: 3, color: integrity > 35 ? FlightColors.green : FlightColors.red, backgroundColor: Colors.white10),
              if (banner.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(banner, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w900)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({required this.player, required this.game, required this.accent, this.reverse = false});
  final int player;
  final SplitScreenRaceGame game;
  final Color accent;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      _PowerMini(icon: Icons.local_fire_department_rounded, label: 'FIRE', color: const Color(0xFFFF6D3A), onTap: () => game.usePower(player, RacePowerType.fireBurst)),
      _PowerMini(icon: Icons.blur_circular_rounded, label: 'WARP', color: FlightColors.violet, onTap: () => game.usePower(player, RacePowerType.distortionPulse)),
      _PowerMini(icon: Icons.air_rounded, label: 'SLOW', color: FlightColors.cyan, onTap: () => game.usePower(player, RacePowerType.slowWindField)),
      _PowerMini(icon: Icons.bolt_rounded, label: 'BOOST', color: accent, onTap: () => game.boost(player), large: true),
    ];
    return Row(
      textDirection: reverse ? TextDirection.rtl : TextDirection.ltr,
      children: controls.map((w) => Padding(padding: const EdgeInsets.only(right: 5), child: w)).toList(),
    );
  }
}

class _PowerMini extends StatelessWidget {
  const _PowerMini({required this.icon, required this.label, required this.color, required this.onTap, this.large = false});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 58.0 : 47.0;
    return Semantics(
      button: true,
      label: '$label power',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: FlightColors.deepNavy.withValues(alpha: .76),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .45)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: large ? 25 : 19, color: color),
              Text(label, style: const TextStyle(fontSize: 6.5, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}

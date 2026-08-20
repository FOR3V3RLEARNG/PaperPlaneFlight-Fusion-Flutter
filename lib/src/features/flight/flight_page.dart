import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/progress_state.dart';
import '../../core/theme.dart';
import 'flight_scene.dart';
import 'flight_simulation.dart';

class FlightPage extends ConsumerStatefulWidget {
  const FlightPage({super.key});

  @override
  ConsumerState<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends ConsumerState<FlightPage> {
  final GlobalKey<FlightSceneState> _sceneKey = GlobalKey<FlightSceneState>();
  FlightSnapshot _snapshot = const FlightSnapshot(
    score: 12840,
    distanceMeters: 0,
    energy: 78,
    combo: 12,
    stars: 0,
  );
  bool _controlsExpanded = false;
  bool _recorded = false;

  void _recordFlightOnce() {
    if (_recorded) return;
    _recorded = true;
    ref.read(playerProgressProvider.notifier).recordFlight(
          score: _snapshot.score,
          distanceKm: _snapshot.distanceMeters / 1000,
          stars: _snapshot.stars,
        );
  }

  void _finishFlight() {
    _recordFlightOnce();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, Object? _) {
          if (didPop) _recordFlightOnce();
        },
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: FlightScene(
                key: _sceneKey,
                onSnapshot: (FlightSnapshot snapshot) {
                  if (mounted) setState(() => _snapshot = snapshot);
                },
              ),
            ),
            const Positioned.fill(child: IgnorePointer(child: _Vignette())),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: <Widget>[
                    _FlightTopBar(
                      snapshot: _snapshot,
                      onBack: _finishFlight,
                      onPause: () {
                        _sceneKey.currentState?.togglePause();
                        setState(() => _controlsExpanded = !_controlsExpanded);
                      },
                      controlsExpanded: _controlsExpanded,
                    ),
                    const Spacer(),
                    _FlightBottomControls(
                      energy: _snapshot.energy,
                      combo: _snapshot.combo,
                      onBoost: () => _sceneKey.currentState?.boost(),
                    ),
                  ],
                ),
              ),
            ),
            if (_controlsExpanded)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 80,
                right: 16,
                child: _PauseCommandSurface(
                  onResume: () {
                    _sceneKey.currentState?.togglePause();
                    setState(() => _controlsExpanded = false);
                  },
                  onQuit: _finishFlight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FlightTopBar extends StatelessWidget {
  const _FlightTopBar({
    required this.snapshot,
    required this.onBack,
    required this.onPause,
    required this.controlsExpanded,
  });

  final FlightSnapshot snapshot;
  final VoidCallback onBack;
  final VoidCallback onPause;
  final bool controlsExpanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _GlassIconButton(
          tooltip: 'Return to previous screen',
          icon: Icons.arrow_back_rounded,
          onPressed: onBack,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _HudMetric(label: 'SCORE', value: snapshot.score.toString(), highlight: true),
              _HudMetric(label: 'DISTANCE', value: '${(snapshot.distanceMeters / 1000).toStringAsFixed(2)} KM'),
              _HudMetric(label: 'STARS', value: '${snapshot.stars}', icon: Icons.star_rounded),
            ],
          ),
        ),
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          width: controlsExpanded ? 116 : 52,
          height: 52,
          child: _GlassIconButton(
            tooltip: controlsExpanded ? 'Close flight controls' : 'Pause and open flight controls',
            icon: controlsExpanded ? Icons.tune_rounded : Icons.pause_rounded,
            label: controlsExpanded ? 'Controls' : null,
            onPressed: onPause,
          ),
        ),
      ],
    );
  }
}

class _HudMetric extends StatelessWidget {
  const _HudMetric({required this.label, required this.value, this.highlight = false, this.icon});

  final String label;
  final String value;
  final bool highlight;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xB30A1D38),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: highlight ? const Color(0x773DB8FF) : const Color(0x333DB8FF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 18, color: FlightColors.sunOrange),
              const SizedBox(width: 5),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: FlightColors.muted)),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 650, end: highlight ? 800 : 700),
                  duration: const Duration(milliseconds: 280),
                  builder: (BuildContext context, double weight, Widget? child) {
                    return Text(
                      value,
                      style: TextStyle(
                        color: FlightColors.cloudWhite,
                        fontSize: highlight ? 20 : 16,
                        fontVariations: <FontVariation>[FontVariation('wght', weight)],
                        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightBottomControls extends StatelessWidget {
  const _FlightBottomControls({required this.energy, required this.combo, required this.onBoost});

  final double energy;
  final int combo;
  final VoidCallback onBoost;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        _EdgeControl(
          label: 'Shield',
          value: '2',
          icon: Icons.shield_outlined,
          color: FlightColors.leafGreen,
          onPressed: () => HapticFeedback.selectionClick(),
        ),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: FlightColors.violet.withValues(alpha: .75),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text('COMBO x$combo', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Text('SWIPE TO STEER', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 6),
            const Icon(Icons.swipe_rounded, color: FlightColors.cloudWhite),
          ],
        ),
        const Spacer(),
        _BoostButton(energy: energy, onPressed: onBoost),
      ],
    );
  }
}

class _BoostButton extends StatefulWidget {
  const _BoostButton({required this.energy, required this.onPressed});

  final double energy;
  final VoidCallback onPressed;

  @override
  State<_BoostButton> createState() => _BoostButtonState();
}

class _BoostButtonState extends State<_BoostButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Boost, energy ${widget.energy.round()} percent',
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 110),
          scale: _pressed ? .90 : 1,
          child: InkResponse(
            radius: 56,
            onTap: widget.onPressed,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[FlightColors.aeroCyan, FlightColors.skyBlue, FlightColors.violet],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: FlightColors.aeroCyan.withValues(alpha: .32), blurRadius: 26),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    value: widget.energy / 100,
                    strokeWidth: 4,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: .16),
                  ),
                  const Icon(Icons.bolt_rounded, size: 42, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeControl extends StatelessWidget {
  const _EdgeControl({required this.label, required this.value, required this.icon, required this.color, required this.onPressed});

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $value available',
      child: IconButton.filledTonal(
        tooltip: '$label ($value)',
        onPressed: onPressed,
        style: IconButton.styleFrom(
          minimumSize: const Size(58, 58),
          backgroundColor: const Color(0xB30A1D38),
          foregroundColor: color,
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class _PauseCommandSurface extends StatelessWidget {
  const _PauseCommandSurface({required this.onResume, required this.onQuit});

  final VoidCallback onResume;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: 270,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xE00A1D38),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x553DB8FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Flight paused', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Your position is preserved.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
              FilledButton.icon(onPressed: onResume, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Resume')),
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: onQuit, icon: const Icon(Icons.exit_to_app_rounded), label: const Text('Finish flight')),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.tooltip, required this.icon, required this.onPressed, this.label});

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xB30A1D38),
      shape: const StadiumBorder(side: BorderSide(color: Color(0x333DB8FF))),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: FlightColors.cloudWhite),
                if (label != null) ...<Widget>[const SizedBox(width: 6), Text(label!)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1.1,
          colors: <Color>[Colors.transparent, Colors.black.withValues(alpha: .52)],
          stops: const <double>[.55, 1],
        ),
      ),
    );
  }
}

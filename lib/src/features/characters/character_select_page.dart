import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/pilot_characters.dart';
import '../../data/race_content.dart';
import '../../game/systems/wing_progression.dart';
import '../multiplayer/split_screen_race_page.dart';
import '../race/race_page.dart';

enum CharacterSelectMode { rival, split, remote }

class CharacterSelectLaunch {
  const CharacterSelectLaunch(this.mode, {this.worldId = 'sky_islands', this.bossRace = false});
  final CharacterSelectMode mode;
  final String worldId;
  final bool bossRace;
}

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key, required this.mode, this.worldId = 'sky_islands', this.bossRace = false});
  final CharacterSelectMode mode;
  final String worldId;
  final bool bossRace;

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  String playerOne = 'yaalon';
  String playerTwo = 'uzziah';
  int wingOne = 3;
  int wingTwo = 3;
  bool loadingProgression = false;

  bool get needsSecond => widget.mode != CharacterSelectMode.remote;
  bool get wingOneIsFromHangar => widget.mode == CharacterSelectMode.rival;

  @override
  void initState() {
    super.initState();
    if (widget.mode == CharacterSelectMode.rival) {
      loadingProgression = true;
      WingProgressionRepository().load(widget.worldId).then((progress) {
        if (!mounted) return;
        setState(() {
          wingOne = widget.bossRace ? 10 : progress.wingLevel;
          wingTwo = widget.bossRace ? 10 : wingTwo;
          loadingProgression = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final worldName = raceWorlds.firstWhere((w) => w.id == widget.worldId, orElse: () => raceWorlds.first).name;
    final title = switch (widget.mode) {
      CharacterSelectMode.rival => widget.bossRace ? 'Boss Race — $worldName' : 'Choose Pilot — $worldName',
      CharacterSelectMode.split => 'Choose Two Pilots',
      CharacterSelectMode.remote => 'Choose Your Online Pilot',
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          Text('PILOT ONE', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: FlightColors.cyan)),
          const SizedBox(height: 8),
          _RosterGrid(selectedId: playerOne, onSelected: (id) => setState(() => playerOne = id)),
          const SizedBox(height: 16),
          if (wingOneIsFromHangar)
            _WingReadout(label: widget.bossRace ? 'P1 WING LEVEL (BOSS)' : 'P1 WING LEVEL (HANGAR)', value: wingOne, loading: loadingProgression)
          else
            _WingPicker(label: 'P1 WING LEVEL', value: wingOne, onChanged: (v) => setState(() => wingOne = v)),
          if (needsSecond) ...[
            const SizedBox(height: 24),
            Text(widget.mode == CharacterSelectMode.rival ? 'AI RIVAL' : 'PILOT TWO', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: FlightColors.orange)),
            const SizedBox(height: 8),
            _RosterGrid(selectedId: playerTwo, onSelected: (id) => setState(() => playerTwo = id)),
            const SizedBox(height: 16),
            if (widget.mode == CharacterSelectMode.rival && widget.bossRace)
              _WingReadout(label: 'RIVAL WING (BOSS)', value: 10, loading: false)
            else
              _WingPicker(label: widget.mode == CharacterSelectMode.rival ? 'RIVAL WING' : 'P2 WING LEVEL', value: wingTwo, onChanged: (v) => setState(() => wingTwo = v)),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: FilledButton.icon(
          onPressed: _launch,
          icon: const Icon(Icons.flight_takeoff_rounded),
          label: Text(widget.mode == CharacterSelectMode.remote ? 'Continue to Lobby' : 'Start Race'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
      ),
    );
  }

  void _launch() {
    final p1 = pilotById(playerOne);
    final p2 = pilotById(playerTwo);
    switch (widget.mode) {
      case CharacterSelectMode.rival:
        context.push('/race', extra: RaceLaunch(
          worldId: widget.worldId,
          wingLevel: wingOne,
          rivalWingLevel: widget.bossRace ? 10 : wingTwo,
          playerName: p1.name,
          rivalName: p2.name,
          playerCharacterId: p1.id,
          rivalCharacterId: p2.id,
          bossRace: widget.bossRace,
        ));
        return;
      case CharacterSelectMode.split:
        context.push('/split-race', extra: SplitRaceLaunch(
          playerOneName: p1.name,
          playerTwoName: p2.name,
          playerOneCharacterId: p1.id,
          playerTwoCharacterId: p2.id,
          playerOneWing: wingOne,
          playerTwoWing: wingTwo,
          worldId: 'sky_islands',
        ));
        return;
      case CharacterSelectMode.remote:
        context.push('/remote-lobby', extra: RemotePilotSelection(characterId: p1.id, displayName: p1.name, wingLevel: wingOne));
        return;
    }
  }
}

class RemotePilotSelection {
  const RemotePilotSelection({required this.characterId, required this.displayName, required this.wingLevel});
  final String characterId;
  final String displayName;
  final int wingLevel;
}

class _WingPicker extends StatelessWidget {
  const _WingPicker({required this.label, required this.value, required this.onChanged});
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: FlightColors.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
            IconButton(onPressed: value > 1 ? () => onChanged(value - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
            Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            IconButton(onPressed: value < 10 ? () => onChanged(value + 1) : null, icon: const Icon(Icons.add_circle_outline)),
          ],
        ),
      );
}

class _WingReadout extends StatelessWidget {
  const _WingReadout({required this.label, required this.value, required this.loading});
  final String label;
  final int value;
  final bool loading;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: FlightColors.panel, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  const Text('Upgrade wings in the Hangar', style: TextStyle(fontSize: 8, color: Color(0xFFB8C9D8))),
                ],
              ),
            ),
            loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}

class _RosterGrid extends StatelessWidget {
  const _RosterGrid({required this.selectedId, required this.onSelected});
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 700 ? 4 : constraints.maxWidth >= 430 ? 3 : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: pilotCharacters.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .93),
        itemBuilder: (_, index) {
          final pilot = pilotCharacters[index];
          final selected = pilot.id == selectedId;
          return Semantics(
            button: pilot.availableByDefault,
            selected: selected,
            label: pilot.availableByDefault ? 'Select ${pilot.name}' : '${pilot.name}, licensed character slot unavailable',
            child: InkWell(
              onTap: pilot.availableByDefault
                  ? () => onSelected(pilot.id)
                  : () => showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(pilot.name),
                          content: Text(pilot.licenseNote ?? 'This character requires licensing.'),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                        ),
                      ),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected ? pilot.primary.withValues(alpha: .13) : FlightColors.panel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? pilot.primary : Colors.white12, width: selected ? 2 : 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Center(child: _PilotPortrait(pilot: pilot))),
                    Text(pilot.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    Text(pilot.callSign, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8, color: pilot.primary, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(pilot.availableByDefault ? pilot.personality : 'LICENSE REQUIRED', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7.5, color: Color(0xFFB8C9D8), height: 1.25)),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class _PilotPortrait extends StatelessWidget {
  const _PilotPortrait({required this.pilot});
  final PilotCharacterDefinition pilot;

  @override
  Widget build(BuildContext context) => CustomPaint(size: const Size(74, 74), painter: _PortraitPainter(pilot));
}

class _PortraitPainter extends CustomPainter {
  const _PortraitPainter(this.pilot);
  final PilotCharacterDefinition pilot;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width * .46, Paint()..color = pilot.primary.withValues(alpha: .11));
    switch (pilot.species) {
      case PilotSpecies.human:
        canvas.drawCircle(Offset(c.dx, c.dy - 7), 17, Paint()..color = pilot.skin);
        canvas.drawArc(Rect.fromCircle(center: Offset(c.dx, c.dy - 12), radius: 18), 3.3, 2.8, true, Paint()..color = pilot.hair);
        break;
      case PilotSpecies.pinkCat:
        final face = Paint()..color = pilot.skin;
        final ears = Path()..moveTo(c.dx-17,c.dy-14)..lineTo(c.dx-10,c.dy-32)..lineTo(c.dx-1,c.dy-15)..moveTo(c.dx+3,c.dy-15)..lineTo(c.dx+12,c.dy-32)..lineTo(c.dx+18,c.dy-13);
        canvas.drawPath(ears, Paint()..color=pilot.primary..style=PaintingStyle.fill);
        canvas.drawCircle(Offset(c.dx,c.dy-5),18,face);
        break;
      case PilotSpecies.monkey:
        canvas.drawCircle(Offset(c.dx-16,c.dy-7),8,Paint()..color=pilot.primary);
        canvas.drawCircle(Offset(c.dx+16,c.dy-7),8,Paint()..color=pilot.primary);
        canvas.drawCircle(Offset(c.dx,c.dy-7),18,Paint()..color=pilot.primary);
        canvas.drawOval(Rect.fromCenter(center:Offset(c.dx,c.dy),width:24,height:18),Paint()..color=pilot.skin);
        break;
      case PilotSpecies.duo:
        canvas.drawCircle(Offset(c.dx-11,c.dy-9),14,Paint()..color=pilot.skin);
        canvas.drawCircle(Offset(c.dx+11,c.dy-6),14,Paint()..color=pilot.skin.withValues(alpha:.96));
        break;
    }
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(c.dx,c.dy+25),width:42,height:24),const Radius.circular(10)),Paint()..color=pilot.secondary);
    canvas.drawCircle(Offset(c.dx-6,c.dy-7),1.5,Paint()..color=const Color(0xFF10243A));
    canvas.drawCircle(Offset(c.dx+6,c.dy-7),1.5,Paint()..color=const Color(0xFF10243A));
  }

  @override
  bool shouldRepaint(covariant _PortraitPainter oldDelegate) => oldDelegate.pilot.id != pilot.id;
}

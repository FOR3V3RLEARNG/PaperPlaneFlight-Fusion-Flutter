import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/pilot_characters.dart';
import '../characters/character_select_page.dart';

class RemoteLobbyPage extends StatefulWidget {
  const RemoteLobbyPage({super.key, required this.selection});
  final RemotePilotSelection? selection;
  @override
  State<RemoteLobbyPage> createState() => _RemoteLobbyPageState();
}

class _RemoteLobbyPageState extends State<RemoteLobbyPage> {
  final room = TextEditingController();
  @override
  void dispose() { room.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pilot = pilotById(widget.selection?.characterId ?? 'yaalon');
    return Scaffold(
      appBar: AppBar(title: const Text('Separate Device Race')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: FlightColors.panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: pilot.primary.withValues(alpha: .35))),
            child: Row(children: [CircleAvatar(backgroundColor: pilot.primary.withValues(alpha: .2), child: Icon(Icons.face_rounded, color: pilot.primary)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pilot.name, style: const TextStyle(fontWeight: FontWeight.w900)), Text('Wing ${widget.selection?.wingLevel ?? 1} • ${pilot.callSign}', style: const TextStyle(fontSize: 10, color: Color(0xFFB8CBDC)))]))]),
          ),
          const SizedBox(height: 18),
          const Text('HOST OR JOIN', style: TextStyle(fontWeight: FontWeight.w900, color: FlightColors.cyan)),
          const SizedBox(height: 8),
          TextField(controller: room, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Room code', hintText: 'SKY-4821')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: () => _notConnected(context), icon: const Icon(Icons.add_link_rounded), label: const Text('Host Room')),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: () => _notConnected(context), icon: const Icon(Icons.login_rounded), label: const Text('Join Room')),
          const SizedBox(height: 18),
          const Text('The gameplay protocol is separated from transport. A Supabase Realtime adapter can synchronize racer position, powers, debris seed and finish state without changing the Flame race rules.', style: TextStyle(fontSize: 10.5, color: Color(0xFFB8CBDC), height: 1.45)),
        ],
      ),
    );
  }

  void _notConnected(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remote transport is ready for Supabase Realtime wiring; no credentials are embedded in this build.')));
}

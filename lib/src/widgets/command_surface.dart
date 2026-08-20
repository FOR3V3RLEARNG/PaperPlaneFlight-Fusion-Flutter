import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

class FlightCommandSurface extends StatefulWidget {
  const FlightCommandSurface({super.key});

  @override
  State<FlightCommandSurface> createState() => _FlightCommandSurfaceState();
}

class _FlightCommandSurfaceState extends State<FlightCommandSurface> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _expanded = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setExpanded(bool value) {
    setState(() => _expanded = value);
    if (value) {
      Future<void>.delayed(const Duration(milliseconds: 160), _focusNode.requestFocus);
    } else {
      _focusNode.unfocus();
      _controller.clear();
    }
    HapticFeedback.selectionClick();
  }

  void _runCommand(String value) {
    final query = value.trim().toLowerCase();
    if (query.contains('flight') || query.contains('play')) {
      context.push('/flight');
    } else if (query.contains('hangar') || query.contains('plane')) {
      context.go('/hangar');
    } else if (query.contains('mission') || query.contains('challenge')) {
      context.go('/missions');
    } else if (query.contains('world') || query.contains('map')) {
      context.go('/map');
    }
    _setExpanded(false);
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width;
    final width = _expanded ? (maxWidth < 420 ? maxWidth - 32 : 360.0) : 52.0;
    return Semantics(
      label: _expanded ? 'Flight command surface' : 'Open flight commands',
      button: !_expanded,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_expanded ? 24 : 28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutCubic,
            width: width,
            height: _expanded ? 136 : 52,
            decoration: BoxDecoration(
              color: FlightColors.glassHigh.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(_expanded ? 24 : 28),
              border: Border.all(color: const Color(0x553DB8FF)),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x44000000), blurRadius: 24, offset: Offset(0, 10)),
              ],
            ),
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(Icons.auto_awesome_rounded, color: FlightColors.aeroCyan),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text('Flight Command', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            IconButton(
                              tooltip: 'Close commands',
                              onPressed: () => _setExpanded(false),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.go,
                            onSubmitted: _runCommand,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Try “start flight” or “open hangar”',
                              prefixIcon: Icon(Icons.search_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : IconButton(
                    tooltip: 'Flight commands',
                    onPressed: () => _setExpanded(true),
                    icon: const Icon(Icons.auto_awesome_rounded, color: FlightColors.aeroCyan),
                  ),
          ),
        ),
      ),
    );
  }
}

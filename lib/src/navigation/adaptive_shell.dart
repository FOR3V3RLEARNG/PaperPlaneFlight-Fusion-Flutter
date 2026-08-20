import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../widgets/command_surface.dart';

class FlightDestination {
  const FlightDestination(this.path, this.label, this.icon, this.selectedIcon);

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const flightDestinations = <FlightDestination>[
  FlightDestination('/home', 'Home', Icons.home_outlined, Icons.home_rounded),
  FlightDestination('/map', 'World', Icons.public_outlined, Icons.public_rounded),
  FlightDestination('/hangar', 'Hangar', Icons.airplanemode_active_outlined, Icons.airplanemode_active_rounded),
  FlightDestination('/missions', 'Missions', Icons.flag_outlined, Icons.flag_rounded),
  FlightDestination('/profile', 'Pilot', Icons.person_outline_rounded, Icons.person_rounded),
];

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  int get _selectedIndex {
    final index = flightDestinations.indexWhere((destination) => location.startsWith(destination.path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final selectedIndex = _selectedIndex;
        final isCompact = constraints.maxWidth < 720;
        final isExpanded = constraints.maxWidth >= 1100;

        final content = Stack(
          children: <Widget>[
            Positioned.fill(child: child),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              right: 16,
              child: const SafeArea(top: false, child: FlightCommandSurface()),
            ),
          ],
        );

        if (isExpanded) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                    child: _AdaptiveToolDock(selectedIndex: selectedIndex),
                  ),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }

        if (!isCompact) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                content,
                Positioned(
                  left: 18,
                  top: MediaQuery.sizeOf(context).height * .28,
                  child: _FloatingContextRail(selectedIndex: selectedIndex),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          body: Padding(
            padding: const EdgeInsets.only(bottom: 92),
            child: content,
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: MorphingNavigationIsland(selectedIndex: selectedIndex),
          ),
        );
      },
    );
  }
}

class MorphingNavigationIsland extends StatelessWidget {
  const MorphingNavigationIsland({required this.selectedIndex, super.key});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Primary navigation',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: FlightColors.glassHigh.withValues(alpha: .82),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0x443DB8FF)),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x55000000), blurRadius: 30, offset: Offset(0, 12)),
              ],
            ),
            child: Row(
              children: List<Widget>.generate(flightDestinations.length, (int index) {
                final destination = flightDestinations[index];
                final selected = index == selectedIndex;
                return Expanded(
                  flex: selected ? 2 : 1,
                  child: _MorphingDestination(
                    destination: destination,
                    selected: selected,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _MorphingDestination extends StatelessWidget {
  const _MorphingDestination({
    required this.destination,
    required this.selected,
  });

  final FlightDestination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    void activate() {
      HapticFeedback.selectionClick();
      context.go(destination.path);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      onTap: activate,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: activate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? FlightColors.skyBlue.withValues(alpha: .18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: selected
                        ? FlightColors.skyBlue.withValues(alpha: .34)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: selected
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      selected
                          ? destination.selectedIcon
                          : destination.icon,
                      color: selected
                          ? FlightColors.aeroCyan
                          : FlightColors.muted,
                      size: 23,
                    ),
                    if (selected) ...<Widget>[
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          destination.label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

class _AdaptiveToolDock extends StatelessWidget {
  const _AdaptiveToolDock({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: FlightColors.glass,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0x333DB8FF)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(flightDestinations.length, (int index) {
          final destination = flightDestinations[index];
          final selected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Tooltip(
              message: destination.label,
              child: IconButton.filledTonal(
                isSelected: selected,
                onPressed: () => context.go(destination.path),
                icon: Icon(selected ? destination.selectedIcon : destination.icon),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FloatingContextRail extends StatelessWidget {
  const _FloatingContextRail({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: FlightColors.glassHigh.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0x333DB8FF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(flightDestinations.length, (int index) {
              final destination = flightDestinations[index];
              return IconButton(
                tooltip: destination.label,
                isSelected: index == selectedIndex,
                onPressed: () => context.go(destination.path),
                icon: Icon(index == selectedIndex ? destination.selectedIcon : destination.icon),
              );
            }),
          ),
        ),
      ),
    );
  }
}

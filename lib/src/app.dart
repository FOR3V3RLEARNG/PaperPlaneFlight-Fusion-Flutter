import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'features/characters/character_select_page.dart';
import 'features/hangar/hangar_page.dart';
import 'features/home/home_page.dart';
import 'features/multiplayer/multiplayer_mode_page.dart';
import 'features/multiplayer/remote_lobby_page.dart';
import 'features/multiplayer/split_screen_race_page.dart';
import 'features/race/race_page.dart';
import 'features/results/race_results_page.dart';
import 'game/models/race_models.dart';

final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const HomePage()),
  GoRoute(path: '/multiplayer', builder: (_, __) => const MultiplayerModePage()),
  GoRoute(path: '/hangar', builder: (_, __) => const HangarPage()),
  GoRoute(
    path: '/character-select',
    builder: (_, state) {
      final launch = state.extra;
      final resolved = launch is CharacterSelectLaunch ? launch : const CharacterSelectLaunch(CharacterSelectMode.rival);
      return CharacterSelectPage(mode: resolved.mode, worldId: resolved.worldId, bossRace: resolved.bossRace);
    },
  ),
  GoRoute(path: '/race', builder: (_, state) => RacePage(launch: state.extra as RaceLaunch)),
  GoRoute(
    path: '/split-race',
    builder: (_, state) => SplitScreenRacePage(launch: state.extra is SplitRaceLaunch ? state.extra as SplitRaceLaunch : const SplitRaceLaunch()),
  ),
  GoRoute(path: '/remote-lobby', builder: (_, state) => RemoteLobbyPage(selection: state.extra as RemotePilotSelection?)),
  GoRoute(path: '/results', builder: (_, state) => RaceResultsPage(result: state.extra as RaceResult?)),
  GoRoute(path: '/split-results', builder: (_, state) => SplitRaceResultsPage(payload: state.extra as SplitResultPayload?)),
]);

class PaperPlaneFlightApp extends StatelessWidget {
  const PaperPlaneFlightApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Paper Plane Flight',
        debugShowCheckedModeBanner: false,
        theme: flightTheme(),
        routerConfig: _router,
      );
}

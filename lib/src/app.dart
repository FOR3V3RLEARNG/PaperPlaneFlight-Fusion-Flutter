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
  GoRoute(path: '/', builder: (_, _) => const HomePage()),
  GoRoute(path: '/multiplayer', builder: (_, _) => const MultiplayerModePage()),
  GoRoute(path: '/hangar', builder: (_, _) => const HangarPage()),
  GoRoute(
    path: '/character-select',
    builder: (_, state) {
      final launch = state.extra;
      final resolved = launch is CharacterSelectLaunch ? launch : const CharacterSelectLaunch(CharacterSelectMode.rival);
      return CharacterSelectPage(mode: resolved.mode, worldId: resolved.worldId, bossRace: resolved.bossRace);
    },
  ),
  GoRoute(path: '/race', builder: (_, state) => RacePage(launch: state.extra is RaceLaunch ? state.extra as RaceLaunch : const RaceLaunch(worldId: 'sky_islands', wingLevel: 1))),
  GoRoute(
    path: '/split-race',
    builder: (_, state) => SplitScreenRacePage(launch: state.extra is SplitRaceLaunch ? state.extra as SplitRaceLaunch : const SplitRaceLaunch()),
  ),
  GoRoute(path: '/remote-lobby', builder: (_, state) => RemoteLobbyPage(selection: state.extra is RemotePilotSelection ? state.extra as RemotePilotSelection : null)),
  GoRoute(path: '/results', builder: (_, state) => RaceResultsPage(result: state.extra is RaceResult ? state.extra as RaceResult : null)),
  GoRoute(path: '/split-results', builder: (_, state) => SplitRaceResultsPage(payload: state.extra is SplitResultPayload ? state.extra as SplitResultPayload : null)),
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

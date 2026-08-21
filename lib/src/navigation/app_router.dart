import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/flight/flight_page.dart';
import '../features/hangar/hangar_page.dart';
import '../features/home/home_page.dart';
import '../features/map/level_detail_page.dart';
import '../features/map/world_map_page.dart';
import '../features/missions/missions_page.dart';
import '../features/profile/profile_page.dart';
import 'adaptive_shell.dart';

final appRouterProvider = Provider<GoRouter>((_) {
  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AdaptiveShell(location: state.uri.path, child: child);
        },
        routes: <RouteBase>[
          GoRoute(path: '/home', builder: (_, _) => const HomePage()),
          GoRoute(
            path: '/map',
            builder: (_, _) => const WorldMapPage(),
            routes: <RouteBase>[
              GoRoute(
                path: 'level/:levelId',
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return _sharedAxisPage(
                    state,
                    LevelDetailPage(levelId: state.pathParameters['levelId'] ?? '1-1'),
                    SharedAxisTransitionType.scaled,
                  );
                },
              ),
            ],
          ),
          GoRoute(path: '/hangar', builder: (_, _) => const HangarPage()),
          GoRoute(path: '/missions', builder: (_, _) => const MissionsPage()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        ],
      ),
      GoRoute(
        path: '/flight',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return _sharedAxisPage(state, const FlightPage(), SharedAxisTransitionType.scaled);
        },
      ),
    ],
  );
});

CustomTransitionPage<void> _sharedAxisPage(
  GoRouterState state,
  Widget child,
  SharedAxisTransitionType type,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    child: child,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget transitionChild,
    ) {
      final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) return transitionChild;
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
        fillColor: Colors.transparent,
        child: transitionChild,
      );
    },
  );
}

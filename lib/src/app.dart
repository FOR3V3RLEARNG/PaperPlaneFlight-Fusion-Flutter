import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'navigation/app_router.dart';

class PaperPlaneFlightApp extends ConsumerWidget {
  const PaperPlaneFlightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Paper Plane Flight',
      theme: buildFlightTheme(),
      routerConfig: router,
      restorationScopeId: 'paper_plane_flight',
    );
  }
}

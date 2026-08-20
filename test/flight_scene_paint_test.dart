import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/features/flight/flight_scene.dart';

void main() {
  testWidgets('paper plane CustomPainter renders without paint exceptions',
      (WidgetTester tester) async {
    final sceneKey = GlobalKey<FlightSceneState>();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlightScene(
            key: sceneKey,
            onSnapshot: (_) {},
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);

    sceneKey.currentState!.boost();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}

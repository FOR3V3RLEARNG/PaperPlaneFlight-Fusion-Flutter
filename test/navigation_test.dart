import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/app.dart';

void main() {
  testWidgets('morphing navigation keeps destination orientation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: PaperPlaneFlightApp()));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.bySemanticsLabel('World'));
    await tester.pumpAndSettle();

    expect(find.text('SKY ATLAS'), findsOneWidget);
    expect(find.bySemanticsLabel('World'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

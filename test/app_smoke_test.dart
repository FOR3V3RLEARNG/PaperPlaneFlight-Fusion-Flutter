import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/app.dart';

void main() {
  testWidgets('home shell renders on a compact phone', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: PaperPlaneFlightApp()));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.textContaining('CHASE'), findsOneWidget);
    expect(find.bySemanticsLabel('Primary navigation'), findsOneWidget);
    expect(find.bySemanticsLabel('Open flight commands'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

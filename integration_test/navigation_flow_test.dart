import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paper_plane_flight/src/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('core player journey stays navigable', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PaperPlaneFlightApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('CHASE'), findsOneWidget);

    await tester.tap(find.text('Start Flight'));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('SWIPE TO STEER'), findsOneWidget);

    await tester.tap(find.byTooltip('Return to previous screen'));
    await tester.pumpAndSettle();
    expect(find.textContaining('CHASE'), findsOneWidget);
  });
}

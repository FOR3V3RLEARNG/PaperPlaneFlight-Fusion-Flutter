import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/core/theme.dart';
import 'package:paper_plane_flight/src/widgets/morphing_metric.dart';

void main() {
  testWidgets('metric pill expands into analytics surface', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFlightTheme(),
        home: const Scaffold(
          body: Center(
            child: MorphingMetric(
              label: 'Control',
              value: '91',
              unit: '/100',
              accent: FlightColors.skyBlue,
              details: <String>['Turn response 94%', 'Wind stability 89%'],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Turn response 94%'), findsNothing);
    await tester.tap(find.text('Control'));
    await tester.pumpAndSettle();
    expect(find.text('Turn response 94%'), findsOneWidget);
  });
}

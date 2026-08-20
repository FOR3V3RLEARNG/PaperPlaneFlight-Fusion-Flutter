import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/app.dart';
import 'package:paper_plane_flight/src/features/flight/flight_page.dart';
import 'package:paper_plane_flight/src/features/home/home_page.dart';

void main() {
  testWidgets('core player journey stays navigable',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PaperPlaneFlightApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.textContaining('CHASE'), findsOneWidget);

    await tester.tap(find.text('Start Flight'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FlightPage), findsOneWidget);
    expect(
      find.byTooltip('Return to previous screen'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Return to previous screen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.textContaining('CHASE'), findsOneWidget);
  });
}

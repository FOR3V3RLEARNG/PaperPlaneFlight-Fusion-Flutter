import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/app.dart';

void main() {
  testWidgets('app boots into the home workspace', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PaperPlaneFlightApp()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('CHASE'), findsOneWidget);
    expect(find.text('Start Flight'), findsOneWidget);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/app.dart';

void main() {
  testWidgets('home exposes pilot and multiplayer entry points', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PaperPlaneFlightApp()));
    await tester.pumpAndSettle();
    expect(find.text('Choose Race Mode'), findsOneWidget);
    expect(find.text('Choose Pilot & Quick Race'), findsOneWidget);
  });
}

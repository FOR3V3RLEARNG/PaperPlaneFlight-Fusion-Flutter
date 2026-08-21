import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paper_plane_flight/src/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('home opens multiplayer mode', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PaperPlaneFlightApp()));
    await tester.pumpAndSettle();
    expect(find.text('Choose Race Mode'), findsOneWidget);
    await tester.tap(find.text('Choose Race Mode'));
    await tester.pumpAndSettle();
    expect(find.text('Local Split Screen'), findsOneWidget);
    expect(find.text('Separate Device Race'), findsOneWidget);
  });
}

#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${1:-$HOME/PaperPlaneFlight_FusionAI_v1}"
cd "$ROOT"

TEST="test/player_journey_test.dart"

cat > "$TEST" <<'DART'
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
DART

git diff --check

echo
echo "Player journey test diff:"
git --no-pager diff -- "$TEST"

git add "$TEST"

if git diff --cached --quiet; then
  echo "No staged test change."
  exit 0
fi

git commit -m "Make player journey test route-stable"
git push origin main

echo
echo "Waiting for GitHub Actions..."
sleep 8

gh run list \
  --workflow "Paper Plane Flight Green Gate" \
  --branch main \
  --limit 5

RUN_ID="$(gh run list \
  --workflow "Paper Plane Flight Green Gate" \
  --branch main \
  --limit 1 \
  --json databaseId \
  --jq '.[0].databaseId')"

echo
echo "New run: $RUN_ID"
echo "Watch with:"
echo "  gh run watch $RUN_ID"

#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${1:-$HOME/PaperPlaneFlight_FusionAI_v1}"
cd "$ROOT"

FILE="lib/src/features/flight/flight_scene.dart"
TEST="test/flight_scene_paint_test.dart"

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found in $ROOT" >&2
  exit 1
fi

python - <<'PY'
from pathlib import Path

path = Path("lib/src/features/flight/flight_scene.dart")
source = path.read_text()

old = """        ..shader = ui.Gradient.linear(
          Offset(-s, -s),
          Offset(s, s),
          const <Color>[Colors.white, Color(0xFFE6F3FF), FlightColors.violet],
        ),
"""

new = """        ..shader = ui.Gradient.linear(
          Offset(-s, -s),
          Offset(s, s),
          const <Color>[
            Colors.white,
            Color(0xFFE6F3FF),
            FlightColors.violet,
          ],
          const <double>[0, .62, 1],
        ),
"""

if old not in source:
    raise SystemExit(
        "Expected paper-plane gradient block was not found. "
        "Refusing to patch blindly."
    )

path.write_text(source.replace(old, new, 1))
PY

cat > "$TEST" <<'DART'
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
DART

git diff --check

echo
echo "Flight painter fix:"
git --no-pager diff -- "$FILE" "$TEST"

git add "$FILE" "$TEST"

if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git commit -m "Fix paper plane gradient paint crash"
git push origin main

echo
echo "Waiting for Green Gate..."
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
echo "Watch it with:"
echo "  gh run watch $RUN_ID"

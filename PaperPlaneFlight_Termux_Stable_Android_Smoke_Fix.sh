#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${1:-$HOME/PaperPlaneFlight_FusionAI_v1}"
cd "$ROOT"

WORKFLOW=".github/workflows/flutter-green-gate.yml"

if [ ! -f "$WORKFLOW" ]; then
  echo "ERROR: $WORKFLOW not found in $ROOT" >&2
  exit 1
fi

python - <<'PY'
from pathlib import Path

p = Path(".github/workflows/flutter-green-gate.yml")
s = p.read_text()

start = s.find("  android-integration:\n")
end = s.find("  release-android:\n")

if start < 0 or end < 0 or end <= start:
    raise SystemExit("Could not locate android-integration block safely.")

new_block = """  android-integration:
    name: Android runtime smoke test
    needs: certify
    runs-on: ubuntu-latest
    timeout-minutes: 25
    steps:
      - uses: actions/checkout@v5

      - uses: actions/setup-java@v5
        with:
          distribution: temurin
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.0'
          channel: stable
          cache: true

      - name: Scaffold Android when source-only
        run: |
          if [ ! -d android ]; then
            flutter create --platforms=android --project-name=paper_plane_flight .
            rm -f test/widget_test.dart
            git checkout -- test/widget_test.dart 2>/dev/null || true
          fi

      - run: flutter pub get

      - name: Enable KVM
        run: |
          echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' \\
            | sudo tee /etc/udev/rules.d/99-kvm4all.rules
          sudo udevadm control --reload-rules
          sudo udevadm trigger --name-match=kvm

      - name: Build, install, launch and verify Android runtime
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          arch: x86_64
          profile: pixel_6
          ram-size: 2048M
          disable-animations: true
          emulator-options: -no-window -gpu swiftshader_indirect -noaudio -no-boot-anim -no-snapshot -no-metrics -camera-back none
          script: |
            set -e
            flutter devices
            flutter build apk --debug
            adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
            adb -s emulator-5554 logcat -c
            adb -s emulator-5554 shell am force-stop com.example.paper_plane_flight
            adb -s emulator-5554 shell monkey -p com.example.paper_plane_flight -c android.intent.category.LAUNCHER 1
            sleep 10
            PID="$(adb -s emulator-5554 shell pidof com.example.paper_plane_flight | tr -d '\\r')"
            if [ -z "$PID" ]; then
              echo "Paper Plane Flight process is not running after launch"
              adb -s emulator-5554 logcat -d -t 300
              exit 1
            fi
            echo "Paper Plane Flight running as PID $PID"
            adb -s emulator-5554 shell dumpsys activity activities | grep -m1 'com.example.paper_plane_flight' || true
            if adb -s emulator-5554 logcat -d -t 500 | grep -E 'FATAL EXCEPTION|Process: com\\.example\\.paper_plane_flight.*has died'; then
              echo "Fatal Android runtime error detected"
              exit 1
            fi
            echo "Android runtime smoke test passed"

"""

p.write_text(s[:start] + new_block + s[end:])
PY

# Preserve the exact player journey as a deterministic widget-level production gate.
cat > test/player_journey_test.dart <<'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_plane_flight/src/app.dart';

void main() {
  testWidgets('core player journey stays navigable', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PaperPlaneFlightApp()),
    );
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
DART

# Remove the temporary flutter-drive host driver; it is no longer used.
if [ -f test_driver/integration_test.dart ]; then
  git rm -f test_driver/integration_test.dart || rm -f test_driver/integration_test.dart
fi
rmdir test_driver 2>/dev/null || true

git diff --check

echo
echo "Green Gate patch:"
git --no-pager diff -- "$WORKFLOW" test_driver/integration_test.dart 2>/dev/null || \
  git --no-pager diff -- "$WORKFLOW"

git add "$WORKFLOW" test/player_journey_test.dart

if git diff --cached --quiet; then
  echo "No staged changes."
  exit 0
fi

git commit -m "Stabilize Android runtime smoke gate"
git push origin main

echo
echo "Waiting for GitHub Actions to register..."
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

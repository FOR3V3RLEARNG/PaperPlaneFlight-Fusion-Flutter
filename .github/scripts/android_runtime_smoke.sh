#!/usr/bin/env bash
set -Eeuo pipefail

DEVICE="emulator-5554"
APP_ID="com.example.paper_plane_flight"
APK="build/app/outputs/flutter-apk/app-debug.apk"

echo "=== Flutter devices ==="
flutter devices

echo "=== Build debug APK ==="
flutter build apk --debug

test -f "$APK" || {
  echo "APK was not created: $APK"
  exit 1
}

echo "=== Wait for emulator ==="
adb -s "$DEVICE" wait-for-device

BOOT_COMPLETED=""
for attempt in {1..30}; do
  BOOT_COMPLETED="$(adb -s "$DEVICE" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
  if [[ "$BOOT_COMPLETED" == "1" ]]; then
    break
  fi

  echo "Waiting for Android boot... ($attempt/30)"
  sleep 2
done

if [[ "$BOOT_COMPLETED" != "1" ]]; then
  echo "Android emulator did not finish booting"
  adb devices -l || true
  exit 1
fi

echo "=== Install APK ==="
adb -s "$DEVICE" install -r "$APK"

echo "=== Clear previous logs ==="
adb -s "$DEVICE" logcat -c

echo "=== Launch Paper Plane Flight ==="
adb -s "$DEVICE" shell am force-stop "$APP_ID"

adb -s "$DEVICE" shell monkey \
  -p "$APP_ID" \
  -c android.intent.category.LAUNCHER \
  1

sleep 10

echo "=== Verify process ==="
PID="$(adb -s "$DEVICE" shell pidof "$APP_ID" 2>/dev/null | tr -d '\r' || true)"

if [[ -z "$PID" ]]; then
  echo "Paper Plane Flight process is not running after launch"
  echo "=== Recent Android log ==="
  adb -s "$DEVICE" logcat -d -t 500 || true
  exit 1
fi

echo "Paper Plane Flight running as PID $PID"

echo "=== Foreground activity ==="
adb -s "$DEVICE" shell dumpsys activity activities \
  | grep -m1 "$APP_ID" \
  || true

echo "=== Check fatal application errors ==="

LOG_FILE="$(mktemp)"
adb -s "$DEVICE" logcat -d -t 500 > "$LOG_FILE" || true

if grep -E \
  "FATAL EXCEPTION|Process: ${APP_ID//./\\.}.*has died" \
  "$LOG_FILE"; then
  echo "Fatal Android runtime error detected"
  cat "$LOG_FILE"
  rm -f "$LOG_FILE"
  exit 1
fi

rm -f "$LOG_FILE"

echo "======================================="
echo "Android runtime smoke test PASSED"
echo "Package: $APP_ID"
echo "PID: $PID"
echo "======================================="

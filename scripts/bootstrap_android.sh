#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found in PATH." >&2
  exit 127
fi

flutter --version
flutter create --platforms=android --project-name=paper_plane_flight .
flutter pub get
dart format --output=none lib test integration_test
flutter analyze --fatal-warnings
flutter test
flutter test integration_test
flutter build apk --release
flutter build appbundle --release

echo "Green Gate complete."
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
echo "AAB: build/app/outputs/bundle/release/app-release.aab"

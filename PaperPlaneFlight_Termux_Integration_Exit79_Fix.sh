#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${1:-$HOME/PaperPlaneFlight_FusionAI_v1}"
cd "$ROOT"

WORKFLOW=".github/workflows/flutter-green-gate.yml"
DRIVER="test_driver/integration_test.dart"

if [ ! -f "$WORKFLOW" ]; then
  echo "ERROR: $WORKFLOW not found in $ROOT" >&2
  exit 1
fi

mkdir -p test_driver

cat > "$DRIVER" <<'DART'
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
DART

python - <<'PY'
from pathlib import Path

path = Path(".github/workflows/flutter-green-gate.yml")
source = path.read_text()

# Clear current GitHub Actions Node 20 deprecation warnings.
source = source.replace("actions/checkout@v4", "actions/checkout@v5")
source = source.replace("actions/setup-java@v4", "actions/setup-java@v5")

old = """          script: |
            flutter devices
            flutter test integration_test/navigation_flow_test.dart
"""

new = """          script: |
            flutter devices
            flutter drive \\
              --driver=test_driver/integration_test.dart \\
              --target=integration_test/navigation_flow_test.dart \\
              -d emulator-5554 \\
              --no-dds
"""

if old not in source:
    raise SystemExit(
        "Expected Android integration command was not found; refusing to patch blindly."
    )

path.write_text(source.replace(old, new, 1))
PY

git diff --check

echo
echo "CI repair diff:"
git --no-pager diff -- "$WORKFLOW" "$DRIVER"

git add "$WORKFLOW" "$DRIVER"

if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git commit -m "Run Android integration journey with Flutter drive"
git push origin main

echo
echo "Waiting for GitHub Actions to register the push..."
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

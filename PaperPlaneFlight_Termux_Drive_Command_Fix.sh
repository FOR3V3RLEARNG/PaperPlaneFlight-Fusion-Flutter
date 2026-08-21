#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${1:-$HOME/PaperPlaneFlight_FusionAI_v1}"
cd "$ROOT"

WORKFLOW=".github/workflows/flutter-green-gate.yml"

python - <<'PY'
from pathlib import Path

p = Path(".github/workflows/flutter-green-gate.yml")
s = p.read_text()

old = """          script: |
            flutter devices
            flutter drive \\
              --driver=test_driver/integration_test.dart \\
              --target=integration_test/navigation_flow_test.dart \\
              -d emulator-5554 \\
              --no-dds
"""

new = """          script: |
            flutter devices
            flutter drive --driver=test_driver/integration_test.dart --target=integration_test/navigation_flow_test.dart -d emulator-5554 --no-dds
"""

if old not in s:
    raise SystemExit(
        "Expected multiline flutter drive block was not found. "
        "Open .github/workflows/flutter-green-gate.yml and inspect the emulator script."
    )

p.write_text(s.replace(old, new, 1))
PY

git diff --check

echo
echo "Workflow change:"
git --no-pager diff -- "$WORKFLOW"

git add "$WORKFLOW"

if git diff --cached --quiet; then
  echo "No staged workflow change."
  exit 0
fi

git commit -m "Fix Android integration driver command"
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

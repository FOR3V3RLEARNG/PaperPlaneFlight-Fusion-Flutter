#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PATCH_DEFAULT="$HOME/storage/downloads/PaperPlaneFlight_FusionAI_v1_CI_Fix.patch"
PATCH_FILE="${PATCH_FILE:-$PATCH_DEFAULT}"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO="$(git rev-parse --show-toplevel)"
elif [ -d "$HOME/PaperPlaneFlight_FusionAI_v1/.git" ]; then
  REPO="$HOME/PaperPlaneFlight_FusionAI_v1"
elif [ -d "$HOME/PaperPlaneFlight-Fusion-Flutter/.git" ]; then
  REPO="$HOME/PaperPlaneFlight-Fusion-Flutter"
else
  echo "Run this from the Paper Plane Flight git repository, or clone it first." >&2
  exit 1
fi

cd "$REPO"

echo "Repository: $REPO"
echo "Branch: $(git branch --show-current)"

if [ ! -f "$PATCH_FILE" ]; then
  echo "Patch not found: $PATCH_FILE" >&2
  echo "Download PaperPlaneFlight_FusionAI_v1_CI_Fix.patch into Android Downloads first." >&2
  exit 1
fi

if git apply --check "$PATCH_FILE" >/dev/null 2>&1; then
  git apply "$PATCH_FILE"
  echo "Applied CI fix patch."
elif git apply --reverse --check "$PATCH_FILE" >/dev/null 2>&1; then
  echo "Patch is already applied; continuing."
else
  echo "Patch does not cleanly apply. Showing repository status:" >&2
  git status --short >&2
  exit 2
fi

git diff --check

git add \
  .github/workflows/flutter-green-gate.yml \
  integration_test/navigation_flow_test.dart \
  lib/src/core/theme.dart \
  lib/src/features/hangar/hangar_page.dart \
  lib/src/navigation/app_router.dart \
  lib/src/widgets/morphing_metric.dart \
  scripts/bootstrap_android.sh \
  test/widget_test.dart

if git diff --cached --quiet; then
  echo "No new changes to commit."
else
  git commit -m "Fix Flutter Green Gate analyzer failures"
  git push origin "$(git branch --show-current)"
fi

echo
echo "Latest workflow runs:"
gh run list --workflow "Paper Plane Flight Green Gate" --limit 5 || true

echo
echo "To watch the newest run:"
echo "  gh run watch"

#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="${1:-$HOME/PaperPlaneFlight_FusionAI_v1}"
cd "$ROOT"

FILE="lib/src/navigation/adaptive_shell.dart"

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found in $ROOT" >&2
  exit 1
fi

python - <<'PY'
from pathlib import Path

path = Path("lib/src/navigation/adaptive_shell.dart")
source = path.read_text()

start_marker = "class _MorphingDestination extends StatelessWidget {"
end_marker = "class _AdaptiveToolDock extends StatelessWidget {"

start = source.find(start_marker)
end = source.find(end_marker)

if start < 0 or end < 0 or end <= start:
    raise SystemExit(
        "Could not locate _MorphingDestination safely; refusing to patch blindly."
    )

replacement = 'class _MorphingDestination extends StatelessWidget {\n  const _MorphingDestination({\n    required this.destination,\n    required this.selected,\n  });\n\n  final FlightDestination destination;\n  final bool selected;\n\n  @override\n  Widget build(BuildContext context) {\n    void activate() {\n      HapticFeedback.selectionClick();\n      context.go(destination.path);\n    }\n\n    return Semantics(\n      button: true,\n      selected: selected,\n      label: destination.label,\n      onTap: activate,\n      child: ExcludeSemantics(\n        child: Padding(\n          padding: const EdgeInsets.symmetric(horizontal: 2),\n          child: Material(\n            color: Colors.transparent,\n            child: InkWell(\n              customBorder: const StadiumBorder(),\n              onTap: activate,\n              child: AnimatedContainer(\n                duration: const Duration(milliseconds: 300),\n                curve: Curves.easeOutCubic,\n                padding: EdgeInsets.symmetric(\n                  horizontal: selected ? 12 : 8,\n                ),\n                decoration: BoxDecoration(\n                  color: selected\n                      ? FlightColors.skyBlue.withValues(alpha: .18)\n                      : Colors.transparent,\n                  borderRadius: BorderRadius.circular(28),\n                  border: Border.all(\n                    color: selected\n                        ? FlightColors.skyBlue.withValues(alpha: .34)\n                        : Colors.transparent,\n                  ),\n                ),\n                child: Row(\n                  mainAxisAlignment: selected\n                      ? MainAxisAlignment.start\n                      : MainAxisAlignment.center,\n                  children: <Widget>[\n                    Icon(\n                      selected\n                          ? destination.selectedIcon\n                          : destination.icon,\n                      color: selected\n                          ? FlightColors.aeroCyan\n                          : FlightColors.muted,\n                      size: 23,\n                    ),\n                    if (selected) ...<Widget>[\n                      const SizedBox(width: 7),\n                      Expanded(\n                        child: Text(\n                          destination.label,\n                          maxLines: 1,\n                          softWrap: false,\n                          overflow: TextOverflow.ellipsis,\n                        ),\n                      ),\n                    ],\n                  ],\n                ),\n              ),\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}\n\n'

path.write_text(source[:start] + replacement + source[end:])
PY

git diff --check

echo
echo "Navigation patch applied:"
git diff -- "$FILE"

git add "$FILE"

if git diff --cached --quiet; then
  echo "No staged changes; nothing to commit."
  exit 0
fi

git commit -m "Fix compact morphing navigation overflow and semantics"
git push origin main

echo
echo "Latest Green Gate runs:"
gh run list --workflow "Paper Plane Flight Green Gate" --limit 3

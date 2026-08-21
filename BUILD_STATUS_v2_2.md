# Build status — v2.2 Character Roster (+ Hangar economy wiring)

## Wiring pass (post-review)
Previously dead code is now reachable from the UI:
- `TokenWalletRepository` (new) persists a running token balance across races.
- `WingProgressionRepository.upgrade()` now atomically spends tokens and
  advances the wing level (was previously never called from anywhere).
- Rival races spawn collectible `TokenPickupComponent`s; `RivalRaceGame.collectToken()`
  is now actually invoked, so `RaceResult.tokens` is no longer always 0.
- New `HangarPage` (`/hangar`) lists all 8 `raceWorlds`, shows per-world wing
  level + upgrade cost, and unlocks "Challenge Boss" once a world hits wing 10.
- `RaceResultsPage` persists earned tokens and marks bosses cleared on a boss-race win.
- `CharacterSelectPage` now sources the player's wing level from Hangar
  progression for Rival Race (read-only, "upgrade in the Hangar") instead of
  a free 1–10 slider; boss races force both wings to level 10.
- Home screen and the Rival Race mode card now route through the Hangar first.

Split Screen and Separate Device modes are unchanged — they intentionally stay
on the free wing slider since there's no shared single-player economy to gate
local head-to-head play.


Completed in this environment:
- local Dart source import-resolution checks: PASS
- delimiter/structure checks: PASS
- YAML workflow parse: PASS
- shell syntax: PASS
- requested roster presence: PASS
- licensed Pink Panther slot locked by default: PASS
- credential-pattern scan: PASS

Not executed locally:
- `flutter pub get`
- `dart format`
- `flutter analyze`
- `flutter test`
- APK/AAB compilation

Reason: Flutter/Dart is not installed in this execution container. `.github/workflows/paper-plane-flight-green-gate.yml` performs those actual gates on GitHub using Flutter 3.47.0 plus a 3.44.7 compatibility lane.

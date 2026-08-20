# Paper Plane Flight — Fusion AI Flutter Build

A source-complete Flutter game concept built from the Fusion AI v3 design and production architecture. The experience uses Material 3 Expressive principles, responsive navigation, procedural CustomPainter graphics, spatially continuous transitions, meaningful haptics, Riverpod state, go_router navigation and Green Gate CI.

## What is implemented

- Playable paper-plane flight scene rendered procedurally with CustomPainter.
- Drag/swipe steering, rings, stars, boost energy, combo scoring, motion trails and haptic feedback.
- Morphing navigation island on phones, floating contextual rail on medium layouts, and adaptive tool dock on large layouts.
- Compact command button that expands into an inline command/search surface.
- Metric pills that transform into detailed analytics surfaces.
- Mission progress ring that unfolds into an interactive timeline.
- Shared-axis route transitions plus Hero origin continuity for world-map level details.
- Responsive Home, Sky Atlas, Hangar, Missions and Pilot workspaces.
- Material 3 dark glass visual system using FlexColorScheme.
- Reduced-motion awareness, semantic labels, large touch targets and system-scaled typography.
- Unit, widget and integration tests plus GitHub Actions APK/AAB Green Gate.

## Run

```bash
flutter pub get
flutter run
```

## Verify

```bash
dart format --output=none lib test integration_test
flutter analyze --fatal-warnings
flutter test
flutter test integration_test
```

## Android release

This repository is intentionally source-only so it stays portable. If platform folders are absent:

```bash
flutter create --platforms=android --project-name=paper_plane_flight .
flutter pub get
flutter build apk --release
flutter build appbundle --release
```

The included GitHub Actions workflow performs the same certification matrix and publishes APK/AAB artifacts only after analyze and tests pass.

## Asset policy

The generated design boards are retained under `assets/reference/` as visual QA references. Gameplay graphics are rendered procedurally so the prototype is not dependent on raster screenshots. `assets/brand/` contains cropped reference marks ready for launcher/splash production treatment.

## Rive decision

Rive is intentionally not installed in this first code pass. The current experience already benefits materially from deterministic CustomPainter rendering for the plane, trails, sky and map. Add Rive only when a real `.riv` state machine exists for a specific high-value interaction (for example an authored launch sequence, animated mascot, or reward choreography). This keeps the production dependency surface smaller and avoids shipping an unused native runtime.

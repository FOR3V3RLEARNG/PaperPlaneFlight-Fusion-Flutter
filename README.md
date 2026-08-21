# PAPER PLANE FLIGHT v2.2 — Character Roster + Multiplayer

Flutter + Flame race upgrade with selectable pilots, 10-level wings, AI rival racing, local split screen and a separate-device lobby architecture.

## Selectable default pilots
YAALON, Uzziah, Nails, Wild Brats, Granny, George the Sky Monkey and Rose Panther.

The exact Pink Panther is represented only by a disabled **licensed character slot** until rights are provided.

## Race modes
1. Rival Race — one player versus AI.
2. Local Split Screen — two players on one phone/tablet in landscape.
3. Separate Device Race — room/lobby UI with transport separated from gameplay; ready for Supabase Realtime wiring without embedding credentials.

## Character gameplay
Each plane renders its selected tiny pilot. Pilot reactions include laughing, fist pumping, shock, ducking, frustration and celebration. Character palettes also influence the plane's wing accents and boost trail.

## Build
```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

GitHub workflow: `Paper Plane Flight Green Gate`.

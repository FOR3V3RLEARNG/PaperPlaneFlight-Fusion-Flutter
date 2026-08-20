# Dependency Compatibility Audit

Target baseline follows the Fusion v3 Flutter certification direction: Dart `>=3.12.0 <4.0.0`, with CI on Flutter `3.44.7` and `3.47.0`.

| Package | Selected | Reason |
|---|---:|---|
| flutter_riverpod | 3.4.2 | Matches Fusion v3 source and provides durable app/session state without coupling the 60fps render loop to global rebuilds. |
| go_router | 17.5.0 | Matches Fusion v3 source; declarative routing, ShellRoute and deep-link-ready paths. |
| flex_color_scheme | 8.4.0 | Material 3 theming; its published requirements are below the selected Dart/Flutter baseline. |
| animations | 2.2.0 | Flutter-published Material motion package. Chosen over the brand-new 3.0.0 release to reduce adoption risk while retaining SharedAxisTransition. |
| flutter_animate | 4.5.2 | Stable, production-used micro-animation layer for low-frequency UI entrances and state changes. |
| skeletonizer | 2.1.3 | Loading-state skeletons; minimum Dart requirement is below the project baseline. |
| Rive | not installed | The current build has no authored `.riv` state machine. Shipping `rive_native` without a real authored interaction would add native/runtime complexity with no user benefit. |
| Flame | not installed | Current game loop is intentionally small and benefits from direct CustomPainter control. Flame remains a future option when collision systems, component hierarchies or level scripting outgrow the lightweight renderer. |
| audioplayers | not installed | No final licensed audio assets are present yet. Add only when sound design is authored and testable. |

## Compatibility conclusion

The selected installed dependencies fit the Fusion Dart baseline and have clear responsibilities. Optional heavy/runtime dependencies are intentionally deferred until the feature value justifies them.

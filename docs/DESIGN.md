# DESIGN — Paper Plane Flight

## Product idea

Paper Plane Flight treats flight as a spatial workspace rather than a sequence of disconnected screens. The player should always understand where they are, what changed, and how to return.

## Design DNA

**Advanced but understandable. Expressive but disciplined. Immersive but efficient. Original but intuitive. Futuristic but believable.**

The visual language uses deep navy atmospheric surfaces, sky blue and aero-cyan motion accents, violet mastery states, sun-orange rewards, cloud-white type and restrained glass depth.

## Navigation model

### Compact phones

A morphing navigation island remains at the bottom in the expected platform location. The selected destination gains physical width, label emphasis and local color. Unselected destinations remain familiar icons. This increases state clarity without inventing a new navigation grammar.

### Medium layouts

The same destinations become a floating contextual rail. The content remains primary and the rail stays spatially stable.

### Expanded layouts

The navigation becomes an adaptive tool dock. Destinations preserve order and icon identity across breakpoints.

### Parent-child navigation

World-map nodes open detail views with Hero continuity and shared-axis motion. Back remains explicit. The level detail visually grows from the node the player touched.

## Morphing component rules

1. A compact Flight Command button expands into an inline command surface.
2. Metric pills expand in place into richer analytics panels.
3. The active bottom-navigation destination grows into the active workspace label.
4. Mission progress transforms from a passive ring into an interactive timeline.
5. Pause grows from a compact media control into a richer flight-control surface.
6. Motion always explains origin, priority or state change; decorative motion is secondary.

## Typography

- Large display type gives the product identity through controlled width, weight and spacing.
- Numerical displays use tabular figures.
- Variable font weight is animated where the current font supports variation axes; unsupported fonts simply ignore the axis and preserve readability.
- Selection uses size/weight before adding more color.

## Interaction feedback

- Boost compresses on touch before activation.
- Navigation changes use selection haptics.
- Ring collection uses light impact, stars use selection feedback, and perfect chains use medium impact.
- Haptics are sparse and semantic.
- The plane target follows pointer/finger position with smoothing rather than teleporting.

## Procedural graphics

CustomPainter is used for:

- faceted paper-plane geometry;
- neon flight trails;
- sky gradient and cloud layers;
- floating islands;
- rings and stars;
- world-map geography and route paths;
- Paper Plane brand mark.

This is a deliberate fit: these visuals benefit from deterministic vector-like rendering and frame-synchronous motion.

## Accessibility

- All primary navigation destinations expose semantic labels and selected state.
- Gameplay exposes an explanatory playfield semantic label.
- Controls use 48dp or larger target sizes.
- System reduced-motion preference disables nonessential scene bloom and route motion.
- Content uses system text scaling and responsive wrapping instead of hard text clipping.
- Color is never the only state indicator for locked/selected/progress states.

## Responsive behavior

- `< 720dp`: compact layout with morphing bottom island.
- `720–1099dp`: floating contextual rail.
- `>= 1100dp`: persistent adaptive tool dock.
- Content cards use Wrap/LayoutBuilder so state composition changes rather than merely shrinking.

## Production guardrails

- Keep gameplay frame updates local to the renderer; do not push 60fps frame state through Riverpod.
- Riverpod owns durable app/session state, not paint-loop state.
- Respect system accessibility settings.
- Do not add Rive, Flame, audio or analytics dependencies until a concrete feature requires them.
- No release success claim without CI evidence.

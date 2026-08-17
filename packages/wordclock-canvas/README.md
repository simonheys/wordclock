# WordClock Canvas

Framework-free canvas renderer for WordClock, published as `@wordclock/canvas`.

It computes an explicit position for every word and draws it to a canvas. The
[WordClock React](/packages/wordclock-js) package wraps this renderer with lifecycle, responsive
sizing, CSS theme colours, and accessibility. The core supports both the **rotary** layout from the
[macOS screen saver](/packages/wordclock-macos) and the staggered **transition** between linear and
rotary.

Zero runtime dependencies. No React, no DOM measurement, no reflow.

## Why canvas

Canvas `fillText` goes through the same platform text engine as DOM text — CoreText, DirectWrite, HarfBuzz — so kerning, standard ligatures and complex-script shaping are identical, provided each word is measured and drawn as a single run. Measured against the DOM across Latin, Arabic, Devanagari, Thai and CJK, advance widths agree to under 0.01px.

The one exception is kerning pairs that span a space, which canvas does not apply. No token in the bundled corpus is affected.

Canvas also means `measureText` is both the measuring and the drawing path, so layout and render agree by construction, and rotated words are rasterised at their true angle rather than being rotated bitmaps.

## Pipeline

```
parseWords  ->  measure  ->  layoutLinear / layoutRotary  ->  draw
                             (pure arithmetic)               (canvas)
```

Everything between `measure` and `draw` is arithmetic on measured widths. It touches no DOM, allocates nothing per frame, and is deterministic — which is what makes the transition testable without a timer.

```ts
import {
  createCanvasMetrics,
  createColourState,
  DEFAULT_PALETTE,
  draw,
  getTimeProps,
  layoutLinear,
  measure,
  parseWords,
  resizeCanvas,
  resolve,
  updateColours,
} from '@wordclock/canvas'
import words from '@wordclock/words/json/English.json'

const font = { family: 'system-ui, sans-serif', weight: 700 }
const context = canvas.getContext('2d')

// measureText silently falls back to a substitute font until the real one loads
await document.fonts.load(`${font.weight} 100px ${font.family}`)

const definition = measure(parseWords(words), createCanvasMetrics(context, font))
const colours = createColourState(definition.words.length)
const mask = new Uint8Array(definition.words.length)

const { width, height } = resizeCanvas(canvas, context, window.devicePixelRatio)
const { coordinates } = layoutLinear(definition, { width, height })

resolve(definition, getTimeProps(), mask)
updateColours(colours, mask, DEFAULT_PALETTE, performance.now())
draw(context, definition, coordinates, colours, { font })
```

## Rotary

One concentric ring per word group. Words are spokes reading radially outward, and each ring's radius starts where the previous ring's selected word ended — so the selected words lay end to end and the phrase reads straight across the wheel.

```ts
const state = refreshRotaryMetrics(createRotaryState(definition), definition)

let previous = performance.now()
const frame = (now: number) => {
  const deltaMs = Math.min(100, now - previous)
  resolve(definition, getTimeProps(), mask)
  updateRotaryState(state, definition, mask, now, deltaMs)
  const { coordinates } = layoutRotary(definition, state, { width, height })
  draw(context, definition, coordinates, colours, { font })
  previous = now
  requestAnimationFrame(frame)
}
requestAnimationFrame(frame)
```

Rings animate to bring the selected word to the reading line, taking the shorter way round, with the same `easeOutBack` over 300ms as the native version.

There is no fixed FPS cap: `requestAnimationFrame` follows the browser and display cadence, including 90Hz and 120Hz displays. All animation progress uses elapsed time, so duration and radial motion remain consistent across refresh rates.

## Transition

Every word gets its own delay, so the layout unfurls rather than snapping, and the order reverses on the way back to linear.

```ts
const transition = createTransition(definition, { style: 'slow', now: performance.now() })
const snapshot = cloneCoordinates(current) // freeze where we are

// each frame: the target stays live, so rings keep turning underneath
const done = advanceTransition(transition, performance.now())
const coordinates = tweenCoordinates(snapshot, target, transition.values)
```

Because progress is a pure function of elapsed time, a transition can be evaluated at any point without animating to it — useful for tests and for rendering a filmstrip.

## Scheduling

`parseWords` records which time fields the compiled expressions actually read, so a file that never mentions `second` need not tick every second:

```ts
setTimeout(tick, millisecondsUntilNextChange(definition))
```

## Options

|                                |                                                                                                                                                   |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pivot`                        | `'leading'` (default, matches macOS) or `'centre'`. Where a word rotates about. Settled layouts are identical; only the transition path differs.  |
| `shortestRotation`             | Default `true`. Takes each word by the smaller arc to the same final orientation. macOS lerps raw, which spins far-side words almost a full turn. |
| `highlightInFront`             | Default `true`. Draws highlighted words last so the dense rings cannot occlude them.                                                              |
| `tracking`, `leading`, `align` | Linear layout metrics.                                                                                                                            |
| `typeDivisor`                  | Rotary type size relative to the smaller container edge.                                                                                          |

`applyRotaryFit` can scale and translate rotary coordinates around either the highlighted phrase
or a caller-supplied maximum phrase width. `findLongestResolvedPhrase` finds the widest phrase that
can actually occur on a selected local day, so responsive sizing need not be based on a hypothetical
combination of words.

## Colours

Highlight transitions use one 150ms elapsed-time transition per word. Colour endpoints are mixed in perceptually uniform Oklab while alpha is interpolated separately, retaining the native version's asymmetry: highlighting on runs colour through `quadEaseIn` while alpha uses `quadEaseOut`; highlighting off uses `quadEaseOut` for both. An interrupted fade restarts from the colour currently on screen rather than snapping.

`DEFAULT_PALETTE` is the macOS factory default — black background, `0.25` grey foreground, white highlight.

## Direction

No token in the bundled corpus mixes scripts, so direction is a per-file property derived from `meta.language` rather than requiring the Unicode bidirectional algorithm. RTL files lay out from the right in linear, and read outward from 9 o'clock in rotary.

## Accessibility

The canvas is not readable by assistive technology. Render the highlighted phrase alongside it — a visually hidden `<time role="timer">` built from the words whose mask bit is set — and mark the canvas `aria-hidden`.

## Scripts

From the repository root:

```bash
pnpm --filter @wordclock/canvas build
pnpm --filter @wordclock/canvas test
pnpm --filter @wordclock/canvas typecheck
pnpm lint
```

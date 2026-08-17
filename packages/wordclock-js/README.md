# WordClock React

A React wrapper around the framework-free WordClock canvas renderer. It renders linear and rotary
layouts, animates between them at the display's native `requestAnimationFrame` cadence, and keeps
the canvas backing store in sync with the device pixel ratio.

The package does not choose or fetch word files. Loading remains the consuming app's responsibility.

## Usage

```bash
pnpm add @wordclock/react @wordclock/words
```

```tsx
import { WordClock, type WordsJson } from '@wordclock/react'
import english from '@wordclock/words/json/English_simple_fragmented.json'

export function Clock() {
  return (
    <div className="h-screen bg-white font-bold dark:bg-black">
      <WordClock
        words={english as WordsJson}
        foregroundClassName="text-neutral-300 dark:text-neutral-700"
        highlightClassName="text-red-500 dark:text-white"
      />
    </div>
  )
}
```

`WordClock` fills its parent and leaves the canvas transparent, so background classes stay on the
normal DOM container. The two colour class props are applied to hidden probe elements. Their
computed colours are passed into the renderer and are re-read when the document theme changes.
The browser resolves the resulting CSS colour before it reaches the renderer, including the
`lab(...)` values emitted by Tailwind's production transform and wide-gamut colour syntax.

Because Tailwind discovers classes statically, pass complete class names such as
`"text-red-500 dark:text-white"`; do not assemble them from fragments at runtime.

## Rotary layouts

```tsx
<WordClock
  words={words}
  layout="rotary"
  fit="phrase"
  fitMargin={8}
  foregroundClassName="text-neutral-500"
  highlightClassName="text-current"
/>
```

The rotary-specific props are:

- `fit="none"`: preserve the base wheel size.
- `fit="phrase"`: scale and translate so the longest phrase that can occur on the selected day is
  centred and fits the viewport.
- `fit="phrase-wheel-centred"`: keep the wheel centre fixed while scaling enough for that phrase to
  fit.
- `fit="phrase-centred-linear-scale"`: centre the current highlighted phrase and cap rotary type at
  the fitted linear-layout size; an already-smaller rotary layout is not enlarged.
- `fitMargin`: breathing room on every edge, as a percentage of the viewport's shorter side.
- `translateX` and `translateY`: final pixel offsets after fitting.
- `transitionStyle`: `"fast"`, `"medium"`, or `"slow"`.

Linear layout also accepts `tracking`, `leading`, and `align`. `leading` is extra line height as an
em fraction and defaults to `0`, matching CSS `line-height: 1` / Tailwind `leading-none`.

`WordClock` accepts normal `div` attributes. It includes an off-screen live `<time role="timer">`
containing the currently highlighted phrase, while the visual canvas is hidden from assistive
technology. Use the optional controlled `date` prop for previews and tests, and `onPhraseChange` if
the consumer needs the resolved phrase.

The old `WordClockContent`, `WordClockWord`, and render-per-word compound API is intentionally
removed: the React component now draws with canvas under the hood.

## Word files

The `words` prop uses the exported `WordsJson` shape. Each file contains:

- `meta.language`: language code used by the manifest
- `meta.title`: human-readable title for selectors and labels
- `groups`: ordered rows of `item`, `sequence`, and `space` entries

For language selectors, derive the consumer's option model from the word-file manifest and load the
selected JSON in the app. `@wordclock/words` publishes raw JSON, so a TypeScript consumer
normally asserts the imported value as `WordsJson` at that boundary.

React 18 and React 19 are supported as peer dependencies.

## Development

Run from the repository root:

```bash
pnpm --filter @wordclock/react test
pnpm --filter @wordclock/react typecheck
pnpm --filter @wordclock/react build
```

The build emits ESM, CommonJS, and TypeScript declarations under `dist`.

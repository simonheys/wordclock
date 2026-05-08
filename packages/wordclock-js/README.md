# WordClock React

React components for rendering a word clock in the browser.

The package renders a supplied word definition, highlights the words that match the current time, and fits the text to the component container.

## For Consumers

Install the React package and the word definitions package:

```bash
pnpm add @simonheys/wordclock @simonheys/wordclock-words
```

Render a clock with one of the bundled word files:

```tsx
import { WordClock, WordClockContent, type WordsJson } from '@simonheys/wordclock'
import english from '@simonheys/wordclock-words/json/English_simple_fragmented.json'

export function Clock() {
  return (
    <WordClock words={english as WordsJson}>
      <WordClockContent />
    </WordClock>
  )
}
```

`WordClock` accepts normal `div` attributes and passes them to the rendered words container. This is useful for styling, labels, and test IDs.

The package expects `react` and `react-dom` to be provided by the consuming app. Supported peer ranges are React 18 and React 19.

## Word Files

The `words` prop uses the `WordsJson` shape exported by this package. Each file contains:

- `meta.language`: language code used by the manifest
- `meta.title`: human-readable title for selectors and labels
- `groups`: ordered rows of `item`, `sequence`, and `space` entries

Use `@simonheys/wordclock-words` for the maintained set of bundled definitions.

## For Contributors

Run package commands from the repository root:

```bash
pnpm --filter @simonheys/wordclock test
pnpm --filter @simonheys/wordclock typecheck
pnpm --filter @simonheys/wordclock lint
pnpm --filter @simonheys/wordclock build
```

To exercise the package in the example app:

```bash
pnpm --filter @simonheys/wordclock build
pnpm --filter @simonheys/wordclock-example dev
```

The package build emits ESM, CommonJS, and TypeScript declaration files under `dist`.

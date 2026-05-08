# WordClock React

React components for rendering a word clock in the browser.

The package renders a supplied word definition, highlights the words that match the current time, and fits the text to the component container.
It does not choose, fetch, or index word files; loading is owned by the consuming app.

## For Consumers

Install the React package and the word definitions package:

```bash
pnpm add @simonheys/wordclock @simonheys/wordclock-words
```

Import one of the bundled word files and render it:

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

The assertion is intentionally at the app boundary: `@simonheys/wordclock-words` publishes raw JSON
rather than generated TypeScript modules.

For language selectors, derive whatever option model the consuming app needs from the manifest and
word-file `meta` fields. In an SSR app, do this on the server and pass only the small option model to
the client:

```ts
import type { WordsJson } from '@simonheys/wordclock'
import manifest from '@simonheys/wordclock-words/json/Manifest.json'

const options = await Promise.all(
  manifest.files.map(async (file) => {
    const wordFile = await import(`@simonheys/wordclock-words/json/${file}`)
    const words = wordFile.default as WordsJson

    return { file, label: words.meta.title }
  }),
)
```

Client-only apps can use the same data boundary, but should choose their own bundler strategy: static
imports, dynamic imports, an app-owned loader map, or a remote fetch layer.

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

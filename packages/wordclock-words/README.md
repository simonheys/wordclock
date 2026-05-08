# WordClock Words

Word definitions used by `@simonheys/wordclock` to describe time in different languages and styles.

The package entry point is `json/Manifest.json`. Individual word files are published from the `json` directory.

## For Consumers

Import the manifest to list available word files:

```ts
import type { Manifest } from '@simonheys/wordclock'
import manifest from '@simonheys/wordclock-words/json/Manifest.json'

const files = (manifest as Manifest).files
```

Import a specific word file to render it with the React package:

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

`Manifest.json` contains:

- `files`: JSON files available in this package
- `languages`: language-code to language-name mapping used for grouping selectors

## Word File Shape

Each word file contains:

- `meta.language`: language code, such as `en`
- `meta.title`: display title for the word file
- `groups`: ordered groups of word definitions

Group entries can be:

- `item`: one or more explicit words with highlight expressions
- `sequence`: generated words bound to `hour`, `minute`, or `second`
- `space`: blank slots used to influence layout

Highlight expressions are evaluated against time props such as `hour`, `twentyfourhour`, `minute`, `second`, `day`, `daystartingmonday`, `date`, and `month`.

## For Contributors

When adding or changing a word file:

- add the JSON file under `json`
- add the filename to `json/Manifest.json`
- ensure `meta.language` exists in the manifest language map
- run the validation tests

```bash
pnpm --filter @simonheys/wordclock-words test
```

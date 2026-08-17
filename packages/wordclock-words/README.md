# WordClock Words

Word definitions used by `@wordclock/react` to describe time in different languages and styles.

This package is intentionally thin: it publishes the raw word-definition JSON files and a manifest.
Consumers decide how to inspect, load, validate, cache, or bundle those files.
It does not publish loader helpers, generated TypeScript modules, or duplicated selector metadata.

## For Consumers

Import the manifest to list available word files:

```ts
import manifest from '@wordclock/words/json/Manifest.json'

const files = manifest.files
```

Import a specific word file when the consumer wants a static dependency:

```ts
import english from '@wordclock/words/json/English_simple_fragmented.json'
```

`Manifest.json` contains:

- `files`: JSON files available in this package
- `languages`: language-code to language-name mapping used for grouping selectors

The manifest is not an index of every word-file title. If a consumer needs titles or other selector
metadata, it should read the canonical `meta` object from the relevant word files.

## Word File Shape

Each word file contains:

- `meta.language`: language code, such as `en`
- `meta.title`: display title for the word file
- `groups`: ordered groups of word definitions

Group entries can be:

- `item`: one or more explicit words with highlight expressions
- `sequence`: generated words bound to date/time fields such as `hour`, `minute`, or `month`
- `space`: blank slots used to influence layout

Highlight expressions are evaluated against time props such as `hour`, `twentyfourhour`, `minute`, `second`, `day`, `daystartingmonday`, `date`, and `month`.

## For Contributors

When adding or changing a word file:

- add the JSON file under `json`
- add the filename to `json/Manifest.json`
- ensure `meta.language` exists in the manifest language map
- run the validation tests

```bash
pnpm --filter @wordclock/words test
```

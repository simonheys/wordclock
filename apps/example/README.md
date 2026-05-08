# WordClock Example

Next.js app for exercising `@simonheys/wordclock` against the bundled word files in `@simonheys/wordclock-words`.

## For Consumers

Use this app to inspect how the React package behaves with different language files and container heights. The page lets you:

- mount and unmount the clock component
- switch between word files from `@simonheys/wordclock-words`
- test the text fitting behavior at several fixed heights

The implementation is also an example of consumer-owned loading:

- `src/app/page.tsx` is the route entry. It composes data from `src/app/_lib/word-files.ts` with
  the interactive example component.
- `src/app/_lib/word-files.ts` derives selector options from each canonical word-file `meta` object
  and passes the initial selected words to the client.
- `src/app/_components/WordClockExample.tsx` is the client component. It owns the interactive dynamic
  import used when the selected word file changes.
- `src/app/_types/word-files.ts` contains the serializable data contracts shared across the
  server/client boundary.

This keeps `@simonheys/wordclock-words` as a raw JSON package while still avoiding eager client-side
imports of every word file.

## For Contributors

Run commands from the repository root:

```bash
pnpm --filter @simonheys/wordclock-example dev
pnpm --filter @simonheys/wordclock-example format:check
pnpm --filter @simonheys/wordclock-example typecheck
pnpm --filter @simonheys/wordclock-example build
pnpm --filter @simonheys/wordclock-example lint
pnpm --filter @simonheys/wordclock-example test:e2e
```

The e2e tests are metric- and behavior-based. They verify that the word clock stays within its
container, refits when the container width changes, and loads a newly selected word file. They do not
use screenshots for visual regression testing.

When changing the React package, rebuild it before relying on this app to verify package output:

```bash
pnpm --filter @simonheys/wordclock build
```

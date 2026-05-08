# WordClock Example

Next.js app for exercising `@simonheys/wordclock` against the bundled word files in `@simonheys/wordclock-words`.

## For Consumers

Use this app to inspect how the React package behaves with different language files and container heights. The page lets you:

- mount and unmount the clock component
- switch between word files from `@simonheys/wordclock-words`
- test the text fitting behavior at several fixed heights

The implementation lives in `src/app/page.tsx`.

## For Contributors

Run commands from the repository root:

```bash
pnpm --filter @simonheys/wordclock-example dev
pnpm --filter @simonheys/wordclock-example build
pnpm --filter @simonheys/wordclock-example lint
pnpm --filter @simonheys/wordclock-example test:e2e
```

The e2e test is metric-based. It verifies that the word clock stays within its container and refits when the container width changes; it does not use screenshots for visual regression testing.

When changing the React package, rebuild it before relying on this app to verify package output:

```bash
pnpm --filter @simonheys/wordclock build
```

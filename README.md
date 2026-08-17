![simonheys com:wordclock](https://user-images.githubusercontent.com/175607/132990185-98a933f6-e0c4-4ab9-ac58-f91f5a6657ae.gif)

# WordClock

WordClock versions of various vintages, for various platforms.

https://www.simonheys.com/wordclock/

## Downloads

Currently available to download as a screen saver for macOS:

https://github.com/simonheys/wordclock/releases

## Web Packages

- [WordClock React](/packages/wordclock-js)

  React components published as `@wordclock/react`. The package renders a supplied word definition; consumers decide how to load those definitions.

- [WordClock Canvas](/packages/wordclock-canvas)

  Framework-free canvas renderer published as `@wordclock/canvas`. Computes an explicit position for every word, which enables the rotary layout and the transition between linear and rotary.

- [WordClock Words](/packages/wordclock-words)

  Raw JSON word definitions published as `@wordclock/words`. The package is intentionally thin: it contains JSON files and a manifest, not loader helpers.

- [WordClock Example](/apps/example)

  Next.js app used to exercise the React package against the bundled word definitions.

## Legacy And Native Packages

- [WordClock Flash](/packages/wordclock-flash)

  The original prototype from 2003.

- [WordClock iOS](/packages/wordclock-ios)

  This was written in 2008 for the original iPod Touch running iPhoneOS 2, and achieved my goal of running at 60fps.

- [WordClock macOS](/packages/wordclock-macos)

  Native macOS screen saver.

## Getting Started

Install common dependencies:

```bash
pnpm install
```

See individual packages for further steps.

## Checks

Run repository-level checks from the root:

```bash
pnpm format:check
pnpm lint
pnpm typecheck
pnpm build
pnpm test
```

## License

[MIT](LICENSE)

# WordClock macOS

This is the code used for the native macOS screen saver version. Rendering is Metal-based and targets 60fps.

Run package scripts from `packages/wordclock-macos`, or from the repository root with
`pnpm --filter wordclock-macos <script>`.

## Initial Setup

- Install dependencies

  ```bash
  pnpm install
  ```

## Release Build

- Build and sign the app

  ```bash
  pnpm build
  ```

- Bundle it into a DMG to preserve the signature

  ```bash
  pnpm package-dmg
  ```

- Notarize and staple the DMG

  ```bash
  pnpm notarize
  ```

- Describe the changes in `RELEASE_NOTES.md`, then draft the GitHub release

  ```bash
  pnpm release
  ```

  This verifies the DMG is stapled, attaches it, and appends the footer from
  `.github/release-footer.md` to the notes. It creates a draft so the notes can be
  reviewed before going live; pass `--publish` to release directly. Requires the
  [GitHub CLI](https://cli.github.com) to be installed and authenticated.

## Signing And Notarization

Required to create a distributable release for macOS. Used to digitally sign the app and notarize it with Apple.

#### `MAC_NOTARIZE_APPLE_ID`

- The Apple ID of the signing account
- e.g. `MAC_NOTARIZE_APPLE_ID=demo@example.com`

#### `MAC_NOTARIZE_APPLE_ID_PASSWORD`

- The password or Keychain item identifier of the signing account
- e.g. `MAC_NOTARIZE_APPLE_ID_PASSWORD=@keychain:Application Loader: demo@example.com`

#### `MAC_NOTARIZE_ASC_PRIMARY_BUNDLE_ID`

- The bundle id of the app

#### `MAC_NOTARIZE_ASC_PROVIDER`

- This is the `ProviderShortname` which can be found by running the following with the credentials referenced above;

  ```bash
  xcrun altool --list-providers -u 'demo@example.com' -p '@keychain:Application Loader: demo@example.com'
  ```

- e.g. `MAC_NOTARIZE_ASC_PROVIDER=ABC123`

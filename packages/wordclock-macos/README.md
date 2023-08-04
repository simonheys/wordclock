# WordClock macOS

This is the code used for the native macOS Screensaver version. It has a long history and is complicated by its use of OpenGL to achieve my goal of running at 60fps.

## Initial setup

- Install dependencies

        $ yarn

## Steps to build a release

- Build and sign the app

        $ pnpm build

- Bundle it into a DMG to preserve the signature

        $ pnpm package-dmg

- Notarize and staple the DMG

        $ pnpm notarize

## macOS sign and Notarize

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

      $ xcrun altool --list-providers -u 'demo@example.comm' -p "@keychain:Application Loader: demo@example.com"

- e.g. `MAC_NOTARIZE_ASC_PROVIDER=ABC123`

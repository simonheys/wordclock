const path = require('path');

import { executeCommand } from './util';

const {
  BUILT_PRODUCTS_DIR,
  FRAMEWORKS_FOLDER_PATH,
  EXPANDED_CODE_SIGN_IDENTITY_NAME,
} = process.env;

console.log('Code signing');

const LOCATION = path.join(BUILT_PRODUCTS_DIR, FRAMEWORKS_FOLDER_PATH);

// https://github.com/sparkle-project/Sparkle/issues/1266
// By default, use the configured code signing identity for the project/target
// If a code signing identity is not specified, use ad hoc signing

const IDENTITY = EXPANDED_CODE_SIGN_IDENTITY_NAME || '-';

console.log('Using identity', IDENTITY);

executeCommand(
  `codesign --timestamp --verify --verbose --force --deep -o runtime --sign "${IDENTITY}" "${LOCATION}/Sparkle.framework/Versions/A/Resources/AutoUpdate.app"`
);
executeCommand(
  `codesign --timestamp --verify --verbose --force -o runtime --sign "${IDENTITY}" "${LOCATION}/Sparkle.framework/Versions/A"`
);

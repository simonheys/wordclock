const path = require("path");

import { executeCommand } from "./util";

const { TARGET_BUILD_DIR, UNLOCALIZED_RESOURCES_FOLDER_PATH } = process.env;
const PACKAGES_DIR = path.join(__dirname, "../..");

console.log("Copying json...");

executeCommand(
  `mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/json/"`
);

executeCommand(
  `cp -r "${PACKAGES_DIR}/wordclock-words/json"/*.json "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/json/"`
);

// remove extended attributes, not allowed for signing
executeCommand(
  `xattr -rc "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/json/"`
);

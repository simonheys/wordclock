const path = require("path");

import { executeCommand } from "./util";

const { TARGET_BUILD_DIR, UNLOCALIZED_RESOURCES_FOLDER_PATH } = process.env;
const PACKAGES_DIR = path.join(__dirname, "../..");

console.log("Copying xml...");

executeCommand(
  `mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/xml/"`
);

executeCommand(
  `cp -r "${PACKAGES_DIR}/wordclock-words/xml"/*.xml "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/xml/"`
);

// remove extended attributes, not allowed for signing
executeCommand(
  `xattr -rc "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/xml/"`
);

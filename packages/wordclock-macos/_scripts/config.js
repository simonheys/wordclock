// load process.env from .env file
require("dotenv").config();

const workspace = `WordClock.xcworkspace`;
const scheme = `Word Clock`;
const configuration = `Release`;

const ascPrimaryBundleId = process.env.MAC_NOTARIZE_ASC_PRIMARY_BUNDLE_ID;
const ascUsername = process.env.MAC_NOTARIZE_APPLE_ID;
const ascPassword = process.env.MAC_NOTARIZE_APPLE_ID_PASSWORD;
const ascProvider = process.env.MAC_NOTARIZE_ASC_PROVIDER;

export {
  workspace,
  scheme,
  configuration,
  ascPrimaryBundleId,
  ascUsername,
  ascPassword,
  ascProvider,
};

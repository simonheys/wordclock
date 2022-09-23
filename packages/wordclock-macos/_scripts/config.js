// load process.env from .env file
require("dotenv").config();

const workspace = `WordClock.xcworkspace`;
const scheme = `Word Clock`;
const configuration = `Release`;

const keychainProfile = process.env.MAC_NOTARIZE_KEYCHAIN_PROFILE;

export { workspace, scheme, configuration, keychainProfile };

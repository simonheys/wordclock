import { executeCommand } from './util';

import { workspace, scheme, configuration } from './config';

const buildSettings = executeCommand(
  `xcodebuild -workspace "${workspace}" -scheme "${scheme}" -configuration "${configuration}" -showBuildSettings`
);

const re = /\s+(.+) = (.+)/g;

const settings = {};

let m;
while ((m = re.exec(buildSettings))) {
  const key = m[1];
  const value = m[2];
  settings[key] = value;
}

export default settings;

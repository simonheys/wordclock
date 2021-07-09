import { spawnCommand } from './util';

import { workspace, scheme, configuration } from './config';

(async () => {
  console.log('Building');

  await spawnCommand(`xcodebuild`, [
    `-workspace`,
    workspace,
    `-scheme`,
    scheme,
    `-configuration`,
    configuration,
    `clean`,
  ]);

  await spawnCommand(`xcodebuild`, [
    `-workspace`,
    workspace,
    `-scheme`,
    scheme,
    `-configuration`,
    configuration,
  ]);
})();

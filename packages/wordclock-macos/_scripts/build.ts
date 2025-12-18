import { spawnCommand } from './util'

import { configuration, scheme, workspace } from './config'
;(async () => {
  console.log('Building')

  await spawnCommand(`xcodebuild`, [
    `-workspace`,
    workspace,
    `-scheme`,
    scheme,
    `-configuration`,
    configuration,
    `clean`,
  ])

  await spawnCommand(`xcodebuild`, [
    `-workspace`,
    workspace,
    `-scheme`,
    scheme,
    `-configuration`,
    configuration,
  ])
})()

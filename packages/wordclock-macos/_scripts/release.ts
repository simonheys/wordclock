import fs from 'fs-extra'
import path from 'path'

import { getDmgInfo, getVersion } from './meta'
import settings from './settings'
import { spawnCommand } from './util'

const { BUILT_PRODUCTS_DIR, FULL_PRODUCT_NAME } = settings

const notesPath = path.join(__dirname, '../RELEASE_NOTES.md')
const footerPath = path.join(__dirname, '../../../.github/release-footer.md')

const publish = process.argv.includes('--publish')
;(async () => {
  const builtProduct = path.join(BUILT_PRODUCTS_DIR, FULL_PRODUCT_NAME)

  if (!(await fs.pathExists(builtProduct))) {
    throw new Error(`No build at ${builtProduct} — run 'pnpm build' first`)
  }

  const version = (await getVersion()) as string
  const tag = `v${version}`

  const { dmgPath, dmgFolderPath } = await getDmgInfo()

  if (!(await fs.pathExists(dmgPath))) {
    throw new Error(`No DMG at ${dmgPath} — run 'pnpm package-dmg' first`)
  }

  console.log('Verifying notarization')
  await spawnCommand(`xcrun`, [`stapler`, `validate`, dmgPath])

  const notes = (await fs.pathExists(notesPath))
    ? (await fs.readFile(notesPath, 'utf8')).trim()
    : ''
  const footer = (await fs.readFile(footerPath, 'utf8')).trim()

  const body = notes ? `${notes}\n\n---\n\n${footer}\n` : `${footer}\n`
  const bodyPath = path.join(dmgFolderPath, 'release-notes.md')
  await fs.writeFile(bodyPath, body)

  console.log(`Creating ${publish ? 'release' : 'draft release'} ${tag}`)
  await spawnCommand(`gh`, [
    `release`,
    `create`,
    tag,
    dmgPath,
    `--title`,
    tag,
    `--notes-file`,
    bodyPath,
    ...(publish ? [] : [`--draft`]),
  ])

  console.log(publish ? `Published ${tag}` : `Drafted ${tag} — review and publish on GitHub`)
})()

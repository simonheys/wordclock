const path = require('path')
const fs = require('fs')
const xml2js = require('xml2js')

import settings from './settings'

const { BUILT_PRODUCTS_DIR, PRODUCT_NAME, FULL_PRODUCT_NAME } = settings

export const getDmgName = async () => {
  const version = await getVersion()
  return `${PRODUCT_NAME} ${version}`
}

export const getDmgInfo = async () => {
  const dmgVolumeName = await getDmgName()
  const dmgFolderPath = path.join(__dirname, '../_dist')
  const dmgPath = path.join(dmgFolderPath, `${dmgVolumeName}.dmg`)
  const dmgTmpPath = path.join(dmgFolderPath, `${dmgVolumeName}.tmp.dmg`)
  return {
    dmgVolumeName,
    dmgFolderPath,
    dmgPath,
    dmgTmpPath,
  }
}

export const getVersion = async () => {
  return new Promise((resolve, reject) => {
    const plistPath = path.join(BUILT_PRODUCTS_DIR, FULL_PRODUCT_NAME, 'Contents/Info.plist')
    fs.readFile(plistPath, 'utf8', function (err, data) {
      if (err) {
        reject(err)
      }
      const parser = new xml2js.Parser()
      parser.parseString(data, function (err, result) {
        if (err) {
          reject(err)
        }
        const i = result.plist.dict[0].key.indexOf('CFBundleShortVersionString')
        const version = result.plist.dict[0].string[i]
        resolve(version)
      })
    })
  })
}

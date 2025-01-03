const path = require("path");
const fs = require("fs-extra");

import { getDmgInfo } from "./meta";
import settings from "./settings";
import { spawnCommand } from "./util";

const { BUILT_PRODUCTS_DIR, FULL_PRODUCT_NAME } = settings;

console.log("Packaging DMG");

(async () => {
  const sourceFolder = path.join(BUILT_PRODUCTS_DIR, FULL_PRODUCT_NAME);

  const dmgInfo = await getDmgInfo();
  const { dmgVolumeName, dmgFolderPath, dmgPath, dmgTmpPath } = dmgInfo;

  await fs.ensureDir(dmgFolderPath);
  await fs.remove(dmgPath);
  await fs.remove(dmgTmpPath);

  await spawnCommand(`hdiutil`, [
    `create`,
    `-srcfolder`,
    sourceFolder,
    `-volname`,
    dmgVolumeName,
    `-fs`,
    `HFS+`,
    `-fsargs`,
    `-c c=64,a=16,e=16`,
    `-format`,
    `UDRW`,
    dmgTmpPath,
  ]);

  await spawnCommand(`hdiutil`, [
    `attach`,
    `-readwrite`,
    `-noverify`,
    `-noautoopen`,
    dmgTmpPath,
  ]);

  await spawnCommand(`hdiutil`, [`detach`, `/Volumes/${dmgVolumeName}`]);

  await spawnCommand(`hdiutil`, [
    `convert`,
    dmgTmpPath,
    `-format`,
    `UDZO`,
    `-imagekey`,
    `zlib-level=9`,
    `-o`,
    dmgPath,
    `-puppetstrings`,
  ]);

  await fs.remove(dmgTmpPath);
})();

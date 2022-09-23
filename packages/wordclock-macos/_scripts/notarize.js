import { spawnCommand } from "./util";
import { getDmgInfo } from "./meta";
import { keychainProfile } from "./config";

(async () => {
  const dmgInfo = await getDmgInfo();
  const { dmgPath } = dmgInfo;

  let result;

  try {
    console.log("Notarizing...");
    const altoolResult = await spawnCommand(`xcrun`, [
      `notarytool`,
      `submit`,
      dmgPath,
      `--keychain-profile`,
      keychainProfile,
      `--wait`,
    ]);
    console.log("altoolResult", JSON.stringify(altoolResult, null, 2));
    const { stdout } = altoolResult;
    result = stdout;
  } catch (e) {
    console.log("altoolResult e", JSON.stringify(e, null, 2));
    const { stderr } = e;
    result = stderr;
  }

  console.log("result", result);

  if (result) {
    await spawnCommand(`xcrun`, [`stapler`, `staple`, `-v`, dmgPath]);
    console.log("Done");
  }
})();

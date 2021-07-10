import { spawnCommand } from "./util";
import { getDmgInfo } from "./meta";
import {
  ascPrimaryBundleId,
  ascUsername,
  ascPassword,
  ascProvider,
} from "./config";

// https://stackoverflow.com/questions/136505/searching-for-uuids-in-text-with-regex;

export const delayInSeconds = async (time) =>
  new Promise((resolve) => setTimeout(resolve, time * 1000));

// returns the final id
export const getIdFromString = (stringToCheck) => {
  const uuidv4Regex =
    /([0-9A-F]{8}-[0-9A-F]{4}-[4][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12})/gi;
  let match, result;
  while ((match = uuidv4Regex.exec(stringToCheck)) !== null) {
    console.log("match", JSON.stringify(match, null, 2));
    result = match[0];
  }
  return result;
};

export const getStatusFromString = (stringToCheck) => {
  const statusRegex = /\n *Status: (.+?)\n/g;
  const match = statusRegex.exec(stringToCheck);
  if (match) {
    return match[1];
  }
};

export const checkVerificationStatusForUploadId = async (id) => {
  let result;
  try {
    const altoolResult = await spawnCommand(`xcrun`, [
      `altool`,
      `--eval-info`,
      id,
      `-u`,
      ascUsername,
      `-p`,
      ascPassword,
      `-itc_provider`,
      ascProvider,
    ]);
    console.log(
      "checkVerificationStatusForUploadId altoolResult",
      JSON.stringify(altoolResult, null, 2)
    );
    const { stdout } = altoolResult;
    result = stdout;
  } catch (e) {
    console.log(
      "checkVerificationStatusForUploadId altoolResult e",
      JSON.stringify(e, null, 2)
    );
    const { stderr } = e;
    result = stderr;
  }
  console.log("result", result);
  return getStatusFromString(result);
};

(async () => {
  const dmgInfo = await getDmgInfo();
  const { dmgPath } = dmgInfo;

  let result;

  try {
    console.log("Notarizing - this can take a while...");
    const altoolResult = await spawnCommand(`xcrun`, [
      `altool`,
      `--notarize-app`,
      `--primary-bundle-id`,
      ascPrimaryBundleId,
      `-u`,
      ascUsername,
      `-p`,
      ascPassword,
      `-itc_provider`,
      ascProvider,
      `-f`,
      dmgPath,
    ]);
    console.log("altoolResult", JSON.stringify(altoolResult, null, 2));
    const { stdout } = altoolResult;
    result = stdout;
    /*
    2019-05-19 13:58:01.315 altool[23641:760399] No errors uploading '<PATH>'.
    RequestUUID = <UUID>
    */
  } catch (e) {
    console.log("altoolResult e", JSON.stringify(e, null, 2));
    const { stderr } = e;
    // huge debug log, may include the phrase
    // ERROR: ERROR ITMS-90732: "The software asset has already been uploaded. The upload ID is <UUID>" at SoftwareAssets/EnigmaSoftwareAsset
    result = stderr;
  }

  console.log("result", result);

  if (result) {
    const id = getIdFromString(result);
    console.log("upload ID", id);
    let pollForStatus = true;
    let status;
    while (pollForStatus) {
      status = await checkVerificationStatusForUploadId(id);
      console.log("Status", status);
      if (status !== "in progress") {
        pollForStatus = false;
      }
      if (pollForStatus) {
        console.log("Checking again in 30 seconds...");
        await delayInSeconds(30);
      }
    }
    if (status === "success") {
      await spawnCommand(`xcrun`, [`stapler`, `staple`, `-v`, dmgPath]);
      console.log("Done");
    } else {
      console.log("Status is not success, not stapling");
    }
  }
})();

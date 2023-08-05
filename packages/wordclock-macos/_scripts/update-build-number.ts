import { executeCommand } from "./util";

const { SRCROOT, INFOPLIST_FILE, TARGET_BUILD_DIR } = process.env;

const branch = executeCommand(`git rev-parse --abbrev-ref HEAD`);

console.log("Branch", branch);

const branchCount = parseInt(executeCommand(`git rev-list ${branch} --count`));
const headToBranchCount = parseInt(
  executeCommand(`git rev-list HEAD..${branch} --count`),
);

const buildNumber = branchCount - headToBranchCount;

console.log("buildNumber", buildNumber);

console.log(
  `Updating build number to ${buildNumber} using branch '${branch}'."`,
);
console.log("TARGET_BUILD_DIR", TARGET_BUILD_DIR);

executeCommand(
  `/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${buildNumber}" "${SRCROOT}/${INFOPLIST_FILE}"`,
);

import path from "path";

import { cwd, executeCommand, getSourceFiles } from "./util";

(async () => {
  const files = await getSourceFiles();
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const filePath = path.join(cwd, file);
    executeCommand(`clang-format -i "${filePath}"`);
  }
})();

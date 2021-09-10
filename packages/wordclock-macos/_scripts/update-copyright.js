import readline from "readline";
import fs from "fs-extra";
import path from "path";
import moment from "moment";

import { cwd, getSourceFiles, executeCommand } from "./util";

const PROJECT_NAME = "WordClock macOS";
const AUTHOR_NAME = "Simon Heys";
const COPYRIGHT_HOLDER = "Studio Heys Limited";

export const makeComment = ({ fileName, creationDate }) => {
  return `\
//\n\
//  ${fileName}\n\
//  ${PROJECT_NAME}\n\
//\n\
//  Created by ${AUTHOR_NAME} on ${creationDate}.\n\
//  Copyright (c) ${COPYRIGHT_HOLDER}. All rights reserved.\n\
//\
`;
};

export const setFileComment = async ({ filePath, comment }) => {
  return new Promise((resolve) => {
    const newFilePath = filePath + ".new";
    let startOfFile = true;
    fs.removeSync(newFilePath);
    fs.copyFileSync(filePath, newFilePath);
    const outputStream = fs.createWriteStream(newFilePath);
    outputStream.write(comment + "\n");
    try {
      readline
        .createInterface({
          input: fs.createReadStream(filePath),
          terminal: false,
        })
        .on("line", function (line) {
          if (startOfFile && line.startsWith("//")) {
            console.log("Line: " + line);
          } else {
            startOfFile = false;
            outputStream.write(line + "\n");
          }
        })
        .on("close", function () {
          outputStream.end();
          // delete original file
          fs.removeSync(filePath);
          fs.renameSync(newFilePath, filePath);
          resolve();
        });
    } catch (error) {
      console.error(error);
      // don't do anything
      fs.removeSync(newFilePath);
      resolve();
    }
  });
};

(async () => {
  const files = await getSourceFiles();
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const filePath = path.join(cwd, file);
    // follow commits through renames, output author date as iso string
    const result = executeCommand(
      `git log --follow --format=%ai "${filePath}" | tail -1`
    );
    // moment doesn't like the format, so convert to Date first
    const date = moment(new Date(result));
    const creationDate = date.format("DD/MM/YYYY");
    const fileName = path.basename(filePath);

    const comment = makeComment({ fileName, creationDate });
    await setFileComment({ filePath, comment });
  }
})();

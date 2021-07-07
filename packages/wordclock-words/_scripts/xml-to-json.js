const fs = require("fs");
const path = require("path");
const { exit } = require("process");
const xml2js = require("xml2js");
const _ = require("lodash");

const SOURCE_DIRECTORY = path.join(__dirname, "../xml");
const DESTINATION_DIRECTORY = path.join(__dirname, "../json");

const isNumeric = (numToCheck) =>
  !isNaN(parseFloat(numToCheck)) && isFinite(numToCheck);

const convertNumeric = (obj) => {
  Object.entries(obj).forEach(([key, value]) => {
    if (isNumeric(value)) {
      obj[key] = parseInt(value);
    }
  });
};

const xmlToJson = async () => {
  const files = fs
    .readdirSync(SOURCE_DIRECTORY)
    .filter((file) => !file.startsWith("."));

  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const fileContents = fs
      .readFileSync(path.join(SOURCE_DIRECTORY, file))
      .toString();
    const parsed = await xml2js.parseStringPromise(fileContents);

    const json = {
      meta: {},
    };

    json.meta.language = _.get(parsed, "wordclock.$.language");

    const sourceTitle = _.get(parsed, "wordclock.title[0]");
    if (sourceTitle) {
      json.meta.title = sourceTitle.trim();
    }

    const sourceSuitability = _.get(parsed, "wordclock.suitability");
    if (sourceSuitability) {
      json.meta.suitability = sourceSuitability.map((suitability) =>
        _.get(suitability, "suitable[0].$.style")
      );
    }

    const sourceGroup = _.get(parsed, "wordclock.group");
    if (sourceGroup) {
      json.groups = sourceGroup.map((item) => {
        return Object.entries(item).map(([key, value]) => {
          const type = key;
          if (type === "item") {
            const items = value.map((item) => {
              const rest = item["$"];
              convertNumeric(rest);
              const entry = { ...rest };
              const sourceText = item["_"];
              if (sourceText) {
                entry.text = sourceText.trim();
              }
              return entry;
            });
            const entry = {
              type,
              items,
            };
            return entry;
          } else {
            const attributes = value[0];
            const sourceText = attributes["_"];
            const rest = attributes["$"];
            convertNumeric(rest);
            const entry = {
              type,
              ...rest,
            };
            if (sourceText) {
              const text = sourceText.trim();
              if (entry.delimeter) {
                entry.text = text.split(entry.delimeter).map((t) => t.trim());
                delete entry.delimeter;
              } else {
                entry.text = [text];
              }
            }
            return entry;
          }
        });
      });
    }

    const newFileContents = JSON.stringify(json, null, 2);
    const fileJson = file.substr(0, file.lastIndexOf(".")) + ".json";
    fs.writeFileSync(
      path.join(DESTINATION_DIRECTORY, fileJson),
      newFileContents
    );
  }
};

(async () => {
  try {
    await xmlToJson();
  } catch (error) {
    console.error(error);
  }
})();

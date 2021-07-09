const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");
const xml2js = require("xml2js");

import { getVersion, getDmgName } from "./meta";
import settings from "./settings";

const { BUILT_PRODUCTS_DIR, FULL_PRODUCT_NAME, EXECUTABLE_NAME, PROJECT_DIR } =
  settings;

console.log("EXECUTABLE_NAME", EXECUTABLE_NAME);
console.log("BUILT_PRODUCTS_DIR", BUILT_PRODUCTS_DIR);
console.log("FULL_PRODUCT_NAME", FULL_PRODUCT_NAME);
console.log("PROJECT_DIR", PROJECT_DIR);

const updateAppCast = async ({
  version,
  signature,
  mtime,
  fileSizeInBytes,
  volumeName,
}) => {
  const appCastTemplateXmlPath = path.join(
    PROJECT_DIR,
    "_appcast/_template.xml"
  );
  console.log("appCastTemplateXmlPath", appCastTemplateXmlPath);
  const appCastWordClockXmlPath = path.join(
    PROJECT_DIR,
    "_appcast/wordclock.xml"
  );
  console.log("appCastWordClockXmlPath", appCastWordClockXmlPath);
  return new Promise((resolve, reject) => {
    fs.readFile(appCastTemplateXmlPath, "utf8", function (err, data) {
      if (err) {
        reject(err);
      }
      var parser = new xml2js.Parser();
      parser.parseString(data, function (err, result) {
        if (err) {
          reject(err);
        }
        // console.log("result:", JSON.stringify(result, null, 2));
        result.rss.channel[0].item[0].title = "Version " + version;
        result.rss.channel[0].item[0].description = `\
- Word Clock fulfils updated 10.15.4 notarize requirements\n\
- Improved font picker\n\
- Requires Mac OS 10.9 or later`;
        result.rss.channel[0].item[0].pubDate = mtime;
        result.rss.channel[0].item[0].enclosure[0].$[
          "url"
        ] = `https://www.simonheys.com/files/${volumeName}.dmg`;
        result.rss.channel[0].item[0].enclosure[0].$["sparkle:dsaSignature"] =
          signature;
        result.rss.channel[0].item[0].enclosure[0].$["length"] =
          fileSizeInBytes;
        result.rss.channel[0].item[0].enclosure[0].$["sparkle:version"] =
          version;
        var builder = new xml2js.Builder();
        var xml = builder.buildObject(result);
        console.log(xml);
        fs.writeFile(appCastWordClockXmlPath, xml, function (err) {
          if (err) {
            reject(err);
          }
          resolve();
        });
      });
    });
  });
};

(async function () {
  const version = await getVersion();
  const volumeName = await getDmgName();

  console.log("version", version);

  const dmgPath = path.join(__dirname, "../_dist", `${volumeName}.dmg`);
  console.log("dmgPath", dmgPath);

  const privkeyPath = path.join(
    __dirname,
    "../_certificates/Sparkle/privkey.pem"
  );
  console.log("privkeyPath", privkeyPath);

  const stats = fs.statSync(dmgPath);
  const fileSizeInBytes = stats.size;
  const mtime = stats.mtime;

  console.log("fileSizeInBytes", fileSizeInBytes);
  console.log("mtime", mtime);

  const command = `openssl dgst -sha1 -binary < "${dmgPath}" | openssl dgst -dss1 -sign "${privkeyPath}" | openssl enc -base64`;

  const signature = execSync(command).toString();
  console.log("signature", signature);

  await updateAppCast({
    version,
    signature,
    mtime,
    fileSizeInBytes,
    volumeName,
  });
})();

import WordClock from "./components/WordClock";

import styles from "./App.module.scss";
import React from "react";

const manifest = require(`wordclock-words/json/Manifest.json`);
const words = {};

manifest.files.forEach((file) => {
  const json = require(`wordclock-words/json/${file}`);
  const { meta } = json;
  const { language, title } = meta;
  const languageTitle = manifest.languages[language];
  if (!words[languageTitle]) {
    words[languageTitle] = [];
  }
  words[languageTitle].push({
    file,
    title,
  });
});

const wordsOrdered = Object.keys(words)
  .sort()
  .reduce((obj, key) => {
    obj[key] = words[key];
    return obj;
  }, {});

const heights = [0, 1, 10, 150, 200, 300, 600, 900];

const App = () => {
  const [file, setFile] = React.useState("English_simple_fragmented.json");
  const [mounted, setMounted] = React.useState(true);
  const [height, setHeight] = React.useState(600);

  const onMountedChange = React.useCallback((event) => {
    setMounted(event.target.checked);
  }, []);

  const onFileChange = React.useCallback((event) => {
    setFile(event.target.value);
  }, []);

  const onHeightChange = React.useCallback((event) => {
    setHeight(event.target.value);
  }, []);

  const words = React.useMemo(() => {
    const json = require(`wordclock-words/json/${file}`);
    return json;
  }, [file]);

  return (
    <React.Fragment>
      <div className={styles.controls}>
        <div>
          <input
            type="checkbox"
            id="mounted"
            onChange={onMountedChange}
            checked={mounted}
          />
          <label htmlFor="mounted">Mounted</label>
        </div>
        <select value={file} onChange={onFileChange}>
          {Object.entries(wordsOrdered).map(([languageTitle, entries]) => {
            return (
              <optgroup key={languageTitle} label={languageTitle}>
                {entries.map(({ file, title }) => {
                  return (
                    <option key={file} value={file}>
                      {title}
                    </option>
                  );
                })}
              </optgroup>
            );
          })}
        </select>
        <select value={height} onChange={onHeightChange}>
          {heights.map((value) => {
            return (
              <option key={value} value={value}>
                {value}
              </option>
            );
          })}
        </select>
      </div>
      <div className={styles.container} style={{ height: `${height}px` }}>
        {mounted && <WordClock words={words} />}
      </div>
    </React.Fragment>
  );
};

export default App;

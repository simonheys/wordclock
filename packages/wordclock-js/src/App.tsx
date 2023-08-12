import { ChangeEvent, Fragment, useCallback, useMemo, useState } from "react";

import styles from "./App.module.scss";
import WordClock from "./components/WordClock";
import { Manifest, WordsEntry, WordsJson, Words } from "./types";

const manifest: Manifest = require(`@simonheys/wordclock-words/json/Manifest.json`);
const words: Words = {};

manifest.files.forEach((file) => {
  const json: WordsJson = require(`@simonheys/wordclock-words/json/${file}`);
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

const wordsOrdered: Record<string, WordsEntry[]> = Object.keys(words)
  .sort()
  .reduce((obj: any, key: string) => {
    obj[key] = words[key];
    return obj;
  }, {});

const heights = [0, 1, 10, 150, 200, 300, 600, 900];

const App = () => {
  const [file, setFile] = useState("English_simple_fragmented.json");
  const [mounted, setMounted] = useState(true);
  const [height, setHeight] = useState(600);

  const onMountedChange = useCallback(
    (event: ChangeEvent<HTMLInputElement>) => {
      setMounted(event.target.checked);
    },
    [],
  );

  const onFileChange = useCallback((event: ChangeEvent<HTMLSelectElement>) => {
    setFile(event.target.value);
  }, []);

  const onHeightChange = useCallback(
    (event: ChangeEvent<HTMLSelectElement>) => {
      setHeight(parseInt(event.target.value));
    },
    [],
  );

  const words = useMemo(() => {
    const json = require(`@simonheys/wordclock-words/json/${file}`);
    return json;
  }, [file]);

  return (
    <Fragment>
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
    </Fragment>
  );
};

export default App;

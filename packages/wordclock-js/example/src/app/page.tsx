"use client";

import { ChangeEvent, Fragment, useCallback, useMemo, useState } from "react";

import {
  type Manifest,
  WordClock,
  WordClockContent,
  type Words,
  type WordsEntry,
  type WordsJson,
} from "@simonheys/wordclock";

// eslint-disable-next-line @typescript-eslint/no-var-requires
const manifest: Manifest = require("@simonheys/wordclock-words/json/Manifest.json");

const words: Words = {};

manifest.files.forEach((file) => {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
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
  .reduce((obj: Record<string, WordsEntry[]>, key: string) => {
    obj[key] = words[key];
    return obj;
  }, {});

const heights = [0, 1, 10, 150, 200, 300, 600, 900];

export default function Home() {
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
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const json = require(`@simonheys/wordclock-words/json/${file}`);
    return json;
  }, [file]);

  return (
    <Fragment>
      <div className="flex flex-row justify-between">
        <div>
          <input
            type="checkbox"
            id="mounted"
            onChange={onMountedChange}
            checked={mounted}
          />
          <label htmlFor="mounted">Mounted</label>
        </div>
        <label htmlFor="language-select">Select language and style:</label>
        <select id="language-select" value={file} onChange={onFileChange}>
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
        <label htmlFor="height-select">Select height:</label>
        <select id="height-select" value={height} onChange={onHeightChange}>
          {heights.map((value) => {
            return (
              <option key={value} value={value}>
                {value}
              </option>
            );
          })}
        </select>
      </div>
      <div
        className="w-full bg-gray-100 text-gray-400 leading-[1.1] font-bold tracking-tight [font-feature-settings:'liga'_1,'kern'_1]"
        style={{ height: `${height}px` }}
      >
        {mounted && (
          <WordClock words={words}>
            <WordClockContent />
          </WordClock>
        )}
      </div>
    </Fragment>
  );
}

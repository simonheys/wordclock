"use client";

import { CSSProperties, FC, HTMLAttributes, useEffect, useState } from "react";

import { useResizeTextToFit } from "../hooks/useResizeTextToFit";
import useTimeProps from "../hooks/useTimeProps";
import * as WordsFileParser from "../modules/WordsFileParser";
import { WordsJson, WordsLabel, WordsLogic } from "./types";
import { WordClockProvider } from "./useWordClock";

const containerStyle: CSSProperties = {
  width: "100%",
  height: "100%",
};

const wordsStyle: CSSProperties = {
  display: "flex",
  flexDirection: "row",
  flexWrap: "wrap",
  height: "100%",
};

interface WordClockProps extends HTMLAttributes<HTMLDivElement> {
  words: WordsJson;
}

export const WordClock: FC<WordClockProps> = ({ words, children, ...rest }) => {
  const [logic, setLogic] = useState<WordsLogic>([]);
  const [label, setLabel] = useState<WordsLabel>([]);

  const timeProps = useTimeProps();
  const { resizeRef, containerRef, resize } = useResizeTextToFit();

  useEffect(() => {
    if (!words) {
      return;
    }
    const parsed = WordsFileParser.parseJson(words);
    setLogic(parsed.logic);
    setLabel(parsed.label);
  }, [words]);

  useEffect(() => {
    resize();
  }, [logic, resize]);

  return (
    <div ref={containerRef} style={containerStyle}>
      <div ref={resizeRef} style={wordsStyle} {...rest}>
        <WordClockProvider value={{ logic, label, timeProps }}>
          {children}
        </WordClockProvider>
      </div>
    </div>
  );
};

import { useEffect, useState } from "react";

import useTimeProps from "../hooks/useTimeProps";
import * as WordsFileParser from "../modules/WordsFileParser";
import { WordsJson, WordsLabel, WordsLogic } from "../types";
import styles from "./WordClock.module.scss";
import { WordClockInner } from "./WordClockInner";
import { useResizeTextToFit } from "../hooks/useResizeTextToFit";

const WordClock = ({ words }: { words: WordsJson }) => {
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
    <div ref={containerRef} className={styles.container}>
      <div ref={resizeRef} className={styles.words}>
        <WordClockInner logic={logic} label={label} timeProps={timeProps} />
      </div>
    </div>
  );
};

export default WordClock;

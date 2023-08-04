import { FC, useEffect, useMemo, useRef, useState } from "react";

import useSize from "../hooks/useSize";
import useTimeProps, { TimeProps } from "../hooks/useTimeProps";
import * as LogicParser from "../modules/LogicParser";
import * as WordsFileParser from "../modules/WordsFileParser";
import { WordsJson } from "../types";
import styles from "./WordClock.module.scss";

interface WordClockInnerProps {
  logic: string[][];
  label: string[][];
  timeProps: TimeProps;
}

const WordClockInner: FC<WordClockInnerProps> = ({
  logic,
  label,
  timeProps,
}) => {
  return (
    <>
      {label.map((labelGroup, labelIndex) => {
        const logicGroup = logic[labelIndex];
        let highlighted;
        let hasPreviousHighlight = false;
        // only allow a single highlight per group
        return labelGroup.map((label, labelGroupIndex) => {
          highlighted = false;
          if (!hasPreviousHighlight) {
            const logic = logicGroup[labelGroupIndex];
            highlighted = LogicParser.term(logic, timeProps);
            if (highlighted) {
              hasPreviousHighlight = true;
            }
          }
          if (!label.length) {
            return null;
          }
          return (
            <div
              className={highlighted ? styles.wordHighlighted : styles.word}
              key={`${labelIndex}-${labelGroupIndex}`}
            >
              {label}
            </div>
          );
        });
      })}
    </>
  );
};

enum FIT {
  UNKNOWN = "UNKNOWN",
  SMALL = "SMALL",
  OK = "OK",
  LARGE = "LARGE",
}

const minimumFontSizeAdjustment = 0.00001;

interface SizeState {
  fontSize: number;
  previousFontSize: number;
  fontSizeLow: number;
  fontSizeHigh: number;
  previousFit: FIT;
  previousTargetSize?: {
    width: number;
    height: number;
  };
}

const sizeStateDefault = {
  fontSize: 12,
  previousFontSize: 12,
  fontSizeLow: 1,
  fontSizeHigh: 256,
  previousFit: FIT.UNKNOWN,
};

const WordClock = ({ words }: { words: WordsJson }) => {
  const innerRef = useRef<HTMLDivElement>(null);
  const { ref: containerRef, size: targetSize } = useSize();

  const [logic, setLogic] = useState<string[][]>([]);
  const [label, setLabel] = useState<string[][]>([]);
  const [sizeState, setSizeState] = useState<SizeState>({
    ...sizeStateDefault,
  });

  const timeProps = useTimeProps();

  useEffect(() => {
    if (!targetSize.width || !targetSize.height) {
      return;
    }
    if (sizeState.previousTargetSize) {
      // component resized - start resizing again
      if (
        sizeState.previousTargetSize.width !== targetSize.width ||
        sizeState.previousTargetSize.height !== targetSize.height
      ) {
        setSizeState({ ...sizeStateDefault, previousTargetSize: targetSize });
        return;
      }
    }
    const height = innerRef.current?.scrollHeight ?? 0;
    if (sizeState.previousFit === FIT.OK) {
      // currently FIT.OK - do nothing
    } else if (height === targetSize.height) {
      // set FIT.OK
      setSizeState((sizeState) => ({
        ...sizeState,
        previousFit: FIT.OK,
        previousTargetSize: targetSize,
      }));
    } else if (height < targetSize.height) {
      // currently FIT.SMALL
      // increase size
      const nextFontSize = 0.5 * (sizeState.fontSize + sizeState.fontSizeHigh);
      setSizeState((sizeState) => ({
        ...sizeState,
        fontSize: nextFontSize,
        previousFontSize: sizeState.fontSize,
        fontSizeLow: sizeState.fontSize,
        previousFit: FIT.SMALL,
        previousTargetSize: targetSize,
      }));
    } else {
      const nextFontSize = 0.5 * (sizeState.fontSize + sizeState.fontSizeLow);
      const fontSizeDifference = Math.abs(sizeState.fontSize - nextFontSize);
      if (
        sizeState.previousFit === FIT.SMALL &&
        fontSizeDifference <= minimumFontSizeAdjustment
      ) {
        // use previous size
        setSizeState((sizeState) => ({
          ...sizeState,
          fontSize: sizeState.previousFontSize,
          previousFit: FIT.OK,
          previousTargetSize: targetSize,
        }));
      } else {
        // decrease size
        setSizeState((sizeState) => ({
          ...sizeState,
          fontSize: nextFontSize,
          previousFontSize: sizeState.fontSize,
          fontSizeHigh: sizeState.fontSize,
          previousFit: FIT.LARGE,
          previousTargetSize: targetSize,
        }));
      }
    }
  }, [
    sizeState.fontSize,
    sizeState.fontSizeHigh,
    sizeState.fontSizeLow,
    sizeState.previousFit,
    sizeState.previousTargetSize,
    targetSize,
  ]);

  const style = useMemo(() => {
    return {
      fontSize: sizeState.fontSize,
    };
  }, [sizeState.fontSize]);

  useEffect(() => {
    if (!words) {
      return;
    }
    const parsed = WordsFileParser.parseJson(words);
    setLogic(parsed.logic);
    setLabel(parsed.label);
    // start resizing
    setSizeState({ ...sizeStateDefault });
  }, [words]);

  const isResizing = sizeState.previousFit !== FIT.OK;
  return (
    <div ref={containerRef} className={styles.container}>
      <div
        ref={innerRef}
        className={isResizing ? styles.wordsResizing : styles.words}
        style={style}
      >
        <WordClockInner logic={logic} label={label} timeProps={timeProps} />
      </div>
    </div>
  );
};

export default WordClock;

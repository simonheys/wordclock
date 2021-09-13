import * as React from "react";

import useTimeProps from "../hooks/useTimeProps";
import * as WordsFileParser from "../modules/WordsFileParser";
import * as LogicParser from "../modules/LogicParser";

import styles from "./WordClock.module.scss";
import useSize from "../hooks/useSize";

const WordClockInner = ({ logic, label, timeProps, fontSize }) => {
  return label.map((labelGroup, labelIndex) => {
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
  });
};

const FIT = {
  UNKNOWN: "UNKNOWN",
  SMALL: "SMALL",
  OK: "OK",
  LARGE: "LARGE",
};

const minimumFontSizeAdjustment = 0.01;

const sizeStateDefault = {
  fontSize: 12,
  previousFontSize: 12,
  fontSizeLow: 1,
  fontSizeHigh: 256,
  previousFit: FIT.UNKNOWN,
};

const WordClock = ({ words }) => {
  const innerRef = React.useRef(null);
  const { ref: containerRef, size: targetSize } = useSize();

  const [logic, setLogic] = React.useState([]);
  const [label, setLabel] = React.useState([]);
  const [sizeState, setSizeState] = React.useState({ ...sizeStateDefault });

  const timeProps = useTimeProps();

  React.useEffect(() => {
    if (!targetSize.width) {
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
    const height = innerRef.current.scrollHeight;
    if (sizeState.previousFit === FIT.OK) {
      // currently FIT.OK - do nothing
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
        // previousTargetSize: targetSize,
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
          // previousTargetSize: targetSize,
        }));
      } else {
        // decrease size
        setSizeState((sizeState) => ({
          ...sizeState,
          fontSize: nextFontSize,
          previousFontSize: sizeState.fontSize,
          fontSizeHigh: sizeState.fontSize,
          previousFit: FIT.LARGE,
          // previousTargetSize: targetSize,
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

  const style = React.useMemo(() => {
    return {
      fontSize: sizeState.fontSize,
    };
  }, [sizeState.fontSize]);

  React.useEffect(() => {
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

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
  lineHeight: 1,
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
    const boundingClientRect = innerRef.current.getBoundingClientRect();
    const { height } = boundingClientRect;
    const nextFontSize = 0.5 * (sizeState.fontSize + sizeState.fontSizeLow);
    const fontSizeDifference = Math.abs(sizeState.fontSize - nextFontSize);
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
    if (sizeState.previousFit === FIT.OK) {
      // currently FIT.OK - do nothing
    } else if (height < targetSize.height) {
      // currently FIT.SMALL
      // increase size
      setSizeState({
        ...sizeState,
        fontSize: 0.5 * (sizeState.fontSize + sizeState.fontSizeHigh),
        previousFontSize: sizeState.fontSize,
        fontSizeLow: sizeState.fontSize,
        previousFit: FIT.SMALL,
        previousTargetSize: targetSize,
        previousHeight: height,
      });
    } else {
      // currently FIT.LARGE
      if (
        sizeState.previousFit === FIT.SMALL &&
        fontSizeDifference <= minimumFontSizeAdjustment
      ) {
        // use previous size
        setSizeState({
          ...sizeState,
          fontSize: sizeState.previousFontSize,
          previousFit: FIT.OK,
          previousTargetSize: targetSize,
        });
      } else {
        // decrease size
        setSizeState({
          ...sizeState,
          fontSize: nextFontSize,
          previousFontSize: sizeState.fontSize,
          fontSizeHigh: sizeState.fontSize,
          previousFit: FIT.LARGE,
          previousTargetSize: targetSize,
          previousHeight: height,
        });
      }
    }
  }, [
    containerRef,
    sizeState,
    targetSize,
    targetSize.height,
    targetSize.width,
  ]);

  const style = React.useMemo(() => {
    return {
      fontSize: sizeState.fontSize,
      lineHeight: sizeState.lineHeight,
    };
  }, [sizeState.fontSize, sizeState.lineHeight]);

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

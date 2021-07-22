import * as React from "react";
import ResizeObserver from "resize-observer-polyfill";

import useTimeProps from "../hooks/useTimeProps";
import * as WordsFileParser from "../modules/WordsFileParser";
import * as LogicParser from "../modules/LogicParser";

import styles from "./WordClock.module.scss";

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
  const containerRef = React.useRef(null);
  const innerRef = React.useRef(null);
  const rafRef = React.useRef(null);
  const ro = React.useRef(null);
  const needsResize = React.useRef(true);

  const [logic, setLogic] = React.useState([]);
  const [label, setLabel] = React.useState([]);
  const [targetHeight, setTargetHeight] = React.useState(0);
  const [sizeState, setSizeState] = React.useState({ ...sizeStateDefault });

  // const elapsedMilliseconds = useAnimationFrame();
  const timeProps = useTimeProps();

  const updateResizeObserver = React.useCallback(() => {
    if (ro.current) {
      if (containerRef.current) {
        ro.current.unobserve(containerRef.current);
      }
    } else {
      ro.current = new ResizeObserver((entries) => {
        const currentRefEntry = entries.find(
          ({ target }) => target === containerRef.current
        );
        if (currentRefEntry) {
          setTargetHeight(currentRefEntry.contentRect.height);
          needsResize.current = true;
        }
      });
    }
    if (containerRef.current) {
      ro.current.observe(containerRef.current);
    }
    return () => {
      ro.current.disconnect();
      ro.current = null;
    };
  }, [setTargetHeight]);

  const setContainerRef = React.useCallback(
    (ref) => {
      if (ref && ref !== containerRef.current) {
        containerRef.current = ref;
        updateResizeObserver();
      }
    },
    [updateResizeObserver]
  );

  const checkFontSize = React.useCallback(() => {
    if (!containerRef.current || !innerRef.current || targetHeight === 0) {
    } else {
      if (needsResize.current) {
        needsResize.current = false;
        setSizeState({ ...sizeStateDefault });
      } else {
        const boundingClientRect = innerRef.current.getBoundingClientRect();
        const { height } = boundingClientRect;
        const nextFontSize = 0.5 * (sizeState.fontSize + sizeState.fontSizeLow);
        const fontSizeDifference = Math.abs(sizeState.fontSize - nextFontSize);
        if (sizeState.previousFit === FIT.OK) {
          // currently FIT.OK - do nothing
        } else if (height < targetHeight) {
          // currently FIT.SMALL
          // increase size
          setSizeState({
            ...sizeState,
            fontSize: 0.5 * (sizeState.fontSize + sizeState.fontSizeHigh),
            previousFontSize: sizeState.fontSize,
            fontSizeLow: sizeState.fontSize,
            previousFit: FIT.SMALL,
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
            });
          } else {
            // decrease size
            setSizeState({
              ...sizeState,
              fontSize: nextFontSize,
              previousFontSize: sizeState.fontSize,
              fontSizeHigh: sizeState.fontSize,
              previousFit: FIT.LARGE,
            });
          }
        }
      }
    }
    rafRef.current = requestAnimationFrame(checkFontSize);
  }, [sizeState, targetHeight]);

  React.useEffect(() => {
    rafRef.current = requestAnimationFrame(checkFontSize);
    return () => cancelAnimationFrame(rafRef.current);
  }, [checkFontSize]);

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
    needsResize.current = true;
  }, [words]);

  const isResizing = sizeState.previousFit !== FIT.OK;
  return (
    <React.Fragment>
      <div ref={setContainerRef} className={styles.container}>
        <div
          ref={innerRef}
          className={isResizing ? styles.wordsResizing : styles.words}
          style={style}
        >
          <WordClockInner logic={logic} label={label} timeProps={timeProps} />
        </div>
      </div>
      <pre>{JSON.stringify({ sizeState, targetHeight }, null, 2)}</pre>
    </React.Fragment>
  );
};

export default WordClock;

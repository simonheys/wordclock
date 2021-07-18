import * as React from "react";
import ResizeObserver from "resize-observer-polyfill";

import useTimeProps from "../hooks/useTimeProps";
import useAnimationFrame from "../hooks/useAnimationFrame";
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
          className={highlighted ? styles.labelHighlighted : styles.label}
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

const minimumFontSizeAdjustment = 0.1;

const WordClock = () => {
  const containerRef = React.useRef();
  const innerRef = React.useRef();
  const ro = React.useRef();

  const [logic, setLogic] = React.useState([]);
  const [label, setLabel] = React.useState([]);
  const [targetHeight, setTargetHeight] = React.useState(0);
  const [sizeState, setSizeState] = React.useState({
    fontSize: 12,
    previousFontSize: 12,
    fontSizeLow: 1,
    fontSizeHigh: 256,
    previousFit: FIT.UNKNOWN,
  });

  const elapsedMilliseconds = useAnimationFrame();
  const timeProps = useTimeProps();

  const loadJson = async () => {
    const parsed = await WordsFileParser.parseJsonUrl(
      "/English_simple_fragmented.json"
    );
    setLogic(parsed.logic);
    setLabel(parsed.label);
  };

  React.useEffect(() => {
    ro.current = new ResizeObserver((entries) => {
      const currentRefEntry = entries.find(
        ({ target }) => target === containerRef.current
      );
      if (currentRefEntry) {
        setTargetHeight(currentRefEntry.contentRect.height);
        // start resizing
        setSizeState({
          ...sizeState,
          fontSizeLow: 1,
          fontSizeHigh: 256,
          previousFit: FIT.UNKNOWN,
        });
      }
    });
    if (containerRef.current) {
      ro?.current?.observe(containerRef.current);
    }
    return () => ro.current.disconnect();
  }, [setTargetHeight, setSizeState, sizeState]);

  const setContainerRef = React.useCallback((ref) => {
    if (containerRef.current) {
      ro?.current?.unobserve(containerRef.current);
    }
    containerRef.current = ref;
    if (containerRef.current) {
      ro?.current?.observe(containerRef.current);
    }
  }, []);

  React.useEffect(() => {
    if (containerRef.current && innerRef.current) {
      const boundingClientRect = innerRef.current.getBoundingClientRect();
      const { height } = boundingClientRect;
      if (height > 0 && targetHeight > 0) {
        const nextFontSize = 0.5 * (sizeState.fontSize + sizeState.fontSizeLow);
        const fontSizeDifference = Math.abs(sizeState.fontSize - nextFontSize);
        if (sizeState.previousFit === FIT.OK) {
          // currently FIT.OK - do nothing
        } else if (height < targetHeight) {
          // currently FIT.SMALL
          // increase size
          setSizeState({
            fontSize: 0.5 * (sizeState.fontSize + sizeState.fontSizeHigh),
            previousFontSize: sizeState.fontSize,
            fontSizeLow: sizeState.fontSize,
            fontSizeHigh: sizeState.fontSizeHigh,
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
              fontSize: sizeState.previousFontSize,
              previousFontSize: sizeState.previousFontSize,
              fontSizeLow: sizeState.previousFontSize,
              fontSizeHigh: sizeState.previousFontSize,
              previousFit: FIT.OK,
            });
          } else {
            // decrease size
            setSizeState({
              fontSize: nextFontSize,
              previousFontSize: sizeState.fontSize,
              fontSizeLow: sizeState.fontSizeLow,
              fontSizeHigh: sizeState.fontSize,
              previousFit: FIT.LARGE,
            });
          }
        }
      }
    }
  }, [elapsedMilliseconds, sizeState, targetHeight]);

  const style = React.useMemo(() => {
    return {
      fontSize: sizeState.fontSize,
    };
  }, [sizeState.fontSize]);

  React.useEffect(() => {
    loadJson();
  }, []);

  return (
    <div ref={setContainerRef} className={styles.container}>
      <div ref={innerRef} className={styles.inner} style={style}>
        <WordClockInner logic={logic} label={label} timeProps={timeProps} />
      </div>
    </div>
  );
};

export default WordClock;

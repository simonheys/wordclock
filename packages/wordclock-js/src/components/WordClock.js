import * as React from "react";

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

const targetHeight = 800;
const minimumFontSizeAdjustment = 0.1;

const WordClock = () => {
  const timeProps = useTimeProps();
  const [logic, setLogic] = React.useState([]);
  const [label, setLabel] = React.useState([]);
  const [sizeState, setSizeState] = React.useState({
    fontSize: 12,
    previousFontSize: 12,
    fontSizeLow: 1,
    fontSizeHigh: 256,
    previousFit: FIT.UNKNOWN,
    previousWidth: 0,
  });

  const loadJson = async () => {
    const parsed = await WordsFileParser.parseJsonUrl(
      "/English_simple_fragmented.json"
    );
    setLogic(parsed.logic);
    setLabel(parsed.label);
  };

  React.useEffect(() => {
    loadJson();
  }, []);

  const canvasRef = React.useRef();
  const elapsedMilliseconds = useAnimationFrame();

  React.useEffect(() => {
    if (canvasRef.current) {
      const boundingClientRect = canvasRef.current.getBoundingClientRect();
      const { width, height } = boundingClientRect;
      if (height > 0) {
        if (
          false &&
          sizeState.previousWidth !== 0 &&
          width !== sizeState.previousWidth
        ) {
          // reset adjustment
          setSizeState({
            fontSize: 12,
            previousFontSize: 12,
            fontSizeLow: 1,
            fontSizeHigh: 256,
            previousFit: FIT.UNKNOWN,
            previousWidth: width,
          });
        } else {
          const nextFontSize =
            0.5 * (sizeState.fontSize + sizeState.fontSizeLow);
          const fontSizeDifference = Math.abs(
            sizeState.fontSize - nextFontSize
          );
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
              previousWidth: width,
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
                previousWidth: width,
              });
            } else {
              // decrease size
              setSizeState({
                fontSize: nextFontSize,
                previousFontSize: sizeState.fontSize,
                fontSizeLow: sizeState.fontSizeLow,
                fontSizeHigh: sizeState.fontSize,
                previousFit: FIT.LARGE,
                previousWidth: width,
              });
            }
          }
        }
      }

      // if (boundingClientRect.height < 800) {
      //   const nextFontSize =
      //   setFontSize(fontSize + 1);
      // }
    }
  }, [elapsedMilliseconds, sizeState]);
  const style = React.useMemo(() => {
    return {
      fontSize: sizeState.fontSize,
    };
  }, [sizeState]);
  return (
    <div ref={canvasRef} className={styles.container} style={style}>
      <WordClockInner logic={logic} label={label} timeProps={timeProps} />
    </div>
  );
};

export default WordClock;

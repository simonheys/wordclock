import * as React from "react";

import useTimeProps from "../hooks/useTimeProps";
import useAnimationFrame from "../hooks/useAnimationFrame";
import * as WordsFileParser from "../modules/WordsFileParser";
import * as LogicParser from "../modules/LogicParser";

import styles from "./WordClock.module.scss";

const WordClockInner = ({ logic, label, timeProps, fontSize }) => {
  return label.map((labelGroup, labelIndex) => {
    const logicGroup = logic[labelIndex];
    return labelGroup.map((label, labelGroupIndex) => {
      if (!label.length) {
        return null;
      }
      const logic = logicGroup[labelGroupIndex];
      const highlighted = LogicParser.term(logic, timeProps);
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
  });

  const loadJson = async () => {
    const parsed = await WordsFileParser.parseJsonUrl("/English.json");
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
      const height = boundingClientRect.height;
      if (height > 0) {
        const nextFontSize = 0.5 * (sizeState.fontSize + sizeState.fontSizeLow);
        const fontSizeDifference = Math.abs(sizeState.fontSize - nextFontSize);
        // console.log(JSON.stringify({ height, sizeState }, null, 2));
        // favour smaller but within tolerance
        if (sizeState.previousFit === FIT.OK) {
          // currently FIT.OK - do nothing
        } else if (boundingClientRect.height < targetHeight) {
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

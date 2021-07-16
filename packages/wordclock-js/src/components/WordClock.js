import * as React from "react";
import ResizeObserver from "resize-observer-polyfill";

import { useTimeProps } from "../hooks/useTimeProps";
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

const WordClock = () => {
  const timeProps = useTimeProps();
  const [logic, setLogic] = React.useState([]);
  const [label, setLabel] = React.useState([]);
  const [fontSize, setFontSize] = React.useState(32);
  const loadJson = async () => {
    const parsed = await WordsFileParser.parseJsonUrl("/English.json");
    setLogic(parsed.logic);
    setLabel(parsed.label);
  };
  React.useEffect(() => {
    loadJson();
  }, []);
  const resizeObserver = React.useRef(
    new ResizeObserver((entries) => {
      console.log("entries", entries);
    })
  );

  const resizedContainerRef = React.useCallback((container) => {
    if (container !== null) {
      resizeObserver.current.observe(container);
    } else {
      if (resizeObserver.current) {
        resizeObserver.current.disconnect();
      }
    }
  }, []);

  return (
    <div
      ref={resizedContainerRef}
      className={styles.container}
      style={{ fontSize }}
    >
      <WordClockInner logic={logic} label={label} timeProps={timeProps} />
    </div>
  );
};

export default WordClock;

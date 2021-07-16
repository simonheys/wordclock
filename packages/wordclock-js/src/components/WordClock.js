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

const WordClock = () => {
  const timeProps = useTimeProps();
  const [logic, setLogic] = React.useState([]);
  const [label, setLabel] = React.useState([]);
  const [fontSize, setFontSize] = React.useState(12);

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
      if (boundingClientRect.height < 800) {
        setFontSize(fontSize + 1);
      }
    }
  }, [elapsedMilliseconds, fontSize]);
  return (
    <div ref={canvasRef} className={styles.container} style={{ fontSize }}>
      <WordClockInner logic={logic} label={label} timeProps={timeProps} />
    </div>
  );
};

export default WordClock;

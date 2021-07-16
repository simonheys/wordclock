import * as React from "react";

import { useTimeProps } from "../hooks/useTimeProps";
import * as WordsFileParser from "../modules/WordsFileParser";
import * as LogicParser from "../modules/LogicParser";
import useBoundingClientRect from "../hooks/useBoundingClientRect";

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
  //   const [fontSize, setFontSize] = React.useState(32);
  const wordClockRef = React.useRef(null);
  const loadJson = async () => {
    const parsed = await WordsFileParser.parseJsonUrl("/English.json");
    setLogic(parsed.logic);
    setLabel(parsed.label);
  };
  React.useEffect(() => {
    loadJson();
  }, []);
  const rect = useBoundingClientRect(wordClockRef);
  React.useEffect(() => {
    console.log("rect", rect);
  }, [rect]);
  //   const setWordClockRef = React.useCallback(
  //     (ref) => {
  //       if (ref) {
  //         wordClockRef.current = ref;
  //         // const rect = wordClockRef.current.getBoundingClientRect();
  //         console.log(wordClockRef.current.getBoundingClientRect());
  //         setFontSize(48);
  //         console.log(wordClockRef.current.getBoundingClientRect());
  //       }
  //     },
  //     [wordClockRef]
  //   );

  const resizeObserver = React.useRef(
    new ResizeObserver((entries) => {
      console.log("entries", entries);
    })
  );

  const resizedContainerRef = React.useCallback((container: HTMLDivElement) => {
    if (container !== null) {
      resizeObserver.current.observe(container);
    }
    // When element is unmounted, ref callback is called with a null argument
    // => best time to cleanup the observer
    else {
      if (resizeObserver.current) resizeObserver.current.disconnect();
    }
  }, []);

  //   React.useLayoutEffect(() => {
  //     for (let s = 16; s <= 48; s++) {
  //       setFontSize(s);
  //       console.log("s", s);
  //     }
  //   }, []);

  return (
    <div className={styles.container}>
      <WordClockInner logic={logic} label={label} timeProps={timeProps} />
    </div>
  );
  //   return label.map((labelGroup, labelIndex) => {
  //     const logicGroup = logic[labelIndex];
  //     return labelGroup.map((label, labelGroupIndex) => {
  //       if (!label.length) {
  //         return null;
  //       }
  //       const logic = logicGroup[labelGroupIndex];
  //       const highlighted = LogicParser.term(logic, timeProps);
  //       const style = highlighted ? { color: "red" } : null;
  //       return (
  //         <span key={`${labelIndex}-${labelGroupIndex}`} style={style}>
  //           {label}
  //         </span>
  //       );
  //     });
  //   });
  //   return <pre>{JSON.stringify(timeProps, null, 2)}</pre>;
};

export default WordClock;

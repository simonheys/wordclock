import * as React from "react";

import { useTimeProps } from "../hooks/useTimeProps";
import * as WordsFileParser from "../modules/WordsFileParser";
import * as LogicParser from "../modules/LogicParser";

const WordClockInner = ({ logic, label, timeProps, fontSize }) => {
  return label.map((labelGroup, labelIndex) => {
    const logicGroup = logic[labelIndex];
    return labelGroup.map((label, labelGroupIndex) => {
      if (!label.length) {
        return null;
      }
      const logic = logicGroup[labelGroupIndex];
      const highlighted = LogicParser.term(logic, timeProps);
      const style = highlighted ? { color: "red" } : null;
      return (
        <span key={`${labelIndex}-${labelGroupIndex}`} style={style}>
          {label}
        </span>
      );
    });
  });
};

const WordClock = () => {
  const timeProps = useTimeProps();
  const [logic, setLogic] = React.useState([]);
  const [label, setLabel] = React.useState([]);
  const wordClockRef = React.useRef(null);
  const loadJson = async () => {
    const parsed = await WordsFileParser.parseJsonUrl("/English.json");
    setLogic(parsed.logic);
    setLabel(parsed.label);
  };
  React.useEffect(() => {
    loadJson();
  }, []);
  const setWordClockRef = React.useCallback(
    (ref) => {
      if (ref) {
        wordClockRef.current = ref;
        const rect = wordClockRef.current.getBoundingClientRect();
        console.log(rect);
      }
    },
    [wordClockRef]
  );
  return (
    <div ref={setWordClockRef}>
      <WordClockInner
        fontSize={32}
        logic={logic}
        label={label}
        timeProps={timeProps}
      />
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

import { FC } from "react";
import { TimeProps } from "../hooks/useTimeProps";
import * as LogicParser from "../modules/LogicParser";
import styles from "./WordClock.module.scss";
import { WordsLabel, WordsLogic } from "../types";

interface WordClockInnerProps {
  logic: WordsLogic;
  label: WordsLabel;
  timeProps: TimeProps;
}

export const WordClockInner: FC<WordClockInnerProps> = ({
  logic,
  label,
  timeProps,
}) => {
  return (
    <>
      {label.map((labelGroup, labelIndex) => {
        const logicGroup = logic[labelIndex];
        let hasPreviousHighlight = false;
        let highlighted = false;
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
      })}
    </>
  );
};

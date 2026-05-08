import type { FC } from 'react'
import * as LogicParser from '../modules/LogicParser'
import { useWordClock } from './useWordClock'
import type { WordClockWordProps } from './WordClockWord'
import { WordClockWord } from './WordClockWord'

interface WordClockContentProps {
  wordComponent?: FC<WordClockWordProps>
}

export const WordClockContent: FC<WordClockContentProps> = ({
  wordComponent: WordComponent = WordClockWord,
}) => {
  const { logic, label, timeProps } = useWordClock()
  return (
    <>
      {label.map((labelGroup, labelIndex) => {
        const logicGroup = logic[labelIndex] ?? []
        let hasPreviousHighlight = false
        let highlighted = false
        // only allow a single highlight per group
        return labelGroup.map((label, labelGroupIndex) => {
          highlighted = false
          if (timeProps && !hasPreviousHighlight) {
            highlighted = LogicParser.term(logicGroup[labelGroupIndex] ?? '', timeProps)
            if (highlighted) {
              hasPreviousHighlight = true
            }
          }
          if (!label.length) {
            return null
          }
          return (
            <WordComponent key={`${labelIndex}-${labelGroupIndex}`} highlighted={highlighted}>
              {label}
            </WordComponent>
          )
        })
      })}
    </>
  )
}

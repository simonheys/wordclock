import type { FC } from 'react'
import * as LogicParser from '../modules/LogicParser.js'
import { useWordClock } from './useWordClock.js'
import type { WordClockWordProps } from './WordClockWord.js'
import { WordClockWord } from './WordClockWord.js'

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

import { createContext, useContext } from 'react'
import { TimeProps } from '../hooks/useTimeProps'
import { WordsLabel, WordsLogic } from './types'

interface WordClockContentProps {
  logic: WordsLogic
  label: WordsLabel
  timeProps: TimeProps
}

const WordClockContext = createContext<WordClockContentProps | null>(null)

export const useWordClock = () => {
  const context = useContext(WordClockContext)
  if (!context) {
    throw new Error('useWordClock must be used within a WordClockProvider')
  }
  return context
}

export const WordClockProvider = WordClockContext.Provider

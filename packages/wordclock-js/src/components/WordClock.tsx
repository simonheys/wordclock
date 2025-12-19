'use client'

import { CSSProperties, FC, HTMLAttributes, useEffect, useMemo } from 'react'

import { useResizeTextToFit } from '../hooks/useResizeTextToFit'
import useTimeProps from '../hooks/useTimeProps'
import * as WordsFileParser from '../modules/WordsFileParser'
import { WordsJson, WordsLabel, WordsLogic } from './types'
import { WordClockProvider } from './useWordClock'

const containerStyle: CSSProperties = {
  width: '100%',
  height: '100%',
}

const wordsStyle: CSSProperties = {
  display: 'flex',
  flexDirection: 'row',
  flexWrap: 'wrap',
  height: '100%',
  alignContent: 'space-between',
}

interface WordClockProps extends HTMLAttributes<HTMLDivElement> {
  words: WordsJson
}

export const WordClock: FC<WordClockProps> = ({ words, children, ...rest }) => {
  const { logic, label } = useMemo<{ logic: WordsLogic; label: WordsLabel }>(() => {
    if (!words) {
      return { logic: [], label: [] }
    }
    return WordsFileParser.parseJson(words)
  }, [words])

  const timeProps = useTimeProps()
  const { resizeRef, containerRef, resize } = useResizeTextToFit()

  useEffect(() => {
    resize()
  }, [logic, resize])

  return (
    <div ref={containerRef} style={containerStyle}>
      <div ref={resizeRef} style={wordsStyle} {...rest}>
        <WordClockProvider value={{ logic, label, timeProps }}>{children}</WordClockProvider>
      </div>
    </div>
  )
}

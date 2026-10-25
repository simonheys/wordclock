'use client'

import { useEffect, useMemo } from 'react'

import type { CSSProperties, FC, HTMLAttributes } from 'react'
import { useResizeTextToFit } from '../hooks/useResizeTextToFit.js'
import useTimeProps from '../hooks/useTimeProps.js'
import * as WordsFileParser from '../modules/WordsFileParser.js'
import type { WordsJson, WordsLabel, WordsLogic } from './types.js'
import { WordClockProvider } from './useWordClock.js'

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

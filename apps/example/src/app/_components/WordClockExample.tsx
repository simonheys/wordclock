'use client'

import { type ChangeEvent, useCallback, useEffect, useMemo, useState } from 'react'

import { WordClock, type WordsJson } from '@wordclock/react'

import { loadWordFile } from '../_lib/load-word-file'
import type { WordFileGroup } from '../_types/word-files'

const heights = [0, 1, 12, 60, 180, 360, 600, 900]

type WordClockExampleProps = {
  initialFile: string
  initialWords: WordsJson
  wordFileGroups: WordFileGroup[]
}

export function WordClockExample({
  initialFile,
  initialWords,
  wordFileGroups,
}: WordClockExampleProps) {
  const [file, setFile] = useState(initialFile)
  const [mounted, setMounted] = useState(true)
  const [height, setHeight] = useState(600)
  const [words, setWords] = useState(initialWords)
  const [loadError, setLoadError] = useState<string | null>(null)

  const validFiles = useMemo(() => {
    return new Set(
      wordFileGroups.flatMap((group) => {
        return group.options.map((option) => option.file)
      }),
    )
  }, [wordFileGroups])

  const onMountedChange = useCallback((event: ChangeEvent<HTMLInputElement>) => {
    setMounted(event.target.checked)
  }, [])

  const onFileChange = useCallback(
    (event: ChangeEvent<HTMLSelectElement>) => {
      const nextFile = event.target.value

      if (validFiles.has(nextFile)) {
        setLoadError(null)
        setFile(nextFile)

        if (nextFile === initialFile) {
          setWords(initialWords)
        }
      }
    },
    [initialFile, initialWords, validFiles],
  )

  const onHeightChange = useCallback((event: ChangeEvent<HTMLSelectElement>) => {
    setHeight(Number.parseInt(event.target.value, 10))
  }, [])

  useEffect(() => {
    let cancelled = false

    if (file === initialFile) {
      return
    }

    loadWordFile(file)
      .then((json) => {
        if (!cancelled) {
          setWords(json)
        }
      })
      .catch((error: unknown) => {
        if (!cancelled) {
          setLoadError(error instanceof Error ? error.message : 'Unable to load word file')
        }
      })

    return () => {
      cancelled = true
    }
  }, [file, initialFile])

  return (
    <>
      <div className="flex flex-row justify-between">
        <div>
          <input type="checkbox" id="mounted" onChange={onMountedChange} checked={mounted} />
          <label htmlFor="mounted">Mounted</label>
        </div>
        <label htmlFor="language-select">Select language and style:</label>
        <select id="language-select" value={file} onChange={onFileChange}>
          {wordFileGroups.map(({ languageTitle, options }) => {
            return (
              <optgroup key={languageTitle} label={languageTitle}>
                {options.map(({ file, title }) => {
                  return (
                    <option key={file} value={file}>
                      {title}
                    </option>
                  )
                })}
              </optgroup>
            )
          })}
        </select>
        <label htmlFor="height-select">Select height:</label>
        <select id="height-select" value={height} onChange={onHeightChange}>
          {heights.map((value) => {
            return (
              <option key={value} value={value}>
                {value}
              </option>
            )
          })}
        </select>
      </div>
      <div
        data-testid="word-clock-frame"
        className="w-full bg-gray-100 [font-feature-settings:'liga'_1,'kern'_1] leading-[1.1] font-bold tracking-tight text-gray-400 dark:bg-gray-900 dark:text-gray-700"
        style={{ height: `${height}px` }}
      >
        {loadError && <div className="p-4 text-sm text-red-600">{loadError}</div>}
        {mounted && (
          <WordClock
            data-testid="word-clock-words"
            foregroundClassName="text-gray-400 dark:text-gray-700"
            highlightClassName="text-red-500 dark:text-white"
            words={words}
          />
        )}
      </div>
    </>
  )
}

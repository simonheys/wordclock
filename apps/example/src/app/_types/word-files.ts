import type { WordsJson } from '@simonheys/wordclock'

export type WordFileOption = {
  file: string
  title: string
}

export type WordFileGroup = {
  languageTitle: string
  options: WordFileOption[]
}

export type WordClockExampleData = {
  initialFile: string
  initialWords: WordsJson
  wordFileGroups: WordFileGroup[]
}

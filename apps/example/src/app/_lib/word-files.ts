import { type Manifest, type WordsJson } from '@simonheys/wordclock'
import manifestJson from '@simonheys/wordclock-words/json/Manifest.json'

import type { WordClockExampleData, WordFileGroup } from '../_types/word-files'
import { loadWordFile } from './load-word-file'

const manifest = manifestJson as Manifest
const preferredInitialFile = 'English_simple_fragmented.json'
const initialFile = manifest.files.includes(preferredInitialFile)
  ? preferredInitialFile
  : manifest.files[0]

type LoadedWordFile = {
  file: string
  languageTitle: string
  title: string
  words: WordsJson
}

const loadWordFileOption = async (file: string): Promise<LoadedWordFile> => {
  const words = await loadWordFile(file)
  const languageTitle = manifest.languages[words.meta.language] ?? words.meta.language

  return {
    file,
    languageTitle,
    title: words.meta.title,
    words,
  }
}

const groupWordFiles = (wordFiles: LoadedWordFile[]): WordFileGroup[] => {
  const groupsByLanguage = wordFiles.reduce<Record<string, WordFileGroup['options']>>(
    (groups, { file, languageTitle, title }) => {
      if (!groups[languageTitle]) {
        groups[languageTitle] = []
      }

      groups[languageTitle].push({ file, title })
      return groups
    },
    {},
  )

  return Object.keys(groupsByLanguage)
    .sort()
    .map((languageTitle) => ({
      languageTitle,
      options: groupsByLanguage[languageTitle],
    }))
}

export const getWordClockExampleData = async (): Promise<WordClockExampleData> => {
  const wordFiles = await Promise.all(manifest.files.map(loadWordFileOption))
  const initialWords = wordFiles.find(({ file }) => file === initialFile)?.words

  if (!initialWords) {
    throw new Error(`Initial word file ${initialFile} is not listed in the manifest`)
  }

  return {
    initialFile,
    initialWords,
    wordFileGroups: groupWordFiles(wordFiles),
  }
}

import type { WordsJson } from '@wordclock/react'

export const loadWordFile = async (file: string): Promise<WordsJson> => {
  const wordFile = await import(`@wordclock/words/json/${file}`)
  return wordFile.default as WordsJson
}

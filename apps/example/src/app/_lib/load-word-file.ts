import type { WordsJson } from '@simonheys/wordclock'

export const loadWordFile = async (file: string): Promise<WordsJson> => {
  const wordFile = await import(`@simonheys/wordclock-words/json/${file}`)
  return wordFile.default as WordsJson
}

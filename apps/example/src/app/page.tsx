import { WordClockExample } from './_components/WordClockExample'
import { getWordClockExampleData } from './_lib/word-files'

export default async function Home() {
  const { initialFile, initialWords, wordFileGroups } = await getWordClockExampleData()

  return (
    <WordClockExample
      initialFile={initialFile}
      initialWords={initialWords}
      wordFileGroups={wordFileGroups}
    />
  )
}

import Link from 'next/link'

import { WordClockExample } from './_components/WordClockExample'
import { getWordClockExampleData } from './_lib/word-files'

export default async function Home() {
  const { initialFile, initialWords, wordFileGroups } = await getWordClockExampleData()

  return (
    <main className="grid gap-4 p-4">
      <Link className="w-fit underline underline-offset-4" href="/canvas">
        Canvas playground →
      </Link>
      <WordClockExample
        initialFile={initialFile}
        initialWords={initialWords}
        wordFileGroups={wordFileGroups}
      />
    </main>
  )
}

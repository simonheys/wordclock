import { render, screen } from '@testing-library/react'
import { expect, test } from 'vitest'

import json from '@simonheys/wordclock-words/json/English.json'

import { WordClock } from './WordClock'
import { WordClockContent } from './WordClockContent'
import type { WordsJson } from './types'

test('renders English.json text', async () => {
  const words = json as WordsJson
  render(
    <WordClock words={words}>
      <WordClockContent />
    </WordClock>,
  )
  const fivePastText = await screen.findByText('Five past')
  expect(fivePastText).toBeInTheDocument()
})

import type { ComponentProps } from 'react'
import { WordClock, WordClockWord, useWordClock, type WordsJson } from '@simonheys/wordclock'

const words: WordsJson = { meta: { language: 'en', title: 'Package consumer' }, groups: [] }
export const props: ComponentProps<typeof WordClock> = { words }
export const wordProps: ComponentProps<typeof WordClockWord> = { highlighted: true }
export type ClockContext = ReturnType<typeof useWordClock>

// @ts-expect-error Consumers must pass a boolean highlight flag.
export const invalidWordProps: ComponentProps<typeof WordClockWord> = { highlighted: 'yes' }

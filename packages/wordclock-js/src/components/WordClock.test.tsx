import { act, cleanup, render, screen } from '@testing-library/react'
import { renderToString } from 'react-dom/server'
import { afterEach, beforeEach, expect, test, vi } from 'vitest'

import json from '@simonheys/wordclock-words/json/English.json'

import { WordClock } from './WordClock'
import { WordClockContent } from './WordClockContent'
import type { WordsJson } from './types'

const secondsWords = {
  meta: {
    language: 'en',
    title: 'Seconds characterization fixture',
  },
  groups: [
    [
      {
        type: 'sequence',
        bind: 'second',
        first: 0,
        text: ['zero seconds', 'one second', 'two seconds'],
      },
    ],
  ],
} satisfies WordsJson

beforeEach(() => {
  vi.useFakeTimers()
})

afterEach(() => {
  cleanup()
  vi.useRealTimers()
})

test('renders English.json text', () => {
  vi.setSystemTime(new Date(2024, 0, 1, 4, 5, 0))
  const words = json as WordsJson
  render(
    <WordClock words={words}>
      <WordClockContent />
    </WordClock>,
  )
  const fivePastText = screen.getByText('Five past')
  expect(fivePastText).toBeInTheDocument()
})

test('passes HTML attributes to the rendered words container', () => {
  vi.setSystemTime(new Date(2024, 0, 1, 12, 0, 0))

  render(
    <WordClock words={secondsWords} aria-label="Word clock words" data-testid="clock-words">
      <WordClockContent />
    </WordClock>,
  )

  expect(screen.getByTestId('clock-words')).toHaveAccessibleName('Word clock words')
  expect(screen.getByTestId('clock-words')).toHaveStyle({
    display: 'flex',
    flexDirection: 'row',
    flexWrap: 'wrap',
    height: '100%',
    alignContent: 'space-between',
  })
})

test('does not render time-dependent highlights during server render', () => {
  vi.setSystemTime(new Date(2024, 0, 1, 12, 0, 0))

  const html = renderToString(
    <WordClock words={secondsWords}>
      <WordClockContent />
    </WordClock>,
  )

  expect(html).toContain('zero seconds')
  expect(html).not.toContain('#ff0000')
})

test('highlights words for the current second and updates every second', () => {
  vi.setSystemTime(new Date(2024, 0, 1, 12, 0, 0))

  render(
    <WordClock words={secondsWords}>
      <WordClockContent />
    </WordClock>,
  )

  expect(screen.getByText('zero seconds')).toHaveStyle({ color: '#ff0000' })
  expect(screen.getByText('one second')).toHaveStyle({ color: 'inherit' })

  act(() => {
    vi.advanceTimersByTime(1000)
  })

  expect(screen.getByText('zero seconds')).toHaveStyle({ color: 'inherit' })
  expect(screen.getByText('one second')).toHaveStyle({ color: '#ff0000' })
})

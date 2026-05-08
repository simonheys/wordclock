import { render, screen } from '@testing-library/react'

import type { TimeProps } from '../hooks/useTimeProps'
import { WordClockContent } from './WordClockContent'
import type { WordClockWordProps } from './WordClockWord'
import { WordClockProvider } from './useWordClock'

const timeProps: TimeProps = {
  day: 1,
  daystartingmonday: 0,
  date: 8,
  month: 0,
  hour: 3,
  twentyfourhour: 15,
  minute: 45,
  second: 12,
}

const RecordingWord = ({ highlighted, children }: WordClockWordProps) => {
  return <span data-highlighted={String(highlighted)}>{children}</span>
}

describe('WordClockContent', () => {
  it('only highlights the first matching word in each group', () => {
    const { container } = render(
      <WordClockProvider
        value={{
          label: [
            ['first match', 'second match', 'third match'],
            ['not highlighted', 'highlighted'],
          ],
          logic: [
            ['else', 'else', 'else'],
            ['minute==44', 'minute==45'],
          ],
          timeProps,
        }}
      >
        <WordClockContent wordComponent={RecordingWord} />
      </WordClockProvider>,
    )

    expect(screen.getByText('first match')).toHaveAttribute('data-highlighted', 'true')
    expect(screen.getByText('second match')).toHaveAttribute('data-highlighted', 'false')
    expect(screen.getByText('third match')).toHaveAttribute('data-highlighted', 'false')
    expect(screen.getByText('not highlighted')).toHaveAttribute('data-highlighted', 'false')
    expect(screen.getByText('highlighted')).toHaveAttribute('data-highlighted', 'true')
    expect(container.querySelectorAll('[data-highlighted]')).toHaveLength(5)
  })

  it('omits empty labels after evaluating their highlight logic', () => {
    const { container } = render(
      <WordClockProvider
        value={{
          label: [['', 'visible fallback']],
          logic: [['else', 'else']],
          timeProps,
        }}
      >
        <WordClockContent wordComponent={RecordingWord} />
      </WordClockProvider>,
    )

    expect(screen.getByText('visible fallback')).toHaveAttribute('data-highlighted', 'false')
    expect(container.querySelectorAll('[data-highlighted]')).toHaveLength(1)
  })
})

import { act, cleanup, render, screen } from '@testing-library/react'
import { renderToString } from 'react-dom/server'
import { afterEach, beforeEach, expect, test, vi } from 'vitest'

import type { WordsJson } from './types'
import { WordClock } from './WordClock'

const secondsWords = {
  meta: { language: 'en', title: 'Seconds fixture' },
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

let frameCallbacks = new Map<number, FrameRequestCallback>()
let nextFrame = 1
let currentFillStyle: string | CanvasGradient | CanvasPattern = ''
const drawnColours: string[] = []

const context = {
  clearRect: vi.fn(),
  direction: 'ltr',
  fillText: vi.fn(() => drawnColours.push(String(currentFillStyle))),
  font: '',
  fontKerning: 'normal',
  get fillStyle() {
    return currentFillStyle
  },
  set fillStyle(value: string | CanvasGradient | CanvasPattern) {
    currentFillStyle = value
  },
  measureText: vi.fn((text: string) => ({
    actualBoundingBoxAscent: 80,
    actualBoundingBoxDescent: 20,
    fontBoundingBoxAscent: 80,
    fontBoundingBoxDescent: 20,
    width: text.length * 10,
  })),
  restore: vi.fn(),
  rotate: vi.fn(),
  save: vi.fn(),
  scale: vi.fn(),
  setTransform: vi.fn(),
  textAlign: 'left',
  textBaseline: 'alphabetic',
  translate: vi.fn(),
} as unknown as CanvasRenderingContext2D

const flushInitialisation = async () => {
  await act(async () => {
    await Promise.resolve()
    await Promise.resolve()
  })
}

const runFrame = (now = 0) => {
  const callbacks = [...frameCallbacks.values()]
  frameCallbacks.clear()
  act(() => callbacks.forEach((callback) => callback(now)))
}

beforeEach(() => {
  frameCallbacks = new Map()
  nextFrame = 1
  currentFillStyle = ''
  drawnColours.length = 0
  vi.clearAllMocks()

  vi.spyOn(HTMLCanvasElement.prototype, 'getContext').mockReturnValue(context)
  vi.spyOn(HTMLElement.prototype, 'clientWidth', 'get').mockReturnValue(600)
  vi.spyOn(HTMLElement.prototype, 'clientHeight', 'get').mockReturnValue(400)
  vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => {
    const id = nextFrame++
    frameCallbacks.set(id, callback)
    return id
  })
  vi.spyOn(window, 'cancelAnimationFrame').mockImplementation((id) => {
    frameCallbacks.delete(id)
  })
})

afterEach(() => {
  cleanup()
  vi.restoreAllMocks()
})

test('draws to canvas and exposes the controlled phrase accessibly', async () => {
  render(
    <WordClock
      aria-label="Word clock words"
      data-testid="clock"
      date={new Date(2026, 7, 16, 12, 0, 1)}
      words={secondsWords}
    />,
  )
  await flushInitialisation()
  runFrame()

  expect(screen.getByTestId('clock')).toHaveAccessibleName('Word clock words')
  expect(screen.getByTestId('clock')).toHaveAttribute('data-word-clock-language', 'en')
  expect(screen.getByRole('timer')).toHaveTextContent('one second')
  expect(screen.getByRole('timer')).toHaveAttribute('dir', 'ltr')
  expect(screen.getByTestId('clock').querySelector('canvas')).toHaveAttribute('aria-hidden', 'true')
  expect(context.fillText).toHaveBeenCalled()
})

test('uses computed Tailwind-style probe colours when drawing', async () => {
  const style = document.createElement('style')
  style.textContent = `
    .clock-foreground { color: rgb(64 80 96); }
    .clock-highlight { color: rgb(240 16 32); }
  `
  document.head.append(style)

  render(
    <WordClock
      date={new Date(2026, 7, 16, 12, 0, 1)}
      foregroundClassName="clock-foreground"
      highlightClassName="clock-highlight"
      words={secondsWords}
    />,
  )
  await flushInitialisation()
  runFrame()

  expect(drawnColours).toContain('rgba(64,80,96,1)')
  expect(drawnColours).toContain('rgba(240,16,32,1)')
  style.remove()
})

test('updates when the controlled date changes', async () => {
  const view = render(<WordClock date={new Date(2026, 7, 16, 12, 0, 0)} words={secondsWords} />)
  await flushInitialisation()
  runFrame()
  expect(screen.getByRole('timer')).toHaveTextContent('zero seconds')

  view.rerender(<WordClock date={new Date(2026, 7, 16, 12, 0, 2)} words={secondsWords} />)
  runFrame(16)
  expect(screen.getByRole('timer')).toHaveTextContent('two seconds')
})

test('server rendering is deterministic and omits the time-dependent phrase', () => {
  const html = renderToString(<WordClock words={secondsWords} />)

  expect(html).toContain('<canvas')
  expect(html).not.toContain('zero seconds')
})

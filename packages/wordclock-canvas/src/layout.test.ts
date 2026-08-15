import { describe, expect, it } from 'vitest'

import { getTimeProps, parseWords, resolve } from './definition'
import { TAU } from './easing'
import {
  createCoordinates,
  createRotaryState,
  fitScale,
  layoutLinear,
  layoutRotary,
  refreshRotaryMetrics,
  updateRotaryState,
  wrap,
} from './layout'
import type { TextMetricsSource } from './measure'
import { measure } from './measure'
import type { Definition, WordsJson } from './types'

/**
 * A deterministic stand-in for canvas metrics: every glyph is half an em wide.
 * Layout is pure arithmetic on measured widths, so it can be tested without a
 * canvas or a font.
 */
const stubMetrics: TextMetricsSource = {
  measure: (text: string) => ({ width: text.length * 50, ascent: 100, descent: 18 }),
}

const wordsJson = (groups: WordsJson['groups']): WordsJson => ({
  meta: { language: 'en', title: 'test' },
  groups,
})

const sequence = (bind: 'minute' | 'second', count: number) =>
  wordsJson([
    [
      {
        type: 'sequence',
        bind,
        first: 0,
        text: Array.from({ length: count }, (_, i) => `w${i}`),
      },
    ],
  ])

const measured = (json: WordsJson): Definition => measure(parseWords(json), stubMetrics)

describe('wrap', () => {
  it('breaks a line when the next word would overflow', () => {
    const definition = measured(
      wordsJson([
        [
          {
            type: 'item',
            items: [
              { highlight: 'else', text: 'aa' }, // 100 wide
              { highlight: 'else', text: 'bb' },
              { highlight: 'else', text: 'cc' },
            ],
          },
        ],
      ]),
    )
    // space is 50 wide, so two words plus a gap need 250
    const lines = wrap(definition, { maxWidth: 260, scale: 1 })
    expect(lines).toHaveLength(2)
    expect(lines[0]?.words).toHaveLength(2)
    expect(lines[1]?.words).toHaveLength(1)
  })

  it('skips spaces, which draw nothing in the linear layout', () => {
    const definition = measured(
      wordsJson([
        [
          { type: 'item', items: [{ highlight: 'else', text: 'aa' }] },
          { type: 'space', count: 3 },
          { type: 'item', items: [{ highlight: 'else', text: 'bb' }] },
        ],
      ]),
    )
    const lines = wrap(definition, { maxWidth: 10_000, scale: 1 })
    expect(lines[0]?.words.map((entry) => entry.word.text)).toEqual(['aa', 'bb'])
  })
})

describe('fitScale', () => {
  it('finds a scale whose wrapped text fits the box', () => {
    const definition = measured(sequence('minute', 60))
    const width = 800
    const height = 600
    const scale = fitScale(definition, { width, height })

    const lines = wrap(definition, { maxWidth: width, scale })
    expect(lines.length * definition.emHeight * scale * 1.1).toBeLessThanOrEqual(height)
    for (const line of lines) {
      expect(line.width).toBeLessThanOrEqual(width)
    }
  })

  it('gives a smaller scale for a smaller box', () => {
    const definition = measured(sequence('minute', 60))
    const big = fitScale(definition, { width: 800, height: 600 })
    const small = fitScale(definition, { width: 400, height: 300 })
    expect(small).toBeLessThan(big)
  })
})

describe('layoutLinear', () => {
  it('marks every non-space word visible and leaves spaces hidden', () => {
    const definition = measured(
      wordsJson([
        [
          { type: 'item', items: [{ highlight: 'else', text: 'aa' }] },
          { type: 'space', count: 2 },
          { type: 'item', items: [{ highlight: 'else', text: 'bb' }] },
        ],
      ]),
    )
    const { coordinates } = layoutLinear(definition, { width: 500, height: 200 })
    expect(coordinates.map((c) => c.visible)).toEqual([true, false, false, true])
  })

  it('lays RTL text out from the right edge', () => {
    const json = wordsJson([
      [
        {
          type: 'item',
          items: [
            { highlight: 'else', text: 'aa' },
            { highlight: 'else', text: 'bb' },
          ],
        },
      ],
    ])
    json.meta.language = 'ar'
    const definition = measured(json)
    const width = 500
    const { coordinates } = layoutLinear(definition, { width, height: 200, scale: 1 })

    // anchors are the leading edge, so RTL starts at the right and decreases
    expect(coordinates[0]?.x).toBe(width)
    expect(coordinates[1]?.x).toBe(width - 150)
  })

  it('is unrotated', () => {
    const definition = measured(sequence('minute', 10))
    const { coordinates } = layoutLinear(definition, { width: 500, height: 200 })
    expect(coordinates.every((c) => c.r === 0)).toBe(true)
  })
})

describe('layoutRotary', () => {
  const settle = (definition: Definition, minute: number) => {
    const state = createRotaryState(definition)
    refreshRotaryMetrics(state, definition)
    const mask = new Uint8Array(definition.words.length)
    resolve(definition, getTimeProps(new Date(2026, 7, 15, 9, minute, 0)), mask)
    for (let i = 0; i < 120; i++) {
      updateRotaryState(state, definition, mask, i * 16, 16)
    }
    return { state, mask }
  }

  it('puts each ring leading edge exactly on its radius', () => {
    const definition = measured(sequence('minute', 60))
    const { state } = settle(definition, 21)
    const options = { width: 800, height: 800 }
    const { coordinates, scale } = layoutRotary(definition, state, options)

    for (const ring of state.rings) {
      const word = ring.words.find((candidate) => !candidate.isSpace)
      const coordinate = word ? coordinates[word.index] : undefined
      if (!coordinate) {
        continue
      }
      const distance = Math.hypot(coordinate.x - 400, coordinate.y - 400)
      expect(distance).toBeCloseTo(ring.displayedRadius * scale, 6)
    }
  })

  it('places the selected word on the reading line, unrotated', () => {
    const definition = measured(sequence('minute', 60))
    const { state, mask } = settle(definition, 21)
    const { coordinates } = layoutRotary(definition, state, { width: 800, height: 800 })

    const selected = definition.words.find((word) => mask[word.index] === 1)
    expect(selected).toBeDefined()
    const coordinate = selected ? coordinates[selected.index] : undefined
    expect(coordinate?.y).toBeCloseTo(400, 6) // dead east of centre
    expect(coordinate?.x).toBeGreaterThan(400)
    expect(coordinate?.r).toBeCloseTo(0, 6)
  })

  it('steps successive word indices clockwise', () => {
    const definition = measured(sequence('minute', 60))
    const { state } = settle(definition, 21)
    const { coordinates } = layoutRotary(definition, state, { width: 800, height: 800 })

    // anticlockwise-from-east angle should decrease as the index rises
    const angleOf = (index: number) => {
      const c = coordinates[index]
      if (!c) {
        return Number.NaN
      }
      return Math.atan2(-(c.y - 400), c.x - 400)
    }
    const first = angleOf(0)
    const second = angleOf(1)
    expect(Math.sin(first - second)).toBeGreaterThan(0)
  })

  it('turns anticlockwise as the selection advances', () => {
    const definition = measured(sequence('minute', 60))
    const state = createRotaryState(definition)
    refreshRotaryMetrics(state, definition)
    const mask = new Uint8Array(definition.words.length)
    const coordinates = createCoordinates(definition.words.length)

    const probe = 10
    const readProbeAngle = (minute: number, base: number) => {
      resolve(definition, getTimeProps(new Date(2026, 7, 15, 9, minute, 0)), mask)
      for (let i = 0; i < 120; i++) {
        updateRotaryState(state, definition, mask, base + i * 16, 16)
      }
      layoutRotary(definition, state, { width: 800, height: 800 }, coordinates)
      const c = coordinates[probe]
      return c ? Math.atan2(-(c.y - 400), c.x - 400) : Number.NaN
    }

    const before = readProbeAngle(21, 0)
    const after = readProbeAngle(22, 10_000)
    expect(Math.sin(after - before)).toBeGreaterThan(0)
  })

  it('does not accumulate turns as rings wrap past the end', () => {
    const definition = measured(sequence('second', 60))
    const state = createRotaryState(definition)
    refreshRotaryMetrics(state, definition)
    const mask = new Uint8Array(definition.words.length)

    // ten simulated minutes, so the seconds ring wraps ten times
    const base = new Date(2026, 7, 15, 9, 0, 0).getTime()
    for (let s = 0; s < 600; s++) {
      resolve(definition, getTimeProps(new Date(base + s * 1000)), mask)
      updateRotaryState(state, definition, mask, s * 300, 16)
    }

    for (const ring of state.rings) {
      expect(Math.abs(ring.angle)).toBeLessThan(2 * TAU)
    }
  })
})

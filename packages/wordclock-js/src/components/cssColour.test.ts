import { describe, expect, it } from 'vitest'

import { parseCssColour } from './cssColour'

const fallback = [0.1, 0.2, 0.3, 1] as const

describe('parseCssColour', () => {
  it('parses hexadecimal and modern rgb colours', () => {
    expect(parseCssColour('#ff8040cc', fallback)).toEqual([1, 128 / 255, 64 / 255, 204 / 255])
    expect(parseCssColour('rgb(10% 20% 30% / 50%)', fallback)).toEqual([0.1, 0.2, 0.3, 0.5])
  })

  it('converts the oklch colours emitted by Tailwind', () => {
    const [red, green, blue, alpha] = parseCssColour('oklch(63.7% 0.237 25.331)', fallback)

    expect(red).toBeCloseTo(251 / 255, 2)
    expect(green).toBeCloseTo(44 / 255, 2)
    expect(blue).toBeCloseTo(54 / 255, 2)
    expect(alpha).toBe(1)
  })

  it('falls back for unsupported values', () => {
    expect(parseCssColour('currentcolor', fallback)).toBe(fallback)
  })
})

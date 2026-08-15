import { describe, expect, it } from 'vitest'

import { DEFAULT_PALETTE, createColourState, updateColours } from './colour'
import { parseWords } from './definition'
import { TAU } from './easing'
import { createCoordinates } from './layout'
import { advanceTransition, createTransition, tweenCoordinates } from './transition'
import type { WordsJson } from './types'

const json = (count: number): WordsJson => ({
  meta: { language: 'en', title: 'test' },
  groups: [
    [
      {
        type: 'sequence',
        bind: 'minute',
        first: 0,
        text: Array.from({ length: count }, (_, i) => `w${i}`),
      },
    ],
  ],
})

describe('createTransition', () => {
  it('staggers words so the layout unfurls', () => {
    const transition = createTransition(parseWords(json(60)), { style: 'slow' })
    const first = transition.delays[0] ?? 0
    const last = transition.delays[59] ?? 0
    expect(first).toBe(0)
    expect(last).toBeGreaterThan(first)
    expect(transition.totalMs).toBeGreaterThan(transition.durationMs)
  })

  it('reverses the stagger on the way back', () => {
    const definition = parseWords(json(60))
    const forward = createTransition(definition, { style: 'slow' })
    const backward = createTransition(definition, { style: 'slow', reverse: true })
    expect(forward.delays[0]).toBe(0)
    expect(backward.delays[59]).toBe(0)
  })

  it('applies no stagger for the fast style', () => {
    const transition = createTransition(parseWords(json(60)), { style: 'fast' })
    expect([...transition.delays].every((delay) => delay === 0)).toBe(true)
    expect(transition.totalMs).toBe(transition.durationMs)
  })
})

describe('advanceTransition', () => {
  it('runs each word from 0 to 1 and reports completion', () => {
    const transition = createTransition(parseWords(json(10)), { style: 'fast', now: 0 })
    expect(advanceTransition(transition, 0)).toBe(false)
    expect(transition.values[0]).toBe(0)

    expect(advanceTransition(transition, transition.totalMs)).toBe(true)
    expect([...transition.values].every((value) => value === 1)).toBe(true)
  })

  it('is a pure function of elapsed time, so it can be sampled out of order', () => {
    const transition = createTransition(parseWords(json(10)), { style: 'fast', now: 0 })
    advanceTransition(transition, transition.totalMs / 2)
    const midway = [...transition.values]
    advanceTransition(transition, transition.totalMs)
    advanceTransition(transition, transition.totalMs / 2)
    expect([...transition.values]).toEqual(midway)
  })
})

describe('tweenCoordinates', () => {
  const pair = () => {
    const from = createCoordinates(1)
    const to = createCoordinates(1)
    const first = from[0]
    const second = to[0]
    if (!first || !second) {
      throw new Error('unreachable')
    }
    first.visible = true
    second.visible = true
    return { from, to, first, second }
  }

  it('interpolates position at the halfway point', () => {
    const { from, to, first, second } = pair()
    first.x = 0
    second.x = 100
    const values = new Float32Array([0.5])
    const result = tweenCoordinates(from, to, values)
    expect(result[0]?.x).toBe(50)
  })

  it('takes the shorter arc rather than unwinding a full turn', () => {
    const { from, to, first, second } = pair()
    first.r = 0
    second.r = TAU - 0.2 // visually -0.2, not +6.08
    const values = new Float32Array([1])
    const result = tweenCoordinates(from, to, values, undefined, { shortestRotation: true })
    expect(result[0]?.r).toBeCloseTo(-0.2, 6)
  })

  it('lerps raw when asked, matching macOS', () => {
    const { from, to, first, second } = pair()
    first.r = 0
    second.r = TAU - 0.2
    const values = new Float32Array([1])
    const result = tweenCoordinates(from, to, values, undefined, { shortestRotation: false })
    expect(result[0]?.r).toBeCloseTo(TAU - 0.2, 6)
  })

  it('lands exactly on the target either way', () => {
    const { from, to, first, second } = pair()
    first.r = 0.4
    second.r = TAU + 1.1
    const values = new Float32Array([1])
    const short = tweenCoordinates(from, to, values, undefined, { shortestRotation: true })
    // same orientation, mod a full turn
    const delta = (short[0]?.r ?? 0) - second.r
    expect(Math.abs(delta % TAU)).toBeCloseTo(0, 6)
  })
})

describe('updateColours', () => {
  const single = () => {
    const state = createColourState(1)
    const mask = new Uint8Array(1)
    updateColours(state, mask, DEFAULT_PALETTE, 0) // settle unhighlighted
    return { state, mask }
  }

  it('settles to the foreground colour without animating on first update', () => {
    const { state } = single()
    expect(state.words[0]?.current).toEqual([0.25, 0.25, 0.25, 1])
  })

  it('eases RGB in when highlighting on', () => {
    const { state, mask } = single()
    mask[0] = 1
    updateColours(state, mask, DEFAULT_PALETTE, 0) // starts the tween
    updateColours(state, mask, DEFAULT_PALETTE, 75) // halfway through 150ms
    // quadEaseIn(0.5) = 0.25, so 0.25 + 0.75 * 0.25
    expect(state.words[0]?.current[0]).toBeCloseTo(0.4375, 6)
  })

  it('eases RGB out when highlighting off', () => {
    const { state, mask } = single()
    mask[0] = 1
    updateColours(state, mask, DEFAULT_PALETTE, 0)
    updateColours(state, mask, DEFAULT_PALETTE, 150)
    mask[0] = 0
    updateColours(state, mask, DEFAULT_PALETTE, 200)
    updateColours(state, mask, DEFAULT_PALETTE, 275) // halfway
    // quadEaseOut(0.5) = 0.75, so 1 - 0.75 * 0.75
    expect(state.words[0]?.current[0]).toBeCloseTo(0.4375, 6)
  })

  it('resumes from the live value when interrupted mid-fade', () => {
    const { state, mask } = single()
    mask[0] = 1
    updateColours(state, mask, DEFAULT_PALETTE, 0)
    updateColours(state, mask, DEFAULT_PALETTE, 75)
    const partway = state.words[0]?.current[0] ?? 0
    expect(partway).toBeGreaterThan(0.25)
    expect(partway).toBeLessThan(1)

    mask[0] = 0
    updateColours(state, mask, DEFAULT_PALETTE, 75)
    // the reversal starts from where it got to, not from full highlight
    expect(state.words[0]?.from[0]).toBeCloseTo(partway, 6)
  })

  it('arrives exactly on the target', () => {
    const { state, mask } = single()
    mask[0] = 1
    updateColours(state, mask, DEFAULT_PALETTE, 0)
    updateColours(state, mask, DEFAULT_PALETTE, 150)
    expect(state.words[0]?.current).toEqual([1, 1, 1, 1])
  })
})

import { describe, expect, it } from 'vitest'

import { getTimeProps, parseWords, resolve } from './definition'
import { applyRotaryFit, findLongestResolvedPhrase, resolvePhrase } from './fit'
import { createRotaryState, layoutRotary, refreshRotaryMetrics, updateRotaryState } from './layout'
import { measure } from './measure'
import type { TextMetricsSource } from './measure'
import type { WordsJson } from './types'

const metrics: TextMetricsSource = {
  measure: (text) => ({ width: text.length * 10, ascent: 80, descent: 20 }),
}

const words = {
  meta: { language: 'en', title: 'fit fixture' },
  groups: [
    [
      {
        type: 'sequence',
        bind: 'second',
        first: 0,
        text: ['short', 'the longest real phrase', 'medium phrase'],
      },
    ],
  ],
} satisfies WordsJson

const createDefinition = () => measure(parseWords(words), metrics)

describe('phrase fitting', () => {
  it('measures the currently resolved phrase', () => {
    const definition = createDefinition()
    const mask = resolve(definition, getTimeProps(new Date(2026, 8, 16, 12, 0, 2)))

    expect(resolvePhrase(definition, mask)).toEqual({
      phrase: 'medium phrase',
      width: 'medium phrase'.length * 10,
    })
  })

  it('uses only phrases that can occur on the selected day', () => {
    const definition = createDefinition()
    const longest = findLongestResolvedPhrase(definition, new Date(2026, 8, 16))

    expect(longest).toMatchObject({
      hour: 0,
      minute: 0,
      second: 1,
      phrase: 'the longest real phrase',
      width: 'the longest real phrase'.length * 10,
    })
  })

  it('reserves a proportional viewport margin', () => {
    const definition = createDefinition()
    const state = refreshRotaryMetrics(createRotaryState(definition), definition)
    const mask = resolve(definition, getTimeProps(new Date(2026, 8, 16, 12, 0, 1)))
    updateRotaryState(state, definition, mask, 0)

    const coordinatesAtFive = layoutRotary(definition, state, {
      width: 800,
      height: 600,
    }).coordinates
    const five = applyRotaryFit(coordinatesAtFive, definition, state, {
      width: 800,
      height: 600,
      baseScale: 1,
      resolvedPhraseWidth: 230,
      mode: 'phrase',
      margin: 5,
    })

    const coordinatesAtTen = layoutRotary(definition, state, {
      width: 800,
      height: 600,
    }).coordinates
    const ten = applyRotaryFit(coordinatesAtTen, definition, state, {
      width: 800,
      height: 600,
      baseScale: 1,
      resolvedPhraseWidth: 230,
      mode: 'phrase',
      margin: 10,
    })

    expect(ten.scale).toBeLessThan(five.scale)
  })

  it('centres a stable maximum phrase envelope at the linear scale when it fits', () => {
    const definition = createDefinition()
    const state = refreshRotaryMetrics(createRotaryState(definition), definition)
    const mask = resolve(definition, getTimeProps(new Date(2026, 8, 16, 12, 0, 1)))
    updateRotaryState(state, definition, mask, 0)

    const width = 300
    const height = 180
    const rotary = layoutRotary(definition, state, { width, height })
    const original = rotary.coordinates.find((coordinate) => coordinate.visible)
    const originalHeight = original?.h ?? 0
    const result = applyRotaryFit(rotary.coordinates, definition, state, {
      width,
      height,
      baseScale: rotary.scale,
      linearScale: rotary.scale * 2,
      resolvedPhraseWidth: 80,
      maximumPhraseWidth: 80,
      mode: 'phrase-centred-linear-scale',
    })

    const visibleRotary = rotary.coordinates.find((coordinate) => coordinate.visible)
    expect(visibleRotary?.h).toBeCloseTo(originalHeight * 2, 6)
    expect((result.phrase.left + result.phrase.right) / 2).toBeCloseTo(width / 2, 6)
    expect((result.phrase.top + result.phrase.bottom) / 2).toBeCloseTo(height / 2, 6)
    expect(result.scale).toBeCloseTo(2, 6)
    expect(result.translateX).not.toBe(0)
    expect(result.translateY).toBe(0)
  })

  it('shrinks below the linear scale only when the maximum phrase would overflow', () => {
    const definition = createDefinition()
    const state = refreshRotaryMetrics(createRotaryState(definition), definition)
    const mask = resolve(definition, getTimeProps(new Date(2026, 8, 16, 12, 0, 1)))
    updateRotaryState(state, definition, mask, 0)

    const width = 300
    const height = 180
    const rotary = layoutRotary(definition, state, { width, height })
    const result = applyRotaryFit(rotary.coordinates, definition, state, {
      width,
      height,
      baseScale: rotary.scale,
      linearScale: rotary.scale * 2,
      resolvedPhraseWidth: 3000,
      maximumPhraseWidth: 3000,
      mode: 'phrase-centred-linear-scale',
    })

    expect(result.scale).toBeLessThan(2)
    expect((result.phrase.left + result.phrase.right) / 2).toBeCloseTo(width / 2, 6)

    const shorterPhrase = layoutRotary(definition, state, { width, height })
    const shorter = applyRotaryFit(shorterPhrase.coordinates, definition, state, {
      width,
      height,
      baseScale: shorterPhrase.scale,
      linearScale: shorterPhrase.scale * 2,
      resolvedPhraseWidth: 130,
      maximumPhraseWidth: 3000,
      mode: 'phrase-centred-linear-scale',
    })
    expect(shorter.scale).toBeCloseTo(result.scale, 6)
    expect(shorter.translateX).toBeCloseTo(result.translateX, 6)
    expect(shorter.translateY).toBeCloseTo(result.translateY, 6)
  })
})

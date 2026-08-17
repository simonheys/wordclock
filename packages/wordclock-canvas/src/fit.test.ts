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

  it('centres the wheel and caps its type at the linear scale without enlarging it', () => {
    const definition = createDefinition()
    const state = refreshRotaryMetrics(createRotaryState(definition), definition)
    const mask = resolve(definition, getTimeProps(new Date(2026, 8, 16, 12, 0, 1)))
    updateRotaryState(state, definition, mask, 0)

    const width = 300
    const height = 180
    const rotary = layoutRotary(definition, state, { width, height })
    const original = rotary.coordinates.find((coordinate) => coordinate.visible)
    const originalHeight = original?.h ?? 0
    const originalX = original?.x ?? 0
    const originalY = original?.y ?? 0
    const result = applyRotaryFit(rotary.coordinates, definition, state, {
      width,
      height,
      baseScale: rotary.scale,
      linearScale: rotary.scale / 2,
      resolvedPhraseWidth: 230,
      mode: 'linear-scale-wheel-centred',
    })

    const visibleRotary = rotary.coordinates.find((coordinate) => coordinate.visible)
    expect(visibleRotary?.h).toBeCloseTo(originalHeight / 2, 6)
    expect(visibleRotary?.x).toBeCloseTo(width / 2 + (originalX - width / 2) / 2, 6)
    expect(visibleRotary?.y).toBeCloseTo(height / 2 + (originalY - height / 2) / 2, 6)
    expect(result.scale).toBeCloseTo(0.5, 6)
    expect(result.translateX).toBe(0)
    expect(result.translateY).toBe(0)

    const alreadySmaller = layoutRotary(definition, state, { width, height })
    const uncapped = applyRotaryFit(alreadySmaller.coordinates, definition, state, {
      width,
      height,
      baseScale: alreadySmaller.scale,
      linearScale: alreadySmaller.scale * 2,
      resolvedPhraseWidth: 230,
      mode: 'linear-scale-wheel-centred',
    })
    expect(uncapped.scale).toBe(1)
  })
})

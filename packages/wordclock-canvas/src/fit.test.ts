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
})

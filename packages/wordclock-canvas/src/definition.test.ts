import { readFileSync, readdirSync } from 'node:fs'
import { createRequire } from 'node:module'
import { dirname, join } from 'node:path'

import { describe, expect, it } from 'vitest'

import { getTimeProps, millisecondsUntilNextChange, parseWords, resolve } from './definition'
import type { WordsJson } from './types'

const require = createRequire(import.meta.url)
const wordsDirectory = join(dirname(require.resolve('@simonheys/wordclock-words')), '.')

const wordFiles = readdirSync(wordsDirectory)
  .filter((name) => name.endsWith('.json') && name !== 'Manifest.json')
  .sort()

const load = (name: string): WordsJson =>
  JSON.parse(readFileSync(join(wordsDirectory, name), 'utf8')) as WordsJson

const english = load('English.json')

describe('parseWords', () => {
  it('keeps spaces as words so ring indices stay stable', () => {
    const definition = parseWords({
      meta: { language: 'en', title: 'test' },
      groups: [
        [
          { type: 'item', items: [{ highlight: 'else', text: 'One' }] },
          { type: 'space', count: 2 },
          { type: 'item', items: [{ highlight: 'else', text: 'Two' }] },
        ],
      ],
    })

    expect(definition.words).toHaveLength(4)
    expect(definition.words.map((w) => w.isSpace)).toEqual([false, true, true, false])
    // the trailing word keeps slot 3, not slot 1
    expect(definition.words[3]?.indexInGroup).toBe(3)
  })

  it('expands a sequence into one word per entry, bound to the field', () => {
    const definition = parseWords({
      meta: { language: 'en', title: 'test' },
      groups: [[{ type: 'sequence', bind: 'minute', first: 5, text: ['five', 'six'] }]],
    })

    expect(definition.words.map((w) => w.logic)).toEqual(['minute==5', 'minute==6'])
  })

  it('derives direction from the language', () => {
    expect(parseWords(english).direction).toBe('ltr')
    expect(parseWords(load('Arabic.json')).direction).toBe('rtl')
  })

  it('derives tick granularity from the compiled expressions', () => {
    const perMinute = parseWords({
      meta: { language: 'en', title: 'test' },
      groups: [[{ type: 'item', items: [{ highlight: 'minute==5', text: 'five' }] }]],
    })
    expect(perMinute.granularity).toBe('minute')
    expect(parseWords(english).granularity).toBe('second')
  })
})

describe('resolve', () => {
  it('highlights at most one word per group', () => {
    const definition = parseWords(english)
    const mask = new Uint8Array(definition.words.length)

    for (let minute = 0; minute < 60; minute += 7) {
      for (const second of [0, 13, 31, 59]) {
        resolve(definition, getTimeProps(new Date(2026, 7, 15, 9, minute, second)), mask)
        for (const group of definition.groups) {
          const lit = group.words.filter((word) => mask[word.index] === 1)
          expect(lit.length).toBeLessThanOrEqual(1)
        }
      }
    }
  })

  it('reuses the supplied buffer rather than allocating', () => {
    const definition = parseWords(english)
    const mask = new Uint8Array(definition.words.length)
    expect(resolve(definition, getTimeProps(), mask)).toBe(mask)
  })

  it('clears previously lit words', () => {
    const definition = parseWords(english)
    const mask = resolve(definition, getTimeProps(new Date(2026, 7, 15, 9, 41, 0)))
    const before = mask.reduce<number>((total, value) => total + value, 0)
    resolve(definition, getTimeProps(new Date(2026, 7, 15, 9, 42, 0)), mask)
    const after = mask.reduce<number>((total, value) => total + value, 0)
    expect(before).toBeGreaterThan(0)
    expect(after).toBeGreaterThan(0)
  })
})

describe('millisecondsUntilNextChange', () => {
  it('schedules to the next second for per-second files', () => {
    const definition = parseWords(english)
    expect(millisecondsUntilNextChange(definition, new Date(2026, 7, 15, 9, 41, 12, 250))).toBe(750)
  })

  it('schedules to the next minute when seconds are never referenced', () => {
    const definition = parseWords({
      meta: { language: 'en', title: 'test' },
      groups: [[{ type: 'item', items: [{ highlight: 'minute==5', text: 'five' }] }]],
    })
    expect(millisecondsUntilNextChange(definition, new Date(2026, 7, 15, 9, 41, 12, 250))).toBe(
      47750,
    )
  })
})

describe('the bundled corpus', () => {
  it('has word files to test', () => {
    expect(wordFiles.length).toBeGreaterThan(50)
  })

  for (const name of wordFiles) {
    it(`${name} parses and resolves across a day`, () => {
      const definition = parseWords(load(name))
      expect(definition.words.length).toBeGreaterThan(0)

      const mask = new Uint8Array(definition.words.length)
      for (let hour = 0; hour < 24; hour += 5) {
        for (const minute of [0, 1, 15, 30, 41, 59]) {
          resolve(definition, getTimeProps(new Date(2026, 7, 15, hour, minute, 33)), mask)
          for (const group of definition.groups) {
            const lit = group.words.filter((word) => mask[word.index] === 1)
            expect(lit.length).toBeLessThanOrEqual(1)
          }
        }
      }
    })
  }
})

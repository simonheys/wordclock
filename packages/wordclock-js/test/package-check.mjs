import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { createRequire } from 'node:module'

import * as esm from '@simonheys/wordclock'

const require = createRequire(import.meta.url)
const cjs = require('@simonheys/wordclock')
const expected = [
  'WordClock',
  'WordClockContent',
  'WordClockProvider',
  'WordClockWord',
  'useWordClock',
]

assert.deepEqual(Object.keys(esm).sort(), expected)
assert.deepEqual(Object.keys(cjs).sort(), expected)

for (const file of ['index.js', 'index.cjs']) {
  const source = readFileSync(new URL(`../dist/${file}`, import.meta.url), 'utf8')
  assert.match(source, /^['"]use client['"]/, `${file} must retain its client boundary`)
}

console.log('ESM and CommonJS package exports and client boundaries verified.')

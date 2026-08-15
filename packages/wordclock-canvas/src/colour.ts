import { quadEaseIn, quadEaseOut } from './easing'
import type { Palette } from './types'

/**
 * Port of the macOS WordClockWord highlight tween. Each RGBA component is its
 * own 0.15s tween starting from wherever that component currently sits, so an
 * interrupted highlight resumes rather than snapping.
 *
 * The eases are deliberately asymmetric: highlighting ON runs RGB through
 * quadEaseIn while alpha uses quadEaseOut; highlighting OFF runs all four
 * through quadEaseOut. The colour ramps in slowly and lets go quickly.
 */

const COLOUR_TWEEN_MS = 150

/** macOS factory defaults. */
export const DEFAULT_PALETTE: Palette = {
  foreground: [0.25, 0.25, 0.25, 1],
  highlight: [1, 1, 1, 1],
  background: [0, 0, 0, 1],
}

interface WordColour {
  current: [number, number, number, number]
  from: [number, number, number, number]
  to: [number, number, number, number]
  startedAt: number
  rgbEaseIn: boolean
  highlighted: boolean
}

export interface ColourState {
  words: WordColour[]
  initialised: boolean
}

export function createColourState(count: number): ColourState {
  return {
    words: Array.from({ length: count }, () => ({
      current: [0, 0, 0, 0] as [number, number, number, number],
      from: [0, 0, 0, 0] as [number, number, number, number],
      to: [0, 0, 0, 0] as [number, number, number, number],
      startedAt: -1,
      rgbEaseIn: false,
      highlighted: false,
    })),
    initialised: false,
  }
}

export function updateColours(
  state: ColourState,
  mask: Uint8Array,
  palette: Palette,
  now: number,
): ColourState {
  const first = !state.initialised

  state.words.forEach((word, i) => {
    const wanted = mask[i] === 1

    if (first) {
      const target = wanted ? palette.highlight : palette.foreground
      for (let k = 0; k < 4; k++) {
        word.current[k] = target[k] ?? 0
      }
      word.highlighted = wanted
      return
    }

    if (wanted !== word.highlighted) {
      word.highlighted = wanted
      const target = wanted ? palette.highlight : palette.foreground
      for (let k = 0; k < 4; k++) {
        word.from[k] = word.current[k] ?? 0 // start from the live value
        word.to[k] = target[k] ?? 0
      }
      word.startedAt = now
      word.rgbEaseIn = wanted // ease in towards highlight, out on the way back
    }
  })

  if (first) {
    state.initialised = true
    return state
  }

  for (const word of state.words) {
    if (word.startedAt < 0) {
      continue
    }
    const t = (now - word.startedAt) / COLOUR_TWEEN_MS
    if (t >= 1) {
      for (let k = 0; k < 4; k++) {
        word.current[k] = word.to[k] ?? 0
      }
      word.startedAt = -1
      continue
    }
    const rgbEase = word.rgbEaseIn ? quadEaseIn(t) : quadEaseOut(t)
    const alphaEase = quadEaseOut(t)
    for (let k = 0; k < 3; k++) {
      const from = word.from[k] ?? 0
      word.current[k] = from + ((word.to[k] ?? 0) - from) * rgbEase
    }
    const fromAlpha = word.from[3] ?? 0
    word.current[3] = fromAlpha + ((word.to[3] ?? 0) - fromAlpha) * alphaEase
  }

  return state
}

const channel = (value: number) => Math.round(Math.min(Math.max(value, 0), 1) * 255)

export function colourStyle(state: ColourState, index: number): string {
  const word = state.words[index]
  if (word === undefined) {
    return 'rgba(0,0,0,0)'
  }
  const [r, g, b, a] = word.current
  return `rgba(${channel(r)},${channel(g)},${channel(b)},${a})`
}

export function rgbaStyle(colour: Palette['background']): string {
  const [r, g, b, a] = colour
  return `rgba(${channel(r)},${channel(g)},${channel(b)},${a})`
}

/** True while the word is highlighted or still fading. */
export function isFront(state: ColourState, index: number): boolean {
  const word = state.words[index]
  return word !== undefined && (word.highlighted || word.startedAt >= 0)
}

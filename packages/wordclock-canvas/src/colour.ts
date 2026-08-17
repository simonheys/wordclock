import { quadEaseIn, quadEaseOut } from './easing'
import type { Palette, Rgba } from './types'

/**
 * A single 150ms elapsed-time transition per word, sampled at the renderer's
 * requestAnimationFrame cadence. RGB endpoints are converted to perceptually
 * uniform Oklab once when the target changes; alpha is interpolated separately.
 * An interrupted transition restarts from the colour currently on screen.
 *
 * The eases are deliberately asymmetric: highlighting ON runs RGB through
 * quadEaseIn while alpha uses quadEaseOut; highlighting OFF runs colour and
 * alpha through quadEaseOut. The colour ramps in slowly and lets go quickly.
 */

const COLOUR_TWEEN_MS = 150

type MutableRgba = [number, number, number, number]
type Oklab = [number, number, number]

const clamp01 = (value: number) => Math.min(1, Math.max(0, value))

const srgbToLinear = (value: number) =>
  value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4

const linearToSrgb = (value: number) =>
  value <= 0.0031308 ? value * 12.92 : 1.055 * value ** (1 / 2.4) - 0.055

/** CSS Color 4 sRGB -> Oklab conversion, written into a reusable tuple. */
const writeOklab = (colour: Rgba, output: Oklab) => {
  const red = srgbToLinear(colour[0])
  const green = srgbToLinear(colour[1])
  const blue = srgbToLinear(colour[2])
  const l = Math.cbrt(0.4122214708 * red + 0.5363325363 * green + 0.0514459929 * blue)
  const m = Math.cbrt(0.2119034982 * red + 0.6806995451 * green + 0.1073969566 * blue)
  const s = Math.cbrt(0.0883024619 * red + 0.2817188376 * green + 0.6299787005 * blue)

  output[0] = 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s
  output[1] = 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s
  output[2] = 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s
}

/** Interpolates Oklab endpoints and writes a clamped sRGB result without allocating. */
const writeInterpolatedSrgb = (from: Oklab, to: Oklab, progress: number, output: MutableRgba) => {
  const lightness = from[0] + (to[0] - from[0]) * progress
  const a = from[1] + (to[1] - from[1]) * progress
  const b = from[2] + (to[2] - from[2]) * progress
  const lRoot = lightness + 0.3963377774 * a + 0.2158037573 * b
  const mRoot = lightness - 0.1055613458 * a - 0.0638541728 * b
  const sRoot = lightness - 0.0894841775 * a - 1.291485548 * b
  const l = lRoot * lRoot * lRoot
  const m = mRoot * mRoot * mRoot
  const s = sRoot * sRoot * sRoot

  output[0] = clamp01(linearToSrgb(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s))
  output[1] = clamp01(linearToSrgb(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s))
  output[2] = clamp01(linearToSrgb(-0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s))
}

/** macOS factory defaults. */
export const DEFAULT_PALETTE: Palette = {
  foreground: [0.25, 0.25, 0.25, 1],
  highlight: [1, 1, 1, 1],
  background: [0, 0, 0, 1],
}

interface WordColour {
  current: MutableRgba
  from: MutableRgba
  to: MutableRgba
  fromOklab: Oklab
  toOklab: Oklab
  startedAt: number
  rgbEaseIn: boolean
  highlighted: boolean
  fadingFromHighlight: boolean
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
      fromOklab: [0, 0, 0],
      toOklab: [0, 0, 0],
      startedAt: -1,
      rgbEaseIn: false,
      highlighted: false,
      fadingFromHighlight: false,
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
    const target = wanted ? palette.highlight : palette.foreground

    if (first) {
      for (let k = 0; k < 4; k++) {
        const value = target[k] ?? 0
        word.current[k] = value
        word.from[k] = value
        word.to[k] = value
      }
      writeOklab(target, word.fromOklab)
      writeOklab(target, word.toOklab)
      word.highlighted = wanted
      word.fadingFromHighlight = false
      return
    }

    const targetChanged = target.some((value, k) => value !== word.to[k])
    if (wanted !== word.highlighted || targetChanged) {
      const wasFront = word.highlighted || word.fadingFromHighlight
      word.highlighted = wanted
      word.fadingFromHighlight = !wanted && wasFront
      for (let k = 0; k < 4; k++) {
        word.from[k] = word.current[k] ?? 0 // start from the live value
        word.to[k] = target[k] ?? 0
      }
      writeOklab(word.current, word.fromOklab)
      writeOklab(target, word.toOklab)
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
      word.fadingFromHighlight = false
      continue
    }
    const rgbEase = word.rgbEaseIn ? quadEaseIn(t) : quadEaseOut(t)
    const alphaEase = quadEaseOut(t)
    writeInterpolatedSrgb(word.fromOklab, word.toOklab, rgbEase, word.current)
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
  return word !== undefined && (word.highlighted || word.fadingFromHighlight)
}

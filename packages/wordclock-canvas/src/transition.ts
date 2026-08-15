import { TAU, quadEaseInOut, quadEaseOut, shortestAngleDelta } from './easing'
import { createCoordinates } from './layout'
import type { Coordinate, Definition } from './types'

/**
 * Every word gets its own delay so the layout unfurls rather than snapping, and
 * the order reverses on the way back to linear. Ported from the macOS
 * WordClockWordLayout transition.
 */

export type TransitionStyle = 'slow' | 'medium' | 'fast'

const STYLES: Record<TransitionStyle, { durationMs: number; spreadMs: number }> = {
  slow: { durationMs: 2000, spreadMs: 1000 / 60 },
  medium: { durationMs: 2000, spreadMs: 1000 / 180 },
  fast: { durationMs: 1500, spreadMs: 0 },
}

export interface Transition {
  delays: Float32Array
  values: Float32Array
  durationMs: number
  startedAt: number
  totalMs: number
  reverse: boolean
  style: TransitionStyle
}

export interface TransitionOptions {
  /** Reverse the stagger. Use when returning to the linear layout. */
  reverse?: boolean
  style?: TransitionStyle
  now?: number
}

export function createTransition(
  definition: Definition,
  { reverse = false, style = 'medium', now = 0 }: TransitionOptions = {},
): Transition {
  const count = definition.words.length
  const { durationMs, spreadMs } = STYLES[style]
  const delays = new Float32Array(count)
  const values = new Float32Array(count)

  let longest = 0
  for (let i = 0; i < count; i++) {
    const word = definition.words[reverse ? count - 1 - i : i]
    if (word === undefined) {
      continue
    }
    const delay = i * quadEaseOut(i / count) * spreadMs
    delays[word.index] = delay
    if (delay > longest) {
      longest = delay
    }
  }

  return {
    delays,
    values,
    durationMs,
    startedAt: now,
    totalMs: longest + durationMs,
    reverse,
    style,
  }
}

/** Advances every word's progress. Returns true once all have arrived. */
export function advanceTransition(transition: Transition, now: number): boolean {
  const { delays, values, durationMs, startedAt } = transition
  let done = true

  for (let i = 0; i < delays.length; i++) {
    const t = (now - startedAt - (delays[i] ?? 0)) / durationMs
    if (t <= 0) {
      values[i] = 0
      done = false
    } else if (t >= 1) {
      values[i] = 1
    } else {
      values[i] = quadEaseInOut(t)
      done = false
    }
  }
  return done
}

export interface TweenOptions {
  /**
   * Take each word by the smaller arc to its target orientation. Rotations are
   * equivalent mod 2pi so the settled result is identical, but the far side of a
   * ring is nearly a full turn from the linear layout and would otherwise spin
   * most of the way round to arrive where it started. macOS lerps raw.
   */
  shortestRotation?: boolean
}

/**
 * `from` is a frozen snapshot; `to` stays live, so the rings keep turning
 * underneath the transition exactly as the macOS version does.
 */
export function tweenCoordinates(
  from: readonly Coordinate[],
  to: readonly Coordinate[],
  values: Float32Array,
  out?: Coordinate[],
  { shortestRotation = true }: TweenOptions = {},
): Coordinate[] {
  const coordinates = out ?? createCoordinates(from.length)

  for (let i = 0; i < from.length; i++) {
    const a = from[i]
    const b = to[i]
    const c = coordinates[i]
    if (a === undefined || b === undefined || c === undefined) {
      continue
    }
    const m = values[i] ?? 0
    const delta = b.r - a.r
    c.x = a.x + m * (b.x - a.x)
    c.y = a.y + m * (b.y - a.y)
    c.w = a.w + m * (b.w - a.w)
    c.h = a.h + m * (b.h - a.h)
    c.r = a.r + m * (shortestRotation ? shortestAngleDelta(delta) : delta)
    c.visible = a.visible || b.visible
  }

  return coordinates
}

export { TAU }

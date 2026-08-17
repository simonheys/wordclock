import { TAU, easeOutBack, normaliseAngle } from './easing'
import type { Coordinate, Definition, Pivot, Word, WordGroup } from './types'

export function createCoordinates(count: number): Coordinate[] {
  return Array.from({ length: count }, () => ({ x: 0, y: 0, w: 0, h: 0, r: 0, visible: false }))
}

export function cloneCoordinates(coordinates: readonly Coordinate[]): Coordinate[] {
  return coordinates.map((c) => ({ ...c }))
}

const hide = (coordinates: Coordinate[]) => {
  for (const coordinate of coordinates) {
    coordinate.visible = false
  }
}

// ____________________________________________________________________________ linear

export interface LinearOptions {
  width: number
  height: number
  /** Word gap as a multiple of the space advance. */
  tracking?: number
  /** Extra line height as a fraction of the em. */
  leading?: number
  align?: 'left' | 'center' | 'right'
  pivot?: Pivot
  /** Overrides the fitted scale. */
  scale?: number
}

interface WrappedWord {
  word: Word
  x: number
  width: number
}

interface WrappedLine {
  words: WrappedWord[]
  width: number
}

/**
 * Line breaking is pure arithmetic on the measured widths — no DOM, no reflow —
 * so it is safe to call repeatedly inside the scale search below.
 */
export function wrap(
  definition: Definition,
  { maxWidth, scale, tracking = 1 }: { maxWidth: number; scale: number; tracking?: number },
): WrappedLine[] {
  const lines: WrappedLine[] = []
  const gap = definition.spaceWidth * tracking * scale
  let line: WrappedWord[] = []
  let x = 0

  for (const word of definition.words) {
    if (word.isSpace) {
      continue // linear drops spaces; rotary keeps their slot
    }
    const width = word.width * scale
    if (line.length > 0 && x + width > maxWidth) {
      lines.push({ words: line, width: x - gap })
      line = []
      x = 0
    }
    line.push({ word, x, width })
    x += width + gap
  }

  if (line.length > 0) {
    lines.push({ words: line, width: x - gap })
  }
  return lines
}

/** Largest scale whose wrapped text still fits the box. */
export function fitScale(definition: Definition, options: LinearOptions): number {
  const { width, height, tracking = 1, leading = 0 } = options
  // CSS line-height is based on the em, not the font's full bounding box. The
  // latter can be substantially taller (118px for a 100px system font in
  // Chromium), which makes a fitted clock much smaller than equivalent DOM
  // text. Keep ascent/descent for drawing and use the reference em for rows.
  const lineHeight = definition.referenceSize * (1 + leading)
  if (
    !Number.isFinite(width) ||
    !Number.isFinite(height) ||
    !Number.isFinite(lineHeight) ||
    width <= 0 ||
    height <= 0 ||
    lineHeight <= 0
  ) {
    return 0
  }

  const fits = (scale: number) => {
    const lines = wrap(definition, { maxWidth: width, scale, tracking })
    return (
      lines.length > 0 &&
      lines.length * lineHeight * scale <= height &&
      lines.every((line) => line.width <= width)
    )
  }

  let low = 0
  let high = 1

  while (fits(high)) {
    low = high
    high *= 2
  }

  for (let i = 0; i < 24; i++) {
    const mid = (low + high) / 2
    if (fits(mid)) {
      low = mid
    } else {
      high = mid
    }
  }
  return low
}

export interface LinearResult {
  coordinates: Coordinate[]
  scale: number
  lines: number
  lineHeight: number
}

export function layoutLinear(
  definition: Definition,
  options: LinearOptions,
  out?: Coordinate[],
): LinearResult {
  const { width, height, tracking = 1, leading = 0, align = 'left', pivot = 'leading' } = options
  const scale = options.scale ?? fitScale(definition, options)
  const lines = wrap(definition, { maxWidth: width, scale, tracking })
  const lineHeight = definition.referenceSize * scale * (1 + leading)
  const rtl = definition.direction === 'rtl'
  const centrePivot = pivot === 'centre'

  const coordinates = out ?? createCoordinates(definition.words.length)
  hide(coordinates)

  // the baseline sits below the glyph body's centre by this much
  const bodyOffset = ((definition.ascent - definition.descent) / 2) * scale

  // distribute lines to fill the height, matching `align-content: space-between`
  const slack = height - lines.length * lineHeight
  const step = lines.length > 1 ? lineHeight + slack / (lines.length - 1) : lineHeight

  lines.forEach((line, lineIndex) => {
    const y = lineIndex * step + definition.ascent * scale
    let offset = 0
    if (align === 'center') {
      offset = (width - line.width) / 2
    } else if (align === 'right') {
      offset = width - line.width
    }

    for (const entry of line.words) {
      const coordinate = coordinates[entry.word.index]
      if (coordinate === undefined) {
        continue
      }
      const anchor = rtl ? width - offset - entry.x : offset + entry.x
      const half = (rtl ? -entry.width : entry.width) / 2
      coordinate.x = centrePivot ? anchor + half : anchor
      coordinate.y = y - bodyOffset
      coordinate.w = entry.width
      coordinate.h = definition.emHeight * scale
      coordinate.r = 0
      coordinate.visible = true
    }
  })

  return { coordinates, scale, lines: lines.length, lineHeight }
}

// ____________________________________________________________________________ rotary

/**
 * One concentric ring per group. Words are spokes reading radially outward, and
 * each ring's radius starts where the previous ring's selected word ended — so
 * the selected words lay end to end and the phrase still reads across the wheel.
 */

/** macOS uses a base radius of 100 against a 24pt unscaled font. */
const BASE_RADIUS_EM = 100 / 24

/**
 * macOS uses a fixed scale rather than fitting, so the outer rings deliberately
 * overflow the frame. Expressed here as type size relative to the smaller edge,
 * which keeps it resolution independent.
 */
const TYPE_DIVISOR = 30

const ANGLE_TWEEN_MS = 300

interface RotaryRing {
  index: number
  words: Word[]
  count: number
  maximumWidth: number
  selectedIndex: number
  angle: number
  angleFrom: number
  angleTo: number
  angleStartedAt: number
  radius: number
  displayedRadius: number
}

export interface RotaryState {
  rings: RotaryRing[]
  baseRadius: number
  initialised: boolean
  measured: boolean
}

export function createRotaryState(definition: Definition): RotaryState {
  const rings = definition.groups.map((group: WordGroup) => ({
    index: group.index,
    words: group.words,
    count: group.words.length,
    maximumWidth: 0,
    selectedIndex: -1,
    angle: 0,
    angleFrom: 0,
    angleTo: 0,
    angleStartedAt: Number.NEGATIVE_INFINITY,
    radius: 0,
    displayedRadius: 0,
  }))

  return { rings, baseRadius: 0, initialised: false, measured: false }
}

/** Call after `measure`, and again whenever the font changes. */
export function refreshRotaryMetrics(
  state: RotaryState,
  definition: Definition,
  { baseRadiusEm = BASE_RADIUS_EM }: { baseRadiusEm?: number } = {},
): RotaryState {
  for (const ring of state.rings) {
    let maximumWidth = 0
    for (const word of ring.words) {
      if (word.width > maximumWidth) {
        maximumWidth = word.width
      }
    }
    ring.maximumWidth = maximumWidth
  }
  // radii are in reference-size units; scale is applied at layout time
  state.baseRadius = baseRadiusEm * definition.referenceSize
  state.measured = true
  return state
}

const selectedIndexForRing = (ring: RotaryRing, mask: Uint8Array): number => {
  for (const word of ring.words) {
    if (!word.isSpace && mask[word.index] === 1) {
      return word.indexInGroup
    }
  }
  return -1
}

export function updateRotaryState(
  state: RotaryState,
  definition: Definition,
  mask: Uint8Array,
  now: number,
  deltaMs = 1000 / 60,
): RotaryState {
  for (const ring of state.rings) {
    const selectedIndex = selectedIndexForRing(ring, mask)
    if (selectedIndex !== ring.selectedIndex) {
      ring.selectedIndex = selectedIndex
      if (selectedIndex !== -1) {
        let target = (TAU * selectedIndex) / ring.count
        if (!state.initialised) {
          ring.angle = target
          ring.angleFrom = target
          ring.angleTo = target
          ring.angleStartedAt = Number.NEGATIVE_INFINITY
        } else {
          // Wrap into [0, 2pi) before taking the short way round. Without this
          // each 59->0 wrap permanently gains a turn, and the linear<->rotary
          // tween then unwinds every accumulated revolution.
          const current = normaliseAngle(ring.angle)
          while (target - current > Math.PI) {
            target -= TAU
          }
          while (target - current < -Math.PI) {
            target += TAU
          }
          ring.angle = current
          ring.angleFrom = current
          ring.angleTo = target
          ring.angleStartedAt = now
        }
      }
    }
  }

  for (const ring of state.rings) {
    if (ring.angleStartedAt === Number.NEGATIVE_INFINITY) {
      continue
    }
    const t = (now - ring.angleStartedAt) / ANGLE_TWEEN_MS
    if (t >= 1) {
      ring.angle = ring.angleTo
      ring.angleStartedAt = Number.NEGATIVE_INFINITY
    } else {
      ring.angle = ring.angleFrom + (ring.angleTo - ring.angleFrom) * easeOutBack(t)
    }
  }

  // each ring clears the previous ring's selected word
  let radius = state.baseRadius
  for (const ring of state.rings) {
    ring.radius = radius
    const selected = ring.selectedIndex === -1 ? undefined : ring.words[ring.selectedIndex]
    const width = selected !== undefined && !selected.isSpace ? selected.width : 0
    radius += width > 1 ? width + definition.spaceWidth : 0
  }

  // macOS halves the gap per frame; expressed here so it is frame-rate independent
  const factor = state.initialised ? 1 - Math.pow(0.5, deltaMs / (1000 / 60)) : 1
  for (const ring of state.rings) {
    ring.displayedRadius += (ring.radius - ring.displayedRadius) * factor
  }

  state.initialised = true
  return state
}

export interface RotaryOptions {
  width: number
  height: number
  centreX?: number
  centreY?: number
  pivot?: Pivot
  typeDivisor?: number
  /** Overrides the derived scale. */
  scale?: number
}

export function fitRotaryScale(definition: Definition, options: RotaryOptions): number {
  const { width, height, typeDivisor = TYPE_DIVISOR } = options
  return Math.min(width, height) / typeDivisor / definition.referenceSize
}

export interface RotaryResult {
  coordinates: Coordinate[]
  scale: number
  rings: number
}

export function layoutRotary(
  definition: Definition,
  state: RotaryState,
  options: RotaryOptions,
  out?: Coordinate[],
): RotaryResult {
  const { width, height, pivot = 'leading' } = options
  const scale = options.scale ?? fitRotaryScale(definition, options)
  const centreX = options.centreX ?? width / 2
  const centreY = options.centreY ?? height / 2
  const centrePivot = pivot === 'centre'
  const rtl = definition.direction === 'rtl'

  // LTR reads outward from 3 o'clock, RTL outward from 9 o'clock
  const readingAngle = rtl ? -Math.PI / 2 : Math.PI / 2

  const coordinates = out ?? createCoordinates(definition.words.length)
  hide(coordinates)

  for (const ring of state.rings) {
    const ringAngle = readingAngle + ring.angle
    const radius = ring.displayedRadius * scale

    for (const word of ring.words) {
      if (word.isSpace) {
        continue // holds its slot on the ring, draws nothing
      }
      const coordinate = coordinates[word.index]
      if (coordinate === undefined) {
        continue
      }

      const a = ringAngle - (TAU * word.indexInGroup) / ring.count
      const wordWidth = word.width * scale
      const distance = radius + (centrePivot ? wordWidth / 2 : 0)

      // The advance runs radially outward along (sin a, -cos a). macOS builds
      // its ortho matrix with bottom/top swapped, so its world y already runs
      // down the screen as canvas does — do not negate y here, or the wheel
      // mirrors and both the turn direction and the index order reverse.
      coordinate.x = centreX + Math.sin(a) * distance
      coordinate.y = centreY + Math.cos(a) * distance
      coordinate.w = wordWidth
      coordinate.h = definition.emHeight * scale
      coordinate.r = readingAngle - a
      coordinate.visible = true
    }
  }

  return { coordinates, scale, rings: state.rings.length }
}

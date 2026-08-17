import { getTimeProps, resolve } from './definition'
import type { RotaryState } from './layout'
import type { Coordinate, Definition } from './types'

export type RotaryFitMode =
  | 'none'
  | 'phrase'
  | 'phrase-wheel-centred'
  | 'linear-scale-wheel-centred'

export interface Bounds {
  left: number
  right: number
  top: number
  bottom: number
}

export interface ResolvedPhrase {
  phrase: string
  width: number
}

export interface LongestResolvedPhrase extends ResolvedPhrase {
  hour: number
  minute: number
  second: number
}

export interface RotaryFitOptions {
  width: number
  height: number
  baseScale: number
  /** Fitted linear-layout scale, used to cap the rotary type size. */
  linearScale?: number
  resolvedPhraseWidth: number
  maximumPhraseWidth?: number
  mode?: RotaryFitMode
  /** Margin on every edge as a percentage of the viewport's shorter side. */
  margin?: number
  translateX?: number
  translateY?: number
}

export interface RotaryFitResult {
  phrase: Bounds
  scale: number
  translateX: number
  translateY: number
}

const longestPhraseCache = new WeakMap<Definition, Map<string, LongestResolvedPhrase>>()

const dateKey = (date: Date) => `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`

export const resolvePhrase = (definition: Definition, mask: Uint8Array): ResolvedPhrase => {
  const words: string[] = []
  let width = 0
  for (const word of definition.words) {
    if (mask[word.index] !== 1) {
      continue
    }
    if (words.length > 0) {
      width += definition.spaceWidth
    }
    words.push(word.text)
    width += word.width
  }
  return { phrase: words.join(' '), width }
}

/** Finds the widest phrase that can actually resolve on the supplied local day. */
export const findLongestResolvedPhrase = (
  definition: Definition,
  referenceDate: Date = new Date(),
): LongestResolvedPhrase => {
  let cache = longestPhraseCache.get(definition)
  if (cache === undefined) {
    cache = new Map()
    longestPhraseCache.set(definition, cache)
  }
  const key = dateKey(referenceDate)
  const cached = cache.get(key)
  if (cached !== undefined) {
    return cached
  }

  const mask = new Uint8Array(definition.words.length)
  const candidate = new Date(referenceDate)
  const hours = definition.fields.has('twentyfourhour')
    ? 24
    : definition.fields.has('hour')
      ? 12
      : 1
  const minutes = definition.fields.has('minute') ? 60 : 1
  const seconds = definition.fields.has('second') ? 60 : 1
  let longest: LongestResolvedPhrase = {
    hour: 0,
    minute: 0,
    second: 0,
    phrase: '',
    width: 0,
  }

  candidate.setMilliseconds(0)
  for (let hour = 0; hour < hours; hour++) {
    candidate.setHours(hour)
    for (let minute = 0; minute < minutes; minute++) {
      candidate.setMinutes(minute)
      for (let second = 0; second < seconds; second++) {
        candidate.setSeconds(second)
        resolve(definition, getTimeProps(candidate), mask)
        const phrase = resolvePhrase(definition, mask)
        if (phrase.width > longest.width) {
          longest = { hour, minute, second, ...phrase }
        }
      }
    }
  }

  cache.set(key, longest)
  return longest
}

const transformCoordinates = (
  coordinates: Coordinate[],
  originX: number,
  originY: number,
  scale: number,
  translateX: number,
  translateY: number,
) => {
  for (const coordinate of coordinates) {
    coordinate.x = originX + (coordinate.x - originX) * scale + translateX
    coordinate.y = originY + (coordinate.y - originY) * scale + translateY
    coordinate.w *= scale
    coordinate.h *= scale
  }
}

const readingLineBounds = (
  definition: Definition,
  state: RotaryState,
  phraseWidth: number,
  scale: number,
  originX: number,
  originY: number,
): Bounds => {
  const halfHeight = (definition.emHeight * scale) / 2
  const inner = state.baseRadius * scale
  const outer = (state.baseRadius + phraseWidth) * scale
  if (definition.direction === 'rtl') {
    return {
      left: originX - outer,
      right: originX - inner,
      top: originY - halfHeight,
      bottom: originY + halfHeight,
    }
  }
  return {
    left: originX + inner,
    right: originX + outer,
    top: originY - halfHeight,
    bottom: originY + halfHeight,
  }
}

const transformBounds = (
  bounds: Bounds,
  originX: number,
  originY: number,
  scale: number,
  translateX: number,
  translateY: number,
): Bounds => ({
  left: originX + (bounds.left - originX) * scale + translateX,
  right: originX + (bounds.right - originX) * scale + translateX,
  top: originY + (bounds.top - originY) * scale + translateY,
  bottom: originY + (bounds.bottom - originY) * scale + translateY,
})

export const applyRotaryFit = (
  coordinates: Coordinate[],
  definition: Definition,
  state: RotaryState,
  {
    width,
    height,
    baseScale,
    linearScale = baseScale,
    resolvedPhraseWidth,
    maximumPhraseWidth = resolvedPhraseWidth,
    mode = 'none',
    margin = 5,
    translateX = 0,
    translateY = 0,
  }: RotaryFitOptions,
): RotaryFitResult => {
  const originX = width / 2
  const originY = height / 2
  const phrase = readingLineBounds(
    definition,
    state,
    resolvedPhraseWidth,
    baseScale,
    originX,
    originY,
  )
  if (mode === 'none') {
    if (translateX !== 0 || translateY !== 0) {
      transformCoordinates(coordinates, originX, originY, 1, translateX, translateY)
    }
    return {
      phrase: transformBounds(phrase, originX, originY, 1, translateX, translateY),
      scale: 1,
      translateX,
      translateY,
    }
  }

  if (mode === 'linear-scale-wheel-centred') {
    const cappedScale = Math.min(baseScale, linearScale)
    const scale = baseScale > 0 ? cappedScale / baseScale : 1
    transformCoordinates(coordinates, originX, originY, scale, translateX, translateY)
    return {
      phrase: transformBounds(phrase, originX, originY, scale, translateX, translateY),
      scale,
      translateX,
      translateY,
    }
  }

  const scaleReference = readingLineBounds(
    definition,
    state,
    maximumPhraseWidth,
    baseScale,
    originX,
    originY,
  )
  const padding = Math.min(width, height) * (Math.min(49, Math.max(0, margin)) / 100)
  const boundsWidth = Math.max(1, scaleReference.right - scaleReference.left)
  const boundsHeight = Math.max(1, scaleReference.bottom - scaleReference.top)
  let scale = 1
  let offsetX = translateX
  let offsetY = translateY

  if (mode === 'phrase') {
    scale = Math.min((width - padding * 2) / boundsWidth, (height - padding * 2) / boundsHeight)
    const boundsCentreX = (scaleReference.left + scaleReference.right) / 2
    const boundsCentreY = (scaleReference.top + scaleReference.bottom) / 2
    offsetX += width / 2 - (originX + (boundsCentreX - originX) * scale)
    offsetY += height / 2 - (originY + (boundsCentreY - originY) * scale)
  } else {
    const leftExtent = Math.max(0, originX - scaleReference.left)
    const rightExtent = Math.max(0, scaleReference.right - originX)
    const topExtent = Math.max(0, originY - scaleReference.top)
    const bottomExtent = Math.max(0, scaleReference.bottom - originY)
    const leftRatio = leftExtent > 0 ? (originX - padding) / leftExtent : 1
    const rightRatio = rightExtent > 0 ? (width - padding - originX) / rightExtent : 1
    const topRatio = topExtent > 0 ? (originY - padding) / topExtent : 1
    const bottomRatio = bottomExtent > 0 ? (height - padding - originY) / bottomExtent : 1
    scale = Math.min(leftRatio, rightRatio, topRatio, bottomRatio)
  }

  transformCoordinates(coordinates, originX, originY, scale, offsetX, offsetY)
  return {
    phrase: transformBounds(phrase, originX, originY, scale, offsetX, offsetY),
    scale,
    translateX: offsetX,
    translateY: offsetY,
  }
}

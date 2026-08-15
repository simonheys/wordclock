/** The time fields a highlight expression may reference. */
export const TIME_FIELDS = [
  'day',
  'daystartingmonday',
  'date',
  'month',
  'hour',
  'twentyfourhour',
  'minute',
  'second',
] as const

export type TimeField = (typeof TIME_FIELDS)[number]

export type TimeProps = Record<TimeField, number>

export type WordsGroup =
  | {
      type: 'sequence'
      bind: TimeField
      first: number
      text: string[]
    }
  | {
      type: 'item'
      items: { highlight: string; text?: string }[]
    }
  | {
      type: 'space'
      count: number
    }

export interface WordsJson {
  meta: {
    language: string
    title: string
  }
  groups: WordsGroup[][]
}

export interface Word {
  /** Index into `Definition.words`, and into every parallel buffer. */
  index: number
  text: string
  /** The source highlight expression, kept for debugging. */
  logic: string
  /**
   * Spaces draw nothing, but keep their slot: the rotary layout positions words
   * by their index within a group, so dropping them would close up the rings.
   */
  isSpace: boolean
  groupIndex: number
  indexInGroup: number
  evaluate: (time: TimeProps) => boolean
  /** Advance width at the reference size. Populated by `measure`. */
  width: number
}

export interface WordGroup {
  index: number
  words: Word[]
}

export type Direction = 'ltr' | 'rtl'

/** How often a word file needs re-evaluating, derived from its expressions. */
export type Granularity = 'second' | 'minute'

export interface Definition {
  meta: WordsJson['meta']
  groups: WordGroup[]
  words: Word[]
  fields: Set<TimeField>
  direction: Direction
  granularity: Granularity
  /** Metrics, all at `referenceSize`. Populated by `measure`. */
  referenceSize: number
  spaceWidth: number
  ascent: number
  descent: number
  emHeight: number
}

/**
 * Where a word sits, in device-independent pixels.
 *
 * `x, y` is the rotation pivot: the middle of the word's leading edge,
 * vertically centred on the glyph body rather than sitting on the baseline.
 * Anchoring at the baseline instead makes words swing around their bottom
 * corner during a transition. `pivot: 'centre'` moves it to the middle of the
 * run; settled layouts are identical either way, only the tween path differs.
 */
export interface Coordinate {
  x: number
  y: number
  /** Advance width, scaled. */
  w: number
  /** Em height, scaled. */
  h: number
  /** Rotation in radians, clockwise (canvas convention). */
  r: number
  visible: boolean
}

export type Pivot = 'leading' | 'centre'

/** RGBA, each component 0..1. */
export type Rgba = readonly [number, number, number, number]

export interface Palette {
  foreground: Rgba
  highlight: Rgba
  background: Rgba
}

import type { ColourState } from './colour'
import { colourStyle, isFront } from './colour'
import type { FontSpec } from './measure'
import { fontString } from './measure'
import type { Coordinate, Definition, Pivot } from './types'

export interface DrawOptions {
  font: FontSpec
  padding?: number
  /** Must match the pivot the layout was produced with. */
  pivot?: Pivot
  /**
   * Draw highlighted words last so the dense unhighlighted rings never occlude
   * them. Words still mid-fade count as front too, otherwise one would drop
   * behind the instant it stops being highlighted, part-way through its tween.
   */
  highlightInFront?: boolean
}

const order: number[] = []

/**
 * Words are drawn one `fillText` per word, which is what preserves shaping:
 * kerning, ligatures and complex-script forms are resolved per call, so a word
 * must never be split across calls.
 */
export function draw(
  context: CanvasRenderingContext2D,
  definition: Definition,
  coordinates: readonly Coordinate[],
  colours: ColourState,
  options: DrawOptions,
): void {
  const { font, padding = 0, highlightInFront = true, pivot = 'leading' } = options
  const rtl = definition.direction === 'rtl'
  const centrePivot = pivot === 'centre'

  context.font = fontString(font, definition.referenceSize)
  context.textBaseline = 'alphabetic'
  context.textAlign = rtl ? 'right' : 'left'
  context.fontKerning = 'normal'
  context.direction = definition.direction

  // coordinates are vertically centred on the glyph body; put the baseline back
  // in the word's own local space so rotation pivots mid-height
  const bodyOffset = (definition.ascent - definition.descent) / 2

  order.length = 0
  if (highlightInFront) {
    for (let i = 0; i < coordinates.length; i++) {
      if (!isFront(colours, i)) {
        order.push(i)
      }
    }
    for (let i = 0; i < coordinates.length; i++) {
      if (isFront(colours, i)) {
        order.push(i)
      }
    }
  } else {
    for (let i = 0; i < coordinates.length; i++) {
      order.push(i)
    }
  }

  for (const i of order) {
    const coordinate = coordinates[i]
    const word = definition.words[i]
    if (coordinate === undefined || word === undefined) {
      continue
    }
    if (!coordinate.visible || coordinate.w <= 0) {
      continue
    }

    context.save()
    context.translate(padding + coordinate.x, padding + coordinate.y)
    if (coordinate.r !== 0) {
      context.rotate(coordinate.r)
    }
    // metrics were taken at referenceSize, so scale rather than restating the font
    const scale = coordinate.h / definition.emHeight
    context.scale(scale, scale)
    context.fillStyle = colourStyle(colours, i)
    context.fillText(word.text, centrePivot ? -word.width / 2 : 0, bodyOffset)
    context.restore()
  }
}

/**
 * Sizes the backing store for the display's pixel ratio and returns the CSS
 * size to lay out against. Re-run on resize and whenever the ratio changes.
 */
export function resizeCanvas(
  canvas: HTMLCanvasElement,
  context: CanvasRenderingContext2D,
  devicePixelRatio: number,
): { width: number; height: number } {
  const width = canvas.clientWidth
  const height = canvas.clientHeight
  const ratio = devicePixelRatio > 0 ? devicePixelRatio : 1
  canvas.width = Math.round(width * ratio)
  canvas.height = Math.round(height * ratio)
  context.setTransform(ratio, 0, 0, ratio, 0, 0)
  return { width, height }
}

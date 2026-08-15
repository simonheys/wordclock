import type { Definition } from './types'

/**
 * All word metrics are taken once at this size; every layout is arithmetic on
 * them, scaled at the end. Nothing downstream touches the DOM or a canvas.
 */
export const REFERENCE_SIZE = 100

export interface FontSpec {
  family: string
  weight?: string | number
}

export interface TextMetricsSource {
  measure: (text: string) => { width: number; ascent: number; descent: number }
}

export const fontString = (font: FontSpec, size: number = REFERENCE_SIZE): string =>
  `${font.weight ?? 400} ${size}px ${font.family}`

/**
 * Canvas `measureText` goes through the same platform shaper as DOM text, so
 * kerning, ligatures and complex-script shaping match what the browser would
 * render — provided each word is measured, and later drawn, as a single run.
 *
 * Note the font must already be loaded: `measureText` silently falls back to a
 * substitute otherwise. Await `document.fonts.load(fontString(font))` first.
 */
export const createCanvasMetrics = (
  context: CanvasRenderingContext2D,
  font: FontSpec,
): TextMetricsSource => {
  context.font = fontString(font)
  return {
    measure: (text) => {
      const metrics = context.measureText(text)
      return {
        width: metrics.width,
        ascent: metrics.fontBoundingBoxAscent ?? metrics.actualBoundingBoxAscent,
        descent: metrics.fontBoundingBoxDescent ?? metrics.actualBoundingBoxDescent,
      }
    },
  }
}

/** Populates the definition's metrics in place. Re-run when the font changes. */
export function measure(definition: Definition, metrics: TextMetricsSource): Definition {
  for (const word of definition.words) {
    word.width = word.isSpace ? 0 : metrics.measure(word.text).width
  }

  const em = metrics.measure('M')
  definition.spaceWidth = metrics.measure(' ').width
  definition.referenceSize = REFERENCE_SIZE
  definition.ascent = em.ascent
  definition.descent = em.descent
  definition.emHeight = em.ascent + em.descent
  return definition
}

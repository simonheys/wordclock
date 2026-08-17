import type { Rgba } from '@wordclock/canvas'

const clamp = (value: number) => Math.min(1, Math.max(0, value))

const parseAlpha = (value: string | undefined) => {
  if (value === undefined) {
    return 1
  }
  return clamp(value.endsWith('%') ? Number.parseFloat(value) / 100 : Number.parseFloat(value))
}

const linearToSrgb = (value: number) =>
  value <= 0.0031308 ? value * 12.92 : 1.055 * value ** (1 / 2.4) - 0.055

const parseOklch = (value: string): Rgba | undefined => {
  const match = value.match(/^oklch\((.+)\)$/)
  if (match?.[1] === undefined) {
    return
  }
  const [channelsText, alphaText] = match[1].split('/').map((part) => part.trim())
  const channels = channelsText?.match(/[+-]?(?:\d*\.)?\d+%?/g) ?? []
  if (channels.length < 3) {
    return
  }

  const lightness = channels[0]?.endsWith('%')
    ? Number.parseFloat(channels[0]) / 100
    : Number.parseFloat(channels[0] ?? '0')
  const chroma = Number.parseFloat(channels[1] ?? '0')
  const hue = (Number.parseFloat(channels[2] ?? '0') * Math.PI) / 180
  const a = chroma * Math.cos(hue)
  const b = chroma * Math.sin(hue)
  const l = (lightness + 0.3963377774 * a + 0.2158037573 * b) ** 3
  const m = (lightness - 0.1055613458 * a - 0.0638541728 * b) ** 3
  const s = (lightness - 0.0894841775 * a - 1.291485548 * b) ** 3

  return [
    clamp(linearToSrgb(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s)),
    clamp(linearToSrgb(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s)),
    clamp(linearToSrgb(-0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s)),
    parseAlpha(alphaText),
  ]
}

export const parseCssColour = (value: string, fallback: Rgba): Rgba => {
  const colour = value.trim().toLowerCase()
  if (colour === 'transparent') {
    return [0, 0, 0, 0]
  }

  const oklch = parseOklch(colour)
  if (oklch !== undefined) {
    return oklch
  }

  const hex = colour.match(/^#([\da-f]{3}|[\da-f]{4}|[\da-f]{6}|[\da-f]{8})$/)
  if (hex?.[1] !== undefined) {
    const compact = hex[1].length <= 4
    const channels = compact
      ? [...hex[1]].map((channel) => Number.parseInt(channel + channel, 16))
      : (hex[1].match(/[\da-f]{2}/g) ?? []).map((channel) => Number.parseInt(channel, 16))
    return [
      (channels[0] ?? 0) / 255,
      (channels[1] ?? 0) / 255,
      (channels[2] ?? 0) / 255,
      (channels[3] ?? 255) / 255,
    ]
  }

  const rgb = colour.match(/^rgba?\((.*)\)$/)
  if (rgb?.[1] !== undefined) {
    const [channelsText, alphaText] = rgb[1].split('/').map((part) => part.trim())
    const channels = channelsText?.match(/[+-]?(?:\d*\.)?\d+%?/g) ?? []
    if (channels.length >= 3) {
      const channel = (entry: string | undefined) =>
        clamp(
          entry?.endsWith('%')
            ? Number.parseFloat(entry) / 100
            : Number.parseFloat(entry ?? '0') / 255,
        )
      const commaAlpha = channels.length > 3 ? channels[3] : undefined
      return [
        channel(channels[0]),
        channel(channels[1]),
        channel(channels[2]),
        parseAlpha(alphaText ?? commaAlpha),
      ]
    }
  }

  const colourFunction = colour.match(/^color\((?:display-p3|srgb)\s+(.+)\)$/)
  if (colourFunction?.[1] !== undefined) {
    const [channelsText, alphaText] = colourFunction[1].split('/').map((part) => part.trim())
    const channels = channelsText?.match(/[+-]?(?:\d*\.)?\d+/g) ?? []
    if (channels.length >= 3) {
      return [
        clamp(Number.parseFloat(channels[0] ?? '0')),
        clamp(Number.parseFloat(channels[1] ?? '0')),
        clamp(Number.parseFloat(channels[2] ?? '0')),
        parseAlpha(alphaText),
      ]
    }
  }

  return fallback
}

export type CssColourResolver = (value: string, fallback: Rgba) => Rgba

/**
 * Lets the browser evaluate any CSS colour syntax it supports, including the
 * `lab(...)` values produced by Tailwind's production CSS transform. Reading a
 * single solid pixel is only done during setup or a theme change, never while
 * drawing animation frames.
 */
export const createCssColourResolver = (): CssColourResolver => {
  const canvas = document.createElement('canvas')
  canvas.width = 1
  canvas.height = 1
  const context = canvas.getContext('2d', { willReadFrequently: true })

  if (
    context === null ||
    typeof context.fillRect !== 'function' ||
    typeof context.getImageData !== 'function'
  ) {
    return parseCssColour
  }

  return (value, fallback) => {
    if (typeof CSS !== 'undefined' && !CSS.supports('color', value)) {
      return parseCssColour(value, fallback)
    }
    try {
      context.clearRect(0, 0, 1, 1)
      context.fillStyle = value
      context.fillRect(0, 0, 1, 1)
      const data = context.getImageData(0, 0, 1, 1).data
      return [
        (data[0] ?? 0) / 255,
        (data[1] ?? 0) / 255,
        (data[2] ?? 0) / 255,
        (data[3] ?? 0) / 255,
      ]
    } catch {
      return parseCssColour(value, fallback)
    }
  }
}

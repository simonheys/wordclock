'use client'

import {
  DEFAULT_PALETTE,
  advanceTransition,
  applyRotaryFit,
  cloneCoordinates,
  createCanvasMetrics,
  createColourState,
  createCoordinates,
  createRotaryState,
  createTransition,
  draw,
  findLongestResolvedPhrase,
  fontString,
  getTimeProps,
  layoutLinear,
  layoutRotary,
  measure,
  parseWords,
  refreshRotaryMetrics,
  resizeCanvas,
  resolve,
  resolvePhrase,
  tweenCoordinates,
  updateColours,
  updateRotaryState,
  type Coordinate,
  type Definition,
  type FontSpec,
  type Palette,
  type RotaryFitMode,
  type RotaryState,
  type Transition,
  type TransitionStyle,
  type WordsJson,
} from '@wordclock/canvas'
import { useEffect, useRef } from 'react'

import type { CSSProperties, HTMLAttributes } from 'react'
import { createCssColourResolver, type CssColourResolver } from './cssColour'

export type WordClockLayout = 'linear' | 'rotary'

export interface WordClockProps extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
  words: WordsJson
  layout?: WordClockLayout
  transitionStyle?: TransitionStyle
  fit?: RotaryFitMode
  fitMargin?: number
  translateX?: number
  translateY?: number
  tracking?: number
  leading?: number
  align?: 'left' | 'center' | 'right'
  shortestRotation?: boolean
  highlightInFront?: boolean
  /** Tailwind or other CSS classes used to resolve the normal word colour. */
  foregroundClassName?: string
  /** Tailwind or other CSS classes used to resolve the highlighted word colour. */
  highlightClassName?: string
  /** Optional controlled time, primarily useful for previews and tests. */
  date?: Date
  onPhraseChange?: (phrase: string) => void
}

interface Presentation {
  font: FontSpec
  palette: Palette
}

interface Runtime {
  definition: Definition
  rotaryState: RotaryState
  mask: Uint8Array
  colours: ReturnType<typeof createColourState>
  linear: Coordinate[]
  rotary: Coordinate[]
  displayed: Coordinate[]
  snapshot: Coordinate[]
  transition: Transition | null
  targetLayout: WordClockLayout
  width: number
  height: number
  dpr: number
  lastFrame: number
  lastTimeKey: number
  linearOptionsKey: string
  linearScale: number
  maximumPhraseKey: string
  maximumPhraseWidth: number
  resolvedPhraseWidth: number
  presentation: Presentation
}

type LiveOptions = Required<
  Pick<
    WordClockProps,
    | 'layout'
    | 'transitionStyle'
    | 'fit'
    | 'fitMargin'
    | 'translateX'
    | 'translateY'
    | 'tracking'
    | 'leading'
    | 'align'
    | 'shortestRotation'
    | 'highlightInFront'
  >
> & {
  date: Date | undefined
  onPhraseChange: ((phrase: string) => void) | undefined
}

const ROOT_STYLE: CSSProperties = {
  height: '100%',
  overflow: 'hidden',
  position: 'relative',
  width: '100%',
}

const CANVAS_STYLE: CSSProperties = {
  display: 'block',
  height: '100%',
  inset: 0,
  position: 'absolute',
  width: '100%',
}

const PROBE_STYLE: CSSProperties = {
  height: 0,
  overflow: 'hidden',
  pointerEvents: 'none',
  position: 'absolute',
  visibility: 'hidden',
  width: 0,
}

const ACCESSIBLE_STYLE: CSSProperties = {
  clip: 'rect(0 0 0 0)',
  clipPath: 'inset(50%)',
  height: 1,
  overflow: 'hidden',
  position: 'absolute',
  whiteSpace: 'nowrap',
  width: 1,
}

const copyCoordinates = (from: readonly Coordinate[], to: Coordinate[]) => {
  for (let i = 0; i < from.length; i++) {
    const source = from[i]
    const target = to[i]
    if (source === undefined || target === undefined) {
      continue
    }
    target.x = source.x
    target.y = source.y
    target.w = source.w
    target.h = source.h
    target.r = source.r
    target.visible = source.visible
  }
}

const timeKey = (definition: Definition, date: Date) => {
  const divisor = definition.granularity === 'second' ? 1000 : 60_000
  return Math.floor(date.getTime() / divisor)
}

const dayKey = (date: Date) => `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`

const sameFont = (a: FontSpec, b: FontSpec) =>
  a.family === b.family && String(a.weight ?? 400) === String(b.weight ?? 400)

const readPresentation = (
  root: HTMLDivElement,
  foregroundProbe: HTMLSpanElement,
  highlightProbe: HTMLSpanElement,
  resolveColour: CssColourResolver,
): Presentation => {
  const rootStyle = getComputedStyle(root)
  const foregroundStyle = getComputedStyle(foregroundProbe)
  const highlightStyle = getComputedStyle(highlightProbe)
  return {
    font: {
      family: rootStyle.fontFamily || 'system-ui, sans-serif',
      weight: rootStyle.fontWeight || 400,
    },
    palette: {
      background: [0, 0, 0, 0],
      foreground: resolveColour(foregroundStyle.color, DEFAULT_PALETTE.foreground),
      highlight: resolveColour(highlightStyle.color, DEFAULT_PALETTE.highlight),
    },
  }
}

const startTransition = (
  runtime: Runtime,
  target: WordClockLayout,
  style: TransitionStyle,
  now: number,
) => {
  copyCoordinates(runtime.displayed, runtime.snapshot)
  runtime.transition = createTransition(runtime.definition, {
    reverse: target === 'linear',
    style,
    now,
  })
  runtime.targetLayout = target
}

const usesMaximumPhrase = (fit: RotaryFitMode) =>
  fit === 'phrase' || fit === 'phrase-wheel-centred' || fit === 'phrase-centred-linear-scale'

export function WordClock({
  words,
  layout = 'linear',
  transitionStyle = 'medium',
  fit = 'none',
  fitMargin = 5,
  translateX = 0,
  translateY = 0,
  tracking = 1,
  leading = 0,
  align = 'left',
  shortestRotation = true,
  highlightInFront = true,
  foregroundClassName,
  highlightClassName,
  date,
  onPhraseChange,
  className,
  style,
  ...rest
}: WordClockProps) {
  const rootRef = useRef<HTMLDivElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const foregroundProbeRef = useRef<HTMLSpanElement>(null)
  const highlightProbeRef = useRef<HTMLSpanElement>(null)
  const phraseRef = useRef<HTMLTimeElement>(null)
  const optionsRef = useRef<LiveOptions>({
    layout,
    transitionStyle,
    fit,
    fitMargin,
    translateX,
    translateY,
    tracking,
    leading,
    align,
    shortestRotation,
    highlightInFront,
    date,
    onPhraseChange,
  })
  optionsRef.current = {
    layout,
    transitionStyle,
    fit,
    fitMargin,
    translateX,
    translateY,
    tracking,
    leading,
    align,
    shortestRotation,
    highlightInFront,
    date,
    onPhraseChange,
  }

  useEffect(() => {
    const root = rootRef.current
    const canvas = canvasRef.current
    const foregroundProbe = foregroundProbeRef.current
    const highlightProbe = highlightProbeRef.current
    if (root === null || canvas === null || foregroundProbe === null || highlightProbe === null) {
      return
    }
    const context = canvas.getContext('2d')
    if (context === null) {
      return
    }
    const resolveColour = createCssColourResolver()

    let animationFrame = 0
    let needsResize = true
    let presentationDirty = false
    let disposed = false
    let resizeObserver: ResizeObserver | undefined
    const markResize = () => {
      needsResize = true
    }
    const markPresentationDirty = () => {
      presentationDirty = true
    }

    if (typeof ResizeObserver !== 'undefined') {
      resizeObserver = new ResizeObserver(markResize)
      resizeObserver.observe(root)
    } else {
      window.addEventListener('resize', markResize)
    }

    const mutationObserver = new MutationObserver(markPresentationDirty)
    mutationObserver.observe(root, { attributeFilter: ['class', 'style'], attributes: true })
    mutationObserver.observe(foregroundProbe, {
      attributeFilter: ['class', 'style'],
      attributes: true,
    })
    mutationObserver.observe(highlightProbe, {
      attributeFilter: ['class', 'style'],
      attributes: true,
    })
    for (let ancestor = root.parentElement; ancestor !== null; ancestor = ancestor.parentElement) {
      mutationObserver.observe(ancestor, {
        attributeFilter: ['class', 'style'],
        attributes: true,
      })
    }

    const colourScheme = window.matchMedia?.('(prefers-color-scheme: dark)')
    colourScheme?.addEventListener('change', markPresentationDirty)
    document.fonts?.addEventListener('loadingdone', markPresentationDirty)

    const initialise = async () => {
      await document.fonts?.ready
      if (disposed) {
        return
      }
      const presentation = readPresentation(root, foregroundProbe, highlightProbe, resolveColour)
      await document.fonts?.load(fontString(presentation.font))
      if (disposed) {
        return
      }

      const definition = measure(parseWords(words), createCanvasMetrics(context, presentation.font))
      root.dataset.wordClockLanguage = definition.meta.language
      root.dataset.wordClockTitle = definition.meta.title
      root.dir = definition.direction
      const count = definition.words.length
      const rotaryState = refreshRotaryMetrics(createRotaryState(definition), definition)
      const linear = createCoordinates(count)
      const rotary = createCoordinates(count)
      const displayed = createCoordinates(count)
      const startedAt = performance.now()
      const runtime: Runtime = {
        definition,
        rotaryState,
        mask: new Uint8Array(count),
        colours: createColourState(count),
        linear,
        rotary,
        displayed,
        snapshot: cloneCoordinates(displayed),
        transition: null,
        targetLayout: optionsRef.current.layout,
        width: 0,
        height: 0,
        dpr: 0,
        lastFrame: startedAt,
        lastTimeKey: Number.NaN,
        linearOptionsKey: '',
        linearScale: 0,
        maximumPhraseKey: '',
        maximumPhraseWidth: 0,
        resolvedPhraseWidth: 0,
        presentation,
      }

      const frame = (now: number) => {
        const options = optionsRef.current
        if (presentationDirty) {
          const nextPresentation = readPresentation(
            root,
            foregroundProbe,
            highlightProbe,
            resolveColour,
          )
          if (!sameFont(runtime.presentation.font, nextPresentation.font)) {
            measure(runtime.definition, createCanvasMetrics(context, nextPresentation.font))
            refreshRotaryMetrics(runtime.rotaryState, runtime.definition)
            needsResize = true
            runtime.linearOptionsKey = ''
          }
          runtime.presentation = nextPresentation
          presentationDirty = false
        }

        const dpr = window.devicePixelRatio || 1
        if (needsResize || dpr !== runtime.dpr) {
          const size = resizeCanvas(canvas, context, dpr)
          runtime.width = size.width
          runtime.height = size.height
          runtime.dpr = dpr
          needsResize = false
        }

        const linearOptionsKey = [
          runtime.width,
          runtime.height,
          options.tracking,
          options.leading,
          options.align,
        ].join(':')
        if (linearOptionsKey !== runtime.linearOptionsKey) {
          const linearResult = layoutLinear(
            runtime.definition,
            {
              width: runtime.width,
              height: runtime.height,
              tracking: options.tracking,
              leading: options.leading,
              align: options.align,
            },
            runtime.linear,
          )
          runtime.linearScale = linearResult.scale
          runtime.linearOptionsKey = linearOptionsKey
        }

        const selectedDate = options.date ?? new Date()
        const selectedTimeKey = timeKey(runtime.definition, selectedDate)
        if (selectedTimeKey !== runtime.lastTimeKey) {
          resolve(runtime.definition, getTimeProps(selectedDate), runtime.mask)
          runtime.lastTimeKey = selectedTimeKey
          const phrase = resolvePhrase(runtime.definition, runtime.mask)
          runtime.resolvedPhraseWidth = phrase.width
          const phraseNode = phraseRef.current
          if (phraseNode !== null) {
            phraseNode.textContent = phrase.phrase
            phraseNode.dateTime = selectedDate.toISOString()
            phraseNode.dir = runtime.definition.direction
          }
          options.onPhraseChange?.(phrase.phrase)
        }

        if (usesMaximumPhrase(options.fit) && options.layout === 'rotary') {
          const maximumKey = dayKey(selectedDate)
          if (maximumKey !== runtime.maximumPhraseKey) {
            runtime.maximumPhraseWidth = findLongestResolvedPhrase(
              runtime.definition,
              selectedDate,
            ).width
            runtime.maximumPhraseKey = maximumKey
          }
        }

        updateColours(runtime.colours, runtime.mask, runtime.presentation.palette, now)
        const deltaMs = Math.min(100, Math.max(0, now - runtime.lastFrame))
        updateRotaryState(runtime.rotaryState, runtime.definition, runtime.mask, now, deltaMs)
        const rotaryResult = layoutRotary(
          runtime.definition,
          runtime.rotaryState,
          { width: runtime.width, height: runtime.height },
          runtime.rotary,
        )
        applyRotaryFit(runtime.rotary, runtime.definition, runtime.rotaryState, {
          width: runtime.width,
          height: runtime.height,
          baseScale: rotaryResult.scale,
          linearScale: runtime.linearScale,
          resolvedPhraseWidth: runtime.resolvedPhraseWidth,
          maximumPhraseWidth: runtime.maximumPhraseWidth,
          mode: options.fit,
          margin: options.fitMargin,
          translateX: options.translateX,
          translateY: options.translateY,
        })

        if (options.layout !== runtime.targetLayout) {
          startTransition(runtime, options.layout, options.transitionStyle, now)
        }
        const target = runtime.targetLayout === 'rotary' ? runtime.rotary : runtime.linear
        if (runtime.transition !== null) {
          const done = advanceTransition(runtime.transition, now)
          tweenCoordinates(runtime.snapshot, target, runtime.transition.values, runtime.displayed, {
            shortestRotation: options.shortestRotation,
          })
          if (done) {
            runtime.transition = null
          }
        } else {
          copyCoordinates(target, runtime.displayed)
        }

        context.clearRect(0, 0, runtime.width, runtime.height)
        draw(context, runtime.definition, runtime.displayed, runtime.colours, {
          font: runtime.presentation.font,
          highlightInFront: options.highlightInFront,
        })
        runtime.lastFrame = now
        animationFrame = requestAnimationFrame(frame)
      }

      animationFrame = requestAnimationFrame(frame)
    }

    void initialise()
    return () => {
      disposed = true
      cancelAnimationFrame(animationFrame)
      resizeObserver?.disconnect()
      if (resizeObserver === undefined) {
        window.removeEventListener('resize', markResize)
      }
      mutationObserver.disconnect()
      colourScheme?.removeEventListener('change', markPresentationDirty)
      document.fonts?.removeEventListener('loadingdone', markPresentationDirty)
    }
  }, [words])

  return (
    <div {...rest} ref={rootRef} className={className} style={{ ...ROOT_STYLE, ...style }}>
      <canvas ref={canvasRef} aria-hidden="true" style={CANVAS_STYLE} />
      <span
        ref={foregroundProbeRef}
        aria-hidden="true"
        className={foregroundClassName}
        style={PROBE_STYLE}
      />
      <span
        ref={highlightProbeRef}
        aria-hidden="true"
        className={highlightClassName}
        style={{ ...PROBE_STYLE, color: highlightClassName ? undefined : '#ff0000' }}
      />
      <time ref={phraseRef} aria-live="polite" role="timer" style={ACCESSIBLE_STYLE} />
    </div>
  )
}

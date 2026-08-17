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
  getTimeProps,
  layoutLinear,
  layoutRotary,
  measure,
  parseWords,
  refreshRotaryMetrics,
  resizeCanvas,
  resolve,
  resolvePhrase,
  rgbaStyle,
  tweenCoordinates,
  updateColours,
  updateRotaryState,
  type Coordinate,
  type Bounds,
  type Definition,
  type FontSpec,
  type RotaryState,
  type RotaryFitMode,
  type Transition,
  type TransitionStyle,
  type WordsJson,
} from '@wordclock/canvas'
import arabicWords from '@wordclock/words/json/Arabic.json'
import englishWords from '@wordclock/words/json/English.json'
import { useEffect, useRef, useState } from 'react'

type ClockLayout = 'linear' | 'rotary'
type FitMode = RotaryFitMode
type Language = 'English' | 'Arabic'
type DprMode = 'device' | '1' | '2'
type ViewportPreset = 'responsive' | 'square' | 'portrait' | 'wide'

interface PlaygroundConfig {
  layout: ClockLayout
  fit: FitMode
  language: Language
  transitionStyle: TransitionStyle
  dpr: DprMode
  viewport: ViewportPreset
  liveTime: boolean
  hour: number
  minute: number
  second: number
  fitMargin: number
  translateX: number
  translateY: number
  shortestRotation: boolean
  highlightInFront: boolean
  showGuides: boolean
  showPhraseBounds: boolean
  replay: number
}

interface Runtime {
  language: Language
  definition: Definition
  rotaryState: RotaryState
  mask: Uint8Array
  colours: ReturnType<typeof createColourState>
  linear: Coordinate[]
  rotary: Coordinate[]
  displayed: Coordinate[]
  snapshot: Coordinate[]
  transition: Transition | null
  targetLayout: ClockLayout
  replay: number
  width: number
  height: number
  dpr: number
  lastFrame: number
  lastTimeKey: number
  resolvedPhraseWidth: number
  dailyMaximumWidth: number
  dailyMaximumKey: string
  frames: number
  statsStartedAt: number
  frameTimes: Float32Array
  frameTimeIndex: number
  frameTimeCount: number
}

const FONT: FontSpec = { family: 'Inter, system-ui, sans-serif', weight: 700 }
const BACKGROUND_STYLE = rgbaStyle(DEFAULT_PALETTE.background)
const WORDS: Record<Language, WordsJson> = {
  English: englishWords as WordsJson,
  Arabic: arabicWords as WordsJson,
}
const VIEWPORTS: Record<ViewportPreset, { width: number; height: number }> = {
  responsive: { width: 960, height: 600 },
  square: { width: 720, height: 720 },
  portrait: { width: 440, height: 720 },
  wide: { width: 1100, height: 520 },
}

const INITIAL_CONFIG: PlaygroundConfig = {
  layout: 'rotary',
  fit: 'none',
  language: 'English',
  transitionStyle: 'medium',
  dpr: 'device',
  viewport: 'responsive',
  liveTime: false,
  hour: 19,
  minute: 11,
  second: 23,
  fitMargin: 5,
  translateX: 0,
  translateY: 0,
  shortestRotation: true,
  highlightInFront: true,
  showGuides: false,
  showPhraseBounds: false,
  replay: 0,
}

const copyCoordinates = (from: readonly Coordinate[], to: Coordinate[]) => {
  const length = from.length
  for (let i = 0; i < length; i++) {
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

const selectedDate = (config: PlaygroundConfig) => {
  if (config.liveTime) {
    return new Date()
  }
  return new Date(2026, 8, 16, config.hour, config.minute, config.second)
}

const dailyMaximumKey = (language: Language, date: Date) =>
  `${language}:${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`

const ensureDailyMaximum = (
  runtime: Runtime,
  config: PlaygroundConfig,
  date: Date = selectedDate(config),
) => {
  const key = dailyMaximumKey(runtime.language, date)
  if (key === runtime.dailyMaximumKey) {
    return findLongestResolvedPhrase(runtime.definition, date)
  }
  const example = findLongestResolvedPhrase(runtime.definition, date)
  runtime.dailyMaximumKey = key
  runtime.dailyMaximumWidth = example.width
  return example
}

const selectedTimeKey = (config: PlaygroundConfig, definition: Definition) => {
  if (!config.liveTime) {
    return config.hour * 3600 + config.minute * 60 + config.second
  }
  const divisor = definition.granularity === 'second' ? 1000 : 60_000
  return Math.floor(Date.now() / divisor)
}

const resolvedDpr = (mode: DprMode) => {
  if (mode === 'device') {
    return window.devicePixelRatio || 1
  }
  return Number(mode)
}

const startTransition = (
  runtime: Runtime,
  target: ClockLayout,
  style: TransitionStyle,
  now: number,
  replay: boolean,
) => {
  if (replay) {
    copyCoordinates(target === 'rotary' ? runtime.linear : runtime.rotary, runtime.snapshot)
  } else {
    copyCoordinates(runtime.displayed, runtime.snapshot)
  }
  runtime.transition = createTransition(runtime.definition, {
    reverse: target === 'linear',
    style,
    now,
  })
  runtime.targetLayout = target
}

const drawGuides = (
  context: CanvasRenderingContext2D,
  coordinates: readonly Coordinate[],
  mask: Uint8Array,
  width: number,
  height: number,
) => {
  context.save()
  context.strokeStyle = 'rgba(56,189,248,0.8)'
  context.fillStyle = 'rgba(56,189,248,0.9)'
  context.lineWidth = 1
  context.setLineDash([5, 5])
  context.beginPath()
  context.moveTo(width / 2, 0)
  context.lineTo(width / 2, height)
  context.moveTo(0, height / 2)
  context.lineTo(width, height / 2)
  context.stroke()
  context.setLineDash([])

  for (let i = 0; i < coordinates.length; i++) {
    if (mask[i] !== 1) {
      continue
    }
    const coordinate = coordinates[i]
    if (coordinate === undefined || !coordinate.visible) {
      continue
    }
    context.beginPath()
    context.arc(coordinate.x, coordinate.y, 3, 0, Math.PI * 2)
    context.fill()
  }
  context.restore()
}

const drawPhraseBounds = (context: CanvasRenderingContext2D, phrase: Bounds) => {
  const phraseWidth = Math.max(0, phrase.right - phrase.left)
  const phraseHeight = Math.max(0, phrase.bottom - phrase.top)
  context.save()
  context.font = '600 12px ui-monospace, SFMono-Regular, Menlo, monospace'
  context.textAlign = 'left'
  context.strokeStyle = 'rgba(56,189,248,1)'
  context.lineWidth = 2
  context.strokeRect(phrase.left, phrase.top, phraseWidth, phraseHeight)
  context.fillStyle = 'rgba(56,189,248,1)'
  context.textBaseline = 'top'
  context.fillText('resolved phrase', Math.max(8, phrase.left), phrase.bottom + 5)
  context.restore()
}

const updateStats = (
  runtime: Runtime,
  node: HTMLDivElement | null,
  now: number,
  drawMs: number,
) => {
  const frameTime = now - runtime.lastFrame
  runtime.frameTimes[runtime.frameTimeIndex] = frameTime
  runtime.frameTimeIndex = (runtime.frameTimeIndex + 1) % runtime.frameTimes.length
  runtime.frameTimeCount = Math.min(runtime.frameTimeCount + 1, runtime.frameTimes.length)
  runtime.frames++

  const elapsed = now - runtime.statsStartedAt
  if (node === null || elapsed < 500) {
    return
  }

  const samples = Array.from(runtime.frameTimes.slice(0, runtime.frameTimeCount)).sort(
    (a, b) => a - b,
  )
  const p95Index = Math.min(samples.length - 1, Math.floor(samples.length * 0.95))
  const p95 = samples[p95Index] ?? 0
  const fps = (runtime.frames * 1000) / elapsed
  node.textContent = `${fps.toFixed(0)} fps (native rAF)  ·  p95 ${p95.toFixed(1)} ms  ·  draw ${drawMs.toFixed(1)} ms  ·  ${runtime.definition.words.length} slots`
  runtime.frames = 0
  runtime.statsStartedAt = now
}

const createRuntime = (
  context: CanvasRenderingContext2D,
  language: Language,
  now: number,
): Runtime => {
  const definition = measure(parseWords(WORDS[language]), createCanvasMetrics(context, FONT))
  const rotaryState = refreshRotaryMetrics(createRotaryState(definition), definition)
  const count = definition.words.length
  const linear = createCoordinates(count)
  const rotary = createCoordinates(count)
  const displayed = createCoordinates(count)
  return {
    language,
    definition,
    rotaryState,
    mask: new Uint8Array(count),
    colours: createColourState(count),
    linear,
    rotary,
    displayed,
    snapshot: cloneCoordinates(displayed),
    transition: null,
    targetLayout: 'linear',
    replay: -1,
    width: 0,
    height: 0,
    dpr: 0,
    lastFrame: now,
    lastTimeKey: -1,
    resolvedPhraseWidth: 0,
    dailyMaximumWidth: 0,
    dailyMaximumKey: '',
    frames: 0,
    statsStartedAt: now,
    frameTimes: new Float32Array(180),
    frameTimeIndex: 0,
    frameTimeCount: 0,
  }
}

export function CanvasPlayground() {
  const [config, setConfig] = useState<PlaygroundConfig>(INITIAL_CONFIG)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const viewportRef = useRef<HTMLDivElement>(null)
  const statsRef = useRef<HTMLDivElement>(null)
  const phraseRef = useRef<HTMLOutputElement>(null)
  const runtimeRef = useRef<Runtime | null>(null)
  const configRef = useRef(config)
  configRef.current = config

  useEffect(() => {
    const canvas = canvasRef.current
    const viewport = viewportRef.current
    if (canvas === null || viewport === null) {
      return
    }
    const context = canvas.getContext('2d', { alpha: false })
    if (context === null) {
      return
    }

    let animationFrame = 0
    let needsResize = true
    let disposed = false
    const resizeObserver = new ResizeObserver(() => {
      needsResize = true
    })
    resizeObserver.observe(viewport)

    const initialise = async () => {
      await document.fonts.ready
      if (disposed) {
        return
      }
      const startedAt = performance.now()
      const runtime = createRuntime(context, configRef.current.language, startedAt)
      runtimeRef.current = runtime
      runtime.targetLayout = configRef.current.layout
      runtime.replay = configRef.current.replay

      const frame = (now: number) => {
        const current = configRef.current
        const wantedDpr = resolvedDpr(current.dpr)
        if (needsResize || wantedDpr !== runtime.dpr) {
          const size = resizeCanvas(canvas, context, wantedDpr)
          runtime.width = size.width
          runtime.height = size.height
          runtime.dpr = wantedDpr
          needsResize = false
          layoutLinear(
            runtime.definition,
            { width: size.width, height: size.height },
            runtime.linear,
          )
        }

        const timeKey = selectedTimeKey(current, runtime.definition)
        if (timeKey !== runtime.lastTimeKey) {
          const date = selectedDate(current)
          resolve(runtime.definition, getTimeProps(date), runtime.mask)
          runtime.lastTimeKey = timeKey
          const phrase = resolvePhrase(runtime.definition, runtime.mask)
          runtime.resolvedPhraseWidth = phrase.width
          if (current.fit !== 'none') {
            ensureDailyMaximum(runtime, current, date)
          }
          const phraseNode = phraseRef.current
          if (phraseNode !== null) {
            phraseNode.textContent = phrase.phrase
            phraseNode.dir = runtime.definition.direction
          }
        }
        updateColours(runtime.colours, runtime.mask, DEFAULT_PALETTE, now)

        const deltaMs = Math.min(100, Math.max(0, now - runtime.lastFrame))
        updateRotaryState(runtime.rotaryState, runtime.definition, runtime.mask, now, deltaMs)
        const rotaryResult = layoutRotary(
          runtime.definition,
          runtime.rotaryState,
          {
            width: runtime.width,
            height: runtime.height,
          },
          runtime.rotary,
        )
        const rotaryFit = applyRotaryFit(runtime.rotary, runtime.definition, runtime.rotaryState, {
          resolvedPhraseWidth: runtime.resolvedPhraseWidth,
          maximumPhraseWidth: runtime.dailyMaximumWidth,
          baseScale: rotaryResult.scale,
          width: runtime.width,
          height: runtime.height,
          mode: current.fit,
          margin: current.fitMargin,
          translateX: current.translateX,
          translateY: current.translateY,
        })

        if (current.layout !== runtime.targetLayout) {
          startTransition(runtime, current.layout, current.transitionStyle, now, false)
        } else if (current.replay !== runtime.replay) {
          runtime.replay = current.replay
          startTransition(runtime, current.layout, current.transitionStyle, now, true)
        }

        const target = runtime.targetLayout === 'rotary' ? runtime.rotary : runtime.linear
        if (runtime.transition !== null) {
          const done = advanceTransition(runtime.transition, now)
          tweenCoordinates(runtime.snapshot, target, runtime.transition.values, runtime.displayed, {
            shortestRotation: current.shortestRotation,
          })
          if (done) {
            runtime.transition = null
          }
        } else {
          copyCoordinates(target, runtime.displayed)
        }

        context.fillStyle = BACKGROUND_STYLE
        context.fillRect(0, 0, runtime.width, runtime.height)
        const beforeDraw = performance.now()
        draw(context, runtime.definition, runtime.displayed, runtime.colours, {
          font: FONT,
          highlightInFront: current.highlightInFront,
        })
        const drawMs = performance.now() - beforeDraw
        if (current.showGuides) {
          drawGuides(context, runtime.displayed, runtime.mask, runtime.width, runtime.height)
        }
        if (current.showPhraseBounds && current.layout === 'rotary') {
          drawPhraseBounds(context, rotaryFit.phrase)
        }

        updateStats(runtime, statsRef.current, now, drawMs)
        runtime.lastFrame = now
        animationFrame = requestAnimationFrame(frame)
      }

      animationFrame = requestAnimationFrame(frame)
    }

    void initialise()
    return () => {
      disposed = true
      cancelAnimationFrame(animationFrame)
      resizeObserver.disconnect()
      runtimeRef.current = null
    }
  }, [config.language])

  const viewport = VIEWPORTS[config.viewport]
  const update = <Key extends keyof PlaygroundConfig>(key: Key, value: PlaygroundConfig[Key]) => {
    setConfig((current) => ({ ...current, [key]: value }))
  }

  const updateFit = (fit: FitMode) => {
    const runtime = runtimeRef.current
    if (fit !== 'none' && runtime !== null && runtime.language === config.language) {
      ensureDailyMaximum(runtime, config)
    }
    update('fit', fit)
  }

  const showLongestExample = () => {
    const runtime = runtimeRef.current
    if (runtime === null || runtime.language !== config.language) {
      return
    }
    const fixedConfig = { ...config, liveTime: false }
    const example = ensureDailyMaximum(runtime, fixedConfig)
    if (example === undefined) {
      return
    }
    setConfig((current) => ({
      ...current,
      liveTime: false,
      hour: example.hour,
      minute: example.minute,
      second: example.second,
      layout: 'rotary',
      fit: 'phrase',
      showPhraseBounds: true,
    }))
  }

  return (
    <div className="grid items-start gap-6 xl:grid-cols-[minmax(0,1fr)_20rem]">
      <section className="min-w-0 rounded-2xl border border-slate-200 bg-background p-3 shadow-sm dark:border-slate-700">
        <div
          ref={viewportRef}
          className="relative mx-auto overflow-hidden rounded-xl bg-black"
          style={{
            width: `min(100%, ${viewport.width}px)`,
            aspectRatio: `${viewport.width} / ${viewport.height}`,
          }}
        >
          <canvas
            ref={canvasRef}
            className="absolute inset-0 h-full w-full"
            data-testid="canvas-clock"
          />
          <div
            ref={statsRef}
            className="pointer-events-none absolute right-3 bottom-3 rounded-md bg-black/65 px-2 py-1 font-mono text-[11px] text-white/80 backdrop-blur-sm"
            data-testid="canvas-stats"
          >
            Measuring…
          </div>
        </div>
        <div className="mt-3 grid gap-1 rounded-lg border border-slate-200 px-3 py-2 dark:border-slate-700">
          <span className="text-[10px] font-semibold tracking-[0.14em] text-slate-500 uppercase dark:text-slate-400">
            Resolved phrase
          </span>
          <output
            ref={phraseRef}
            className="min-h-5 text-sm text-foreground"
            data-testid="resolved-phrase"
            dir="auto"
          >
            Resolving…
          </output>
        </div>
      </section>

      <aside className="grid gap-5 rounded-2xl border border-slate-200 bg-background p-5 shadow-sm dark:border-slate-700">
        <fieldset className="grid gap-3">
          <legend className="mb-1 text-xs font-semibold tracking-[0.16em] text-slate-500 uppercase dark:text-slate-400">
            Content
          </legend>
          <Control label="Language">
            <select
              className="control"
              value={config.language}
              onChange={(event) => update('language', event.target.value as Language)}
            >
              <option>English</option>
              <option>Arabic</option>
            </select>
          </Control>
          <Control label="Time source">
            <select
              className="control"
              value={config.liveTime ? 'live' : 'fixed'}
              onChange={(event) => update('liveTime', event.target.value === 'live')}
            >
              <option value="fixed">Fixed</option>
              <option value="live">Live</option>
            </select>
          </Control>
          {config.liveTime ? null : (
            <div className="grid grid-cols-3 gap-2">
              <NumberControl
                label="Hour"
                max={23}
                value={config.hour}
                onChange={(value) => update('hour', value)}
              />
              <NumberControl
                label="Minute"
                max={59}
                value={config.minute}
                onChange={(value) => update('minute', value)}
              />
              <NumberControl
                label="Second"
                max={59}
                value={config.second}
                onChange={(value) => update('second', value)}
              />
            </div>
          )}
          <button
            className="rounded-lg border border-sky-300 bg-sky-50 px-3 py-2 text-sm font-medium text-sky-800 hover:bg-sky-100 dark:border-sky-800 dark:bg-sky-950/40 dark:text-sky-200 dark:hover:bg-sky-950/70"
            type="button"
            onClick={showLongestExample}
          >
            Show longest real phrase
          </button>
          <p className="text-[11px] leading-4 text-slate-500 dark:text-slate-400">
            Measures every valid time on 16 Sep 2026, then fits that longest phrase with a stable
            scale and position. Blue shows the current resolved phrase.
          </p>
        </fieldset>

        <fieldset className="grid gap-3 border-t border-slate-200 pt-5 dark:border-slate-700">
          <legend className="mb-1 text-xs font-semibold tracking-[0.16em] text-slate-500 uppercase dark:text-slate-400">
            Layout
          </legend>
          <div className="grid grid-cols-2 gap-2">
            {(['linear', 'rotary'] as const).map((layout) => (
              <button
                key={layout}
                className={`rounded-lg px-3 py-2 text-sm font-medium capitalize transition ${
                  config.layout === layout
                    ? 'bg-sky-500 text-white'
                    : 'border border-slate-300 bg-background text-foreground hover:bg-slate-100 dark:border-slate-600 dark:hover:bg-slate-800'
                }`}
                aria-pressed={config.layout === layout}
                type="button"
                onClick={() => update('layout', layout)}
              >
                {layout}
              </button>
            ))}
          </div>
          <Control label="Transition">
            <select
              className="control"
              value={config.transitionStyle}
              onChange={(event) => update('transitionStyle', event.target.value as TransitionStyle)}
            >
              <option value="slow">Slow</option>
              <option value="medium">Medium</option>
              <option value="fast">Fast</option>
            </select>
          </Control>
          <button
            className="rounded-lg border border-slate-300 px-3 py-2 text-sm font-medium text-foreground hover:bg-slate-50 dark:border-slate-600 dark:hover:bg-slate-800"
            type="button"
            onClick={() => update('replay', config.replay + 1)}
          >
            Replay transition
          </button>
          <Control label="Rotary fit">
            <select
              className="control"
              value={config.fit}
              onChange={(event) => updateFit(event.target.value as FitMode)}
            >
              <option value="none">Current heuristic</option>
              <option value="phrase">Fit phrase</option>
              <option value="phrase-wheel-centred">Fit phrase, wheel centred</option>
            </select>
          </Control>
          {config.fit === 'none' ? null : (
            <RangeControl
              label="Fit margin"
              max={20}
              min={0}
              step={0.5}
              suffix="%"
              value={config.fitMargin}
              onChange={(value) => update('fitMargin', value)}
            />
          )}
          <RangeControl
            label="Translate X"
            max={400}
            min={-400}
            step={1}
            suffix="px"
            value={config.translateX}
            onChange={(value) => update('translateX', value)}
          />
          <RangeControl
            label="Translate Y"
            max={300}
            min={-300}
            step={1}
            suffix="px"
            value={config.translateY}
            onChange={(value) => update('translateY', value)}
          />
        </fieldset>

        <fieldset className="grid gap-3 border-t border-slate-200 pt-5 dark:border-slate-700">
          <legend className="mb-1 text-xs font-semibold tracking-[0.16em] text-slate-500 uppercase dark:text-slate-400">
            Viewport & debug
          </legend>
          <Control label="Viewport">
            <select
              className="control"
              value={config.viewport}
              onChange={(event) => update('viewport', event.target.value as ViewportPreset)}
            >
              <option value="responsive">Responsive 16:10</option>
              <option value="square">Square</option>
              <option value="portrait">Portrait</option>
              <option value="wide">Wide</option>
            </select>
          </Control>
          <Control label="Pixel ratio">
            <select
              className="control"
              value={config.dpr}
              onChange={(event) => update('dpr', event.target.value as DprMode)}
            >
              <option value="device">Device</option>
              <option value="1">1×</option>
              <option value="2">2×</option>
            </select>
          </Control>
          <CheckControl
            checked={config.shortestRotation}
            label="Shortest rotation"
            onChange={(value) => update('shortestRotation', value)}
          />
          <CheckControl
            checked={config.highlightInFront}
            label="Highlights in front"
            onChange={(value) => update('highlightInFront', value)}
          />
          <CheckControl
            checked={config.showGuides}
            label="Show reading guides"
            onChange={(value) => update('showGuides', value)}
          />
          <CheckControl
            checked={config.showPhraseBounds}
            label="Show phrase bounds"
            onChange={(value) => update('showPhraseBounds', value)}
          />
          <button
            className="mt-1 rounded-lg border border-slate-300 px-3 py-2 text-sm font-medium text-foreground hover:bg-slate-50 dark:border-slate-600 dark:hover:bg-slate-800"
            type="button"
            onClick={() => setConfig({ ...INITIAL_CONFIG, replay: config.replay + 1 })}
          >
            Reset controls
          </button>
        </fieldset>
      </aside>
    </div>
  )
}

function Control({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label className="grid gap-1 text-sm">
      <span className="text-xs font-medium text-slate-600 dark:text-slate-300">{label}</span>
      {children}
    </label>
  )
}

function NumberControl({
  label,
  max,
  value,
  onChange,
}: {
  label: string
  max: number
  value: number
  onChange: (value: number) => void
}) {
  return (
    <Control label={label}>
      <input
        className="control"
        max={max}
        min={0}
        type="number"
        value={value}
        onChange={(event) => onChange(Number(event.target.value))}
      />
    </Control>
  )
}

function RangeControl({
  label,
  min,
  max,
  step,
  suffix = '',
  value,
  onChange,
}: {
  label: string
  min: number
  max: number
  step: number
  suffix?: string
  value: number
  onChange: (value: number) => void
}) {
  return (
    <label className="grid gap-1 text-sm">
      <span className="flex items-center justify-between text-xs font-medium text-slate-600 dark:text-slate-300">
        <span>{label}</span>
        <output className="font-mono text-[11px]">
          {value}
          {suffix}
        </output>
      </span>
      <input
        aria-label={label}
        className="accent-sky-500"
        max={max}
        min={min}
        step={step}
        type="range"
        value={value}
        onChange={(event) => onChange(Number(event.target.value))}
      />
    </label>
  )
}

function CheckControl({
  checked,
  label,
  onChange,
}: {
  checked: boolean
  label: string
  onChange: (value: boolean) => void
}) {
  return (
    <label className="flex items-center gap-2 text-sm">
      <input
        checked={checked}
        className="size-4 accent-sky-500"
        type="checkbox"
        onChange={(event) => onChange(event.target.checked)}
      />
      <span>{label}</span>
    </label>
  )
}

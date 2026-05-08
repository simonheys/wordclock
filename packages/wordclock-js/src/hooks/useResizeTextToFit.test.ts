import { act, renderHook } from '@testing-library/react'
import { afterEach, beforeEach, expect, vi } from 'vitest'

const useSizeMock = vi.hoisted(() => ({
  containerRef: vi.fn(),
  size: {
    height: 100,
    width: 100,
  },
}))

vi.mock('./useSize', () => ({
  default: () => ({
    ref: useSizeMock.containerRef,
    size: useSizeMock.size,
  }),
}))

import {
  fitTextToHeight,
  getFontSizeAdjustmentThreshold,
  useResizeTextToFit,
} from './useResizeTextToFit'

const parseFontSize = (element: HTMLElement) => Number.parseFloat(element.style.fontSize)

const createMeasuredElement = () => {
  const element = document.createElement('div')

  Object.defineProperty(element, 'scrollHeight', {
    configurable: true,
    get() {
      return parseFontSize(element) * 2
    },
  })

  return element
}

describe('getFontSizeAdjustmentThreshold', () => {
  it('uses rendered pixel precision based on device pixel ratio', () => {
    expect(getFontSizeAdjustmentThreshold(1)).toEqual(1)
    expect(getFontSizeAdjustmentThreshold(2)).toEqual(0.5)
  })

  it('falls back to one CSS pixel for invalid device pixel ratios', () => {
    expect(getFontSizeAdjustmentThreshold(0)).toEqual(1)
  })
})

describe('fitTextToHeight', () => {
  it('sets the largest fitting font size within the supplied precision', () => {
    const element = createMeasuredElement()

    fitTextToHeight(element, 100, 1)

    expect(parseFontSize(element)).toBeGreaterThan(49)
    expect(parseFontSize(element)).toBeLessThanOrEqual(50)
  })

  it('restores an existing inline height after measurement', () => {
    const element = createMeasuredElement()
    element.style.height = '25px'

    fitTextToHeight(element, 100, 1)

    expect(element.style.height).toEqual('25px')
  })

  it('removes the temporary inline height when no height was set', () => {
    const element = createMeasuredElement()

    fitTextToHeight(element, 100, 1)

    expect(element.style.height).toEqual('')
  })

  it('does not mutate font size without a target height', () => {
    const element = createMeasuredElement()

    fitTextToHeight(element, 0, 1)

    expect(element.style.fontSize).toEqual('')
  })
})

describe('useResizeTextToFit', () => {
  let animationFrameCallbacks: FrameRequestCallback[]
  let originalFonts: FontFaceSet | undefined

  beforeEach(() => {
    animationFrameCallbacks = []
    useSizeMock.size = {
      height: 100,
      width: 100,
    }
    originalFonts = document.fonts
    Object.defineProperty(document, 'fonts', {
      configurable: true,
      value: undefined,
    })
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => {
      animationFrameCallbacks.push(callback)
      return animationFrameCallbacks.length
    })
    vi.spyOn(window, 'cancelAnimationFrame').mockImplementation((frameId) => {
      animationFrameCallbacks[frameId - 1] = () => undefined
    })
  })

  afterEach(() => {
    Object.defineProperty(document, 'fonts', {
      configurable: true,
      value: originalFonts,
    })
    vi.restoreAllMocks()
  })

  it('coalesces resize requests into a single animation frame', () => {
    const { result } = renderHook(() => useResizeTextToFit())
    const initialFrame = animationFrameCallbacks.shift()
    act(() => {
      initialFrame?.(0)
    })

    const requestedFramesBeforeResize = vi.mocked(window.requestAnimationFrame).mock.calls.length
    const element = createMeasuredElement()
    result.current.resizeRef.current = element

    act(() => {
      result.current.resize()
      result.current.resize()
    })

    expect(window.requestAnimationFrame).toHaveBeenCalledTimes(requestedFramesBeforeResize + 1)
    expect(element.style.fontSize).toEqual('')

    const resizeFrame = animationFrameCallbacks.shift()
    act(() => {
      resizeFrame?.(0)
    })

    expect(parseFontSize(element)).toBeGreaterThan(49)
    expect(parseFontSize(element)).toBeLessThanOrEqual(50)
  })

  it('schedules a refit when only the measured width changes', () => {
    const { rerender } = renderHook(() => useResizeTextToFit())
    const initialFrame = animationFrameCallbacks.shift()
    act(() => {
      initialFrame?.(0)
    })

    const requestedFramesBeforeResize = vi.mocked(window.requestAnimationFrame).mock.calls.length

    useSizeMock.size = {
      ...useSizeMock.size,
      width: 200,
    }

    rerender()

    expect(window.requestAnimationFrame).toHaveBeenCalledTimes(requestedFramesBeforeResize + 1)
  })
})

import { act, renderHook } from '@testing-library/react'
import { afterEach, expect, test, vi } from 'vitest'

const resizeObserverMock = vi.hoisted(() => ({
  callback: undefined as ResizeObserverCallback | undefined,
  disconnect: vi.fn(),
  observe: vi.fn(),
  unobserve: vi.fn(),
}))

vi.mock('resize-observer-polyfill', () => ({
  default: vi.fn(function ResizeObserver(callback: ResizeObserverCallback) {
    resizeObserverMock.callback = callback

    return {
      disconnect: resizeObserverMock.disconnect,
      observe: resizeObserverMock.observe,
      unobserve: resizeObserverMock.unobserve,
    }
  }),
}))

import useSize from './useSize'

const createResizeObserverEntry = (
  target: Element,
  contentRect: Pick<DOMRectReadOnly, 'height' | 'width'>,
) =>
  ({
    contentRect,
    target,
  }) as ResizeObserverEntry

afterEach(() => {
  resizeObserverMock.callback = undefined
  vi.clearAllMocks()
  vi.unstubAllGlobals()
})

test('uses the polyfill when native ResizeObserver is unavailable', () => {
  vi.stubGlobal('ResizeObserver', undefined)

  const { result } = renderHook(() => useSize())
  const element = document.createElement('div')
  const entry = createResizeObserverEntry(element, {
    height: 50,
    width: 100,
  })

  act(() => {
    result.current.ref(element)
  })

  act(() => {
    resizeObserverMock.callback?.([entry], {} as ResizeObserver)
  })

  expect(result.current.size).toEqual({
    height: 50,
    width: 100,
  })

  const sizeAfterFirstResize = result.current.size

  act(() => {
    resizeObserverMock.callback?.([entry], {} as ResizeObserver)
  })

  expect(result.current.size).toBe(sizeAfterFirstResize)
})

test('uses native ResizeObserver when available', () => {
  const nativeResizeObserverMock = {
    callback: undefined as ResizeObserverCallback | undefined,
    disconnect: vi.fn(),
    observe: vi.fn(),
    unobserve: vi.fn(),
  }
  const NativeResizeObserver = vi.fn(function ResizeObserver(callback: ResizeObserverCallback) {
    nativeResizeObserverMock.callback = callback

    return {
      disconnect: nativeResizeObserverMock.disconnect,
      observe: nativeResizeObserverMock.observe,
      unobserve: nativeResizeObserverMock.unobserve,
    }
  })
  vi.stubGlobal('ResizeObserver', NativeResizeObserver)

  const { result } = renderHook(() => useSize())
  const element = document.createElement('div')
  const entry = createResizeObserverEntry(element, {
    height: 75,
    width: 125,
  })

  act(() => {
    result.current.ref(element)
  })

  expect(NativeResizeObserver).toHaveBeenCalledTimes(1)
  expect(resizeObserverMock.observe).not.toHaveBeenCalled()

  act(() => {
    nativeResizeObserverMock.callback?.([entry], {} as ResizeObserver)
  })

  expect(result.current.size).toEqual({
    height: 75,
    width: 125,
  })
})

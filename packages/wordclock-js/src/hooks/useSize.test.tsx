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
})

test('preserves the size object when the observed dimensions are unchanged', () => {
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

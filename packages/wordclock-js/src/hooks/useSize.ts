import * as React from 'react'
import ResizeObserverPolyfill from 'resize-observer-polyfill'

const createResizeObserver = (callback: ResizeObserverCallback) => {
  const ResizeObserverImplementation = globalThis.ResizeObserver ?? ResizeObserverPolyfill
  return new ResizeObserverImplementation(callback)
}

const useSize = () => {
  const ref = React.useRef<HTMLDivElement | null>(null)
  const resizeObserverRef = React.useRef<ResizeObserver | null>(null)
  const [size, setSize] = React.useState({
    width: 0,
    height: 0,
  })

  const teardownResizeObserver = React.useCallback(() => {
    if (resizeObserverRef.current) {
      if (ref.current) {
        resizeObserverRef.current.unobserve(ref.current)
      }
      resizeObserverRef.current.disconnect()
      resizeObserverRef.current = null
    }
  }, [])

  const setupResizeObserver = React.useCallback(() => {
    if (resizeObserverRef.current) {
      teardownResizeObserver()
    }
    if (!ref.current) {
      return
    }
    resizeObserverRef.current = createResizeObserver((entries) => {
      const currentRefEntry = entries.find(({ target }) => target === ref.current)
      if (currentRefEntry) {
        const { width, height } = currentRefEntry.contentRect
        setSize((currentSize) => {
          if (currentSize.width === width && currentSize.height === height) {
            return currentSize
          }
          return { width, height }
        })
      }
    })
    resizeObserverRef.current.observe(ref.current)
  }, [teardownResizeObserver])

  const setRef = React.useCallback(
    (nextRef: HTMLDivElement | null) => {
      teardownResizeObserver()
      ref.current = nextRef
      setupResizeObserver()
    },
    [setupResizeObserver, teardownResizeObserver],
  )
  return { ref: setRef, useRef: ref, size }
}

export default useSize

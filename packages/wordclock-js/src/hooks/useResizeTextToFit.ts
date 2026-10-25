import { useCallback, useEffect, useRef } from 'react'

import useSize from './useSize'

const minimumFontSize = 1
const maximumFontSize = 256
const defaultDevicePixelRatio = 1

export const getFontSizeAdjustmentThreshold = (
  devicePixelRatio = globalThis.window?.devicePixelRatio ?? defaultDevicePixelRatio,
) => 1 / Math.max(devicePixelRatio || defaultDevicePixelRatio, defaultDevicePixelRatio)

const requestResizeFrame = (callback: FrameRequestCallback) => {
  if (!globalThis.window?.requestAnimationFrame) {
    callback(0)
    return null
  }
  return window.requestAnimationFrame(callback)
}

const cancelResizeFrame = (frameId: number | null) => {
  if (frameId !== null && globalThis.window) {
    window.cancelAnimationFrame(frameId)
  }
}

export const fitTextToHeight = (
  element: HTMLDivElement,
  targetHeight: number,
  minimumFontSizeAdjustment = getFontSizeAdjustmentThreshold(),
) => {
  if (!targetHeight) {
    return
  }

  const originalHeight = element.style.height || null
  element.style.height = 'auto'

  let fontSizeLow = minimumFontSize
  let fontSizeHigh = maximumFontSize
  let done = false
  let oldLow = -1
  let oldHigh = -1
  let lowFits = false,
    highFits = false
  let fontSizeMid

  while (!done && Math.abs(fontSizeLow - fontSizeHigh) > minimumFontSizeAdjustment) {
    if (fontSizeLow !== oldLow) {
      element.style.fontSize = `${fontSizeLow}px`
      lowFits = element.scrollHeight < targetHeight
      oldLow = fontSizeLow
    }
    if (fontSizeHigh !== oldHigh) {
      element.style.fontSize = `${fontSizeHigh}px`
      highFits = element.scrollHeight < targetHeight
      oldHigh = fontSizeHigh
    }
    if (lowFits && !highFits) {
      fontSizeMid = (fontSizeLow + fontSizeHigh) * 0.5
      element.style.fontSize = `${fontSizeMid}px`
      const midFits = element.scrollHeight < targetHeight
      if (midFits) {
        fontSizeLow = fontSizeMid
      } else {
        fontSizeHigh = fontSizeMid
      }
    } else {
      done = true
    }
  }

  element.style.fontSize = `${fontSizeLow}px`

  if (originalHeight) {
    element.style.height = originalHeight
  } else {
    element.style.removeProperty('height')
  }
}

export const useResizeTextToFit = () => {
  const { ref: containerRef, size: targetSize } = useSize()
  const resizeRef = useRef<HTMLDivElement>(null)
  const resizeFrameRef = useRef<number | null>(null)

  const runResize = useCallback(() => {
    resizeFrameRef.current = null
    if (resizeRef.current && targetSize.width) {
      fitTextToHeight(resizeRef.current, targetSize.height)
    }
  }, [targetSize.height, targetSize.width])

  const resize = useCallback(() => {
    if (resizeFrameRef.current !== null) {
      return
    }
    resizeFrameRef.current = requestResizeFrame(runResize)
  }, [runResize])

  useEffect(() => {
    resize()
    return () => {
      cancelResizeFrame(resizeFrameRef.current)
      resizeFrameRef.current = null
    }
  }, [resize])

  useEffect(() => {
    const fonts = globalThis.document?.fonts
    if (!fonts) {
      return
    }

    let cancelled = false
    const resizeAfterFontsLoad = () => {
      if (!cancelled) {
        resize()
      }
    }

    void fonts.ready.then(resizeAfterFontsLoad)
    fonts.addEventListener('loadingdone', resizeAfterFontsLoad)
    return () => {
      cancelled = true
      fonts.removeEventListener('loadingdone', resizeAfterFontsLoad)
    }
  }, [resize])

  return {
    resizeRef,
    containerRef,
    resize,
  }
}

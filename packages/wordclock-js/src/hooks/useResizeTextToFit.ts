import { useCallback, useEffect, useRef } from "react";

import useSize from "./useSize";

const minimumFontSizeAdjustment = 0.0001;

export const useResizeTextToFit = () => {
  const { ref: containerRef, size: targetSize } = useSize();
  const resizeRef = useRef<HTMLDivElement>(null);
  const originalHeightRef = useRef<string | null>(null);

  const resize = useCallback(() => {
    if (!resizeRef.current || !targetSize.height) {
      return;
    }

    // Store original height before modifying
    originalHeightRef.current = resizeRef.current.style.height || null;
    resizeRef.current.style.height = "auto";

    let fontSizeLow = 1;
    let fontSizeHigh = 256;
    let done = false;
    let oldLow = -1;
    let oldHigh = -1;
    let lowFits = false,
      highFits = false,
      midFits = false;
    let fontSizeMid;

    while (
      !done &&
      Math.abs(fontSizeLow - fontSizeHigh) > minimumFontSizeAdjustment
    ) {
      if (fontSizeLow !== oldLow) {
        resizeRef.current.style.fontSize = `${fontSizeLow}px`;
        lowFits = resizeRef.current.scrollHeight < targetSize.height;
        oldLow = fontSizeLow;
      }
      if (fontSizeHigh !== oldHigh) {
        resizeRef.current.style.fontSize = `${fontSizeHigh}px`;
        highFits = resizeRef.current.scrollHeight < targetSize.height;
        oldHigh = fontSizeHigh;
      }
      if (lowFits && !highFits) {
        fontSizeMid = (fontSizeLow + fontSizeHigh) * 0.5;
        resizeRef.current.style.fontSize = `${fontSizeMid}px`;
        midFits = resizeRef.current.scrollHeight < targetSize.height;
        if (midFits) {
          fontSizeLow = fontSizeMid;
        } else {
          fontSizeHigh = fontSizeMid;
        }
      } else {
        done = true;
      }
    }

    resizeRef.current.style.fontSize = `${fontSizeLow}px`;

    // Restore original height or remove the property
    if (originalHeightRef.current) {
      resizeRef.current.style.height = originalHeightRef.current;
    } else {
      resizeRef.current.style.removeProperty("height");
    }
  }, [targetSize]);

  useEffect(() => {
    resize();
  }, [resize, targetSize]);

  return {
    resizeRef,
    containerRef,
    resize,
  };
};

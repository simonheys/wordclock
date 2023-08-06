import { useCallback, useEffect, useRef } from "react";

import useSize from "./useSize";

const minimumFontSizeAdjustment = 0.0001;

export const useResizeTextToFit = () => {
  const { ref: containerRef, size: targetSize } = useSize();
  const resizeRef = useRef<HTMLDivElement>(null);
  const resize = useCallback(() => {
    if (!resizeRef.current || !targetSize.height) {
      return;
    }
    let fontSizeLow = 1;
    let fontSizeHigh = 256;
    let done = false;
    let oldLow = -1;
    let oldHigh = -1;
    let lowFits = false,
      highFits = false,
      midFits = false;
    let fontSizeMid;

    resizeRef.current.style.height = "auto";

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
    resizeRef.current.style.removeProperty("height");
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

import * as React from "react";
import ResizeObserver from "resize-observer-polyfill";

const useSize = () => {
  const ref = React.useRef<HTMLDivElement | null>(null);
  const resizeObserver = React.useRef<ResizeObserver | null>(null);
  const [size, setSize] = React.useState({
    width: 0,
    height: 0,
  });

  const teardownResizeObserver = React.useCallback(() => {
    if (resizeObserver.current) {
      if (ref.current) {
        resizeObserver.current.unobserve(ref.current);
      }
      resizeObserver.current.disconnect();
      resizeObserver.current = null;
    }
  }, []);

  const setupResizeObserver = React.useCallback(() => {
    if (resizeObserver.current) {
      teardownResizeObserver();
    }
    if (!ref.current) {
      return;
    }
    resizeObserver.current = new ResizeObserver((entries) => {
      const currentRefEntry = entries.find(
        ({ target }) => target === ref.current,
      );
      if (currentRefEntry) {
        const { width, height } = currentRefEntry.contentRect;
        setSize({ width, height });
      }
    });
    resizeObserver.current.observe(ref.current);
  }, [teardownResizeObserver]);

  const setRef = React.useCallback(
    (nextRef: HTMLDivElement) => {
      teardownResizeObserver();
      ref.current = nextRef;
      setupResizeObserver();
    },
    [setupResizeObserver, teardownResizeObserver],
  );
  return { ref: setRef, useRef: ref, size };
};

export default useSize;

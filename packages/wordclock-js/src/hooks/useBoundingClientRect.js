/* @flow */

import * as React from 'react';

const useBoundingClientRect = (ref: any) => {
  const [boundingClientRect, setBoundingClientRect] = React.useState();

  const updateBoundingClientRect = React.useCallback(
    () => setBoundingClientRect(ref?.current?.getBoundingClientRect()),
    [ref]
  );

  React.useEffect(() => {
    updateBoundingClientRect();
    window.addEventListener('resize', updateBoundingClientRect);
    return () => window.removeEventListener('resize', updateBoundingClientRect);
  }, [updateBoundingClientRect]);

  return boundingClientRect;
};

export default useBoundingClientRect;

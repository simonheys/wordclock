import { useEffect, useState } from "react";

const useAnimationFrame = () => {
  const [elapsed, setTime] = useState(0);

  useEffect(() => {
    let animationFrame: number, start: number;

    // Function to be executed on each animation frame
    const onFrame = () => {
      setTime(Date.now() - start);
      loop();
    };

    // Call onFrame() on next animation frame
    const loop = () => {
      animationFrame = requestAnimationFrame(onFrame);
    };

    // Start the loop
    start = Date.now();
    loop();

    // Clean things up
    return () => {
      cancelAnimationFrame(animationFrame);
    };
  }, []);

  return elapsed;
};

export default useAnimationFrame;

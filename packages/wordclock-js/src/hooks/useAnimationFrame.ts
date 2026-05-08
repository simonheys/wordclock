import { useEffect, useState } from 'react'

const useAnimationFrame = () => {
  const [elapsed, setElapsed] = useState(0)

  useEffect(() => {
    let animationFrame: number
    const start = Date.now()

    // Function to be executed on each animation frame
    const onFrame = () => {
      setElapsed(Date.now() - start)
      loop()
    }

    // Call onFrame() on next animation frame
    const loop = () => {
      animationFrame = requestAnimationFrame(onFrame)
    }

    // Start the loop
    loop()

    // Clean things up
    return () => {
      cancelAnimationFrame(animationFrame)
    }
  }, [])

  return elapsed
}

export default useAnimationFrame

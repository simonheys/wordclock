/** Ports of the macOS easing functions, so timings match the native version. */

export const TAU = Math.PI * 2

export const quadEaseIn = (t: number): number => t * t

export const quadEaseOut = (t: number): number => 1 - (1 - t) * (1 - t)

export const quadEaseInOut = (t: number): number =>
  t < 0.5 ? 2 * t * t : 1 - ((-2 * t + 2) * (-2 * t + 2)) / 2

const BACK_OVERSHOOT = 1.70158

export const easeOutBack = (t: number): number => {
  const u = t - 1
  return 1 + (BACK_OVERSHOOT + 1) * u * u * u + BACK_OVERSHOOT * u * u
}

/** Wraps to [0, 2pi). */
export const normaliseAngle = (angle: number): number => ((angle % TAU) + TAU) % TAU

/** Reduces a rotation delta to the equivalent turn of smallest magnitude. */
export const shortestAngleDelta = (delta: number): number => delta - TAU * Math.round(delta / TAU)

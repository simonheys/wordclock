//
//  easing_functions.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

// time, begin, change, duration

#define kWCEaseOvershoot 1.70158f  // 2.0f;// 1.70158f;

static inline float quad_ease_in(float t) {
    return 1 * (t /= 1) * t + 0;
}

static inline float quad_ease_out(float t) {
    return -1 * (t /= 1) * (t - 2) + 0;
}

static inline float quad_ease_in_out(float t) {
    if ((t *= 2.0f) < 1)
        return 0.5f * t * t;
    return -0.5f * ((--t) * (t - 2) - 1);
}

/**
 * Easing equation function for a back (overshooting cubic easing: (s+1)*t^3 -
 * s*t^2) easing out: decelerating from zero velocity.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
static inline float ease_out_back(float t) {
    return 1.0f * ((t = t / 1.0f - 1.0f) * t * ((kWCEaseOvershoot + 1) * t + kWCEaseOvershoot) + 1.0f) + 0;
}

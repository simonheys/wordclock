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
    const float x = t;
    return x * x;
}

static inline float quad_ease_out(float t) {
    const float x = t;
    return -1.0f * x * (x - 2.0f);
}

static inline float quad_ease_in_out(float t) {
    float x = t * 2.0f;
    if (x < 1.0f) {
        return 0.5f * x * x;
    }
    x -= 1.0f;
    return -0.5f * (x * (x - 2.0f) - 1.0f);
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
    const float x = t - 1.0f;
    const float s = kWCEaseOvershoot;
    return x * x * ((s + 1.0f) * x + s) + 1.0f;
}

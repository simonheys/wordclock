//
//  easing_functions.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//
/*
 *  easing_functions.h
 *  iphone_word_clock_open_gl
 *
 *  Created by Simon on 22/02/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
//time, begin, change, duration

#define kWCEaseOvershoot 1.70158f // 2.0f;// 1.70158f;

static inline float quad_ease_in(float t) {
	return 1*(t/=1)*t + 0;
}

static inline float quad_ease_out(float t) {
	return -1 *(t/=1)*(t-2) + 0;
}

static inline float quad_ease_in_out(float t) {
	if ((t*=2.0f) < 1) return 0.5f*t*t;
	return -0.5f * ((--t)*(t-2) - 1);
}

/**
 * Easing equation function for a back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing out: decelerating from zero velocity.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
static inline float ease_out_back(float t)
{
	//var s:Number = !Boolean(p_params) || isNaN(p_params.overshoot) ? 1.70158 : p_params.overshoot;
//	return c*((t=t/d-1)*t*((kWCEaseOvershoot+1)*t + kWCEaseOvershoot) + 1) + b;
	return 1.0f*((t=t/1.0f-1.0f)*t*((kWCEaseOvershoot+1)*t + kWCEaseOvershoot) + 1.0f) + 0;
}

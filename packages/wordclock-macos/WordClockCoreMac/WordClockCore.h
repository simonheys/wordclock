//
//  WordClockCore.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//
/*
 *  WordClockCore.h
 *  WordClockCore
 *
 *  Created by Simon on 05/04/2010.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

typedef NS_ENUM(NSInteger, WCDeviceOrientation) {
    WCDeviceOrientationUnknown,
    WCDeviceOrientationPortrait,            // Device oriented vertically, home button on
                                            // the bottom
    WCDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home
                                            // button on the top
    WCDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home
                                            // button on the right
    WCDeviceOrientationLandscapeRight,      // Device oriented horizontally, home
                                            // button on the left
    WCDeviceOrientationFaceUp,              // Device oriented flat, face up
    WCDeviceOrientationFaceDown             // Device oriented flat, face down
};

#if defined(__LP64__) && __LP64__
typedef double WCFloat;
#define WCFLOAT_MIN DBL_MIN
#define WCFLOAT_MAX DBL_MAX
#define WCFLOAT_IS_DOUBLE 1
#else /* !defined(__LP64__) || !__LP64__ */
typedef float WCFloat;
#define WCFLOAT_MIN FLT_MIN
#define WCFLOAT_MAX FLT_MAX
#define WCFLOAT_IS_DOUBLE 0
#endif /* !defined(__LP64__) || !__LP64__ */

/* Points. */

struct WCPoint {
    WCFloat x;
    WCFloat y;
};
typedef struct WCPoint WCPoint;

/* Sizes. */

struct WCSize {
    WCFloat width;
    WCFloat height;
};
typedef struct WCSize WCSize;

/* Rectangles. */

struct WCRect {
    WCPoint origin;
    WCSize size;
};
typedef struct WCRect WCRect;

static __inline__ WCPoint WCPointMake(WCFloat x, WCFloat y) {
    WCPoint p;
    p.x = x;
    p.y = y;
    return p;
}

static __inline__ WCSize WCSizeMake(WCFloat width, WCFloat height) {
    WCSize size;
    size.width = width;
    size.height = height;
    return size;
}

static __inline__ WCRect WCRectMake(WCFloat x, WCFloat y, WCFloat width, WCFloat height) {
    WCRect rect;
    rect.origin.x = x;
    rect.origin.y = y;
    rect.size.width = width;
    rect.size.height = height;
    return rect;
}

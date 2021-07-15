//
//  culling.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//
/*
 *  culling.h
 *  iphone_word_clock_open_gl
 *
 *  Created by Simon on 15/03/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import <ApplicationServices/ApplicationServices.h>

#import "assert.h"
#import "stdio.h"
#import "stdlib.h"

typedef struct _WordClockVerticesForCulling {
    float xl;
    float yt;
    float xr;
    float yb;
    int i;
} WordClockRectsForCulling;

int cull_rects(WordClockRectsForCulling *rects, int numberOfRects, CGRect rect, void *resultPointer);

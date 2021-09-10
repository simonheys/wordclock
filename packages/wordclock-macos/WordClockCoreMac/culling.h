//
//  culling.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

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

//
//  culling.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "stdio.h"
#import "stdlib.h"
#import "assert.h"

typedef struct _WordClockVerticesForCulling {
	float xl;
	float yt; 
	float xr;
	float yb;  
	int i;
} WordClockRectsForCulling;

int cull_rects(WordClockRectsForCulling *rects, int numberOfRects, CGRect rect, void *resultPointer );

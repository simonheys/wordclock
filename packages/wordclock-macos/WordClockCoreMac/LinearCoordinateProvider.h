//
//  LinearCoordinateProvider.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "CoordinateProvider.h"
#import "WordClockCore.h"

#define FONT_SIZE_TOLERANCE 0.05

@interface LinearCoordinateProvider : CoordinateProvider {
   @private
    NSMutableArray *_sizeCache;
    NSMutableArray *_rectCache;

    //	float _tracking;
    float _leading;

    float _width;
    float _height;
    float _x;
    float _y;
    float _wordScale;
    float _widthUsedInPreviousUpdate;
    float _heightUsedInPreviousUpdate;
}

@property float width;
@property float height;
@property float wordScale;

@end

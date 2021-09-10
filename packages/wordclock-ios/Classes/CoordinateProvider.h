//
//  CoordinateProvider.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
// FIXME importing WordClockGLView causes errors....why?
//#import "WordClockGLView.h"
#import "DLog.h"
#import "WordClockWordManager.h"
//#import "WordClockWord.h"

typedef struct _WordClockWordCoordinates {
    float x;
    float y;
    float w;
    float h;
    float r;
    float w_bounds;
    float h_bounds;
} WordClockWordCoordinates;

typedef struct _WordClockOrientationVector {
    float vx;
    float vy;
} WordClockOrientationVector;

@interface CoordinateProvider : NSObject {
    WordClockWordCoordinates *_coordinates;
    WordClockOrientationVector _orientationVector;
    float _translateX;
    float _translateY;
    float _scale;
    float _vx;
    float _vy;
    float _rotation;
}
- (void)update;
- (void)shake;
- (CoordinateProvider *)clone;
- (void)setupForCurrentSize;

@property(nonatomic) CGSize size;
@property WordClockWordCoordinates *coordinates;
@property float scale;
@property float translateX;
@property float translateY;
@property WordClockOrientationVector orientationVector;

@end

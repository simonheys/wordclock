//
//  CoordinateProvider.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

// FIXME importing WordClockRenderView causes errors....why?
// #import "WordClockRenderView.h"
#import "WordClockCore.h"

@class WordClockWordManager;
@class TweenManager;

typedef struct _WordClockWordCoordinates {
    float x;
    float y;
    float w;
    float h;
    float r;
    float wBounds;
    float hBounds;
} WordClockWordCoordinates;

typedef struct _WordClockOrientationVector {
    float vx;
    float vy;
} WordClockOrientationVector;

@interface CoordinateProvider : NSObject {
    WordClockWordCoordinates *_coordinates;
    WordClockOrientationVector _orientationVector;
    WCDeviceOrientation _currentOrientation;
    WordClockWordManager *_wordClockWordManager;
    TweenManager *_tweenManager;
    float _translateX;
    float _translateY;
    float _scale;
    float _vx;
    float _vy;
    float _rotation;
}
- (instancetype)initWithWordClockWordManager:(WordClockWordManager *)wordClockWordManager tweenManager:(TweenManager *)tweenManager;
- (void)update;
- (void)shake;
- (void)setupForOrientation:(WCDeviceOrientation)orientation andBounds:(WCRect)screenBounds;
- (BOOL)needsSetupForOrientation:(WCDeviceOrientation)orientation;
- (void)setupForDefaultOrientation;
- (void)texturesDidChange;

@property(NS_NONATOMIC_IOSONLY, readonly, strong) CoordinateProvider *clone;
@property WordClockWordCoordinates *coordinates;
@property float scale;
@property float translateX;
@property float translateY;
@property WordClockOrientationVector orientationVector;
@property(nonatomic, retain) WordClockWordManager *wordClockWordManager;
@property(nonatomic, retain) TweenManager *tweenManager;
@end

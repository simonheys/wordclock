//
//  Tween.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLog.h"
#import "TweenManager.h"
#import "easing_functions.h"

typedef enum { kTweenQuadEaseInOut, kTweenQuadEaseIn, kTweenQuadEaseOut, kTweenEaseOutBack } TweenEasing;

@interface Tween : NSObject {
    id target;
    NSString *keyPath;
    NSDate *startTime;
    id onCompleteTarget;

    float _targetValue;

    NSTimeInterval _duration;
    TweenEasing _ease;
    SEL _onComplete;

    float _startValue;
}

+ (Tween *)tweenWithTarget:(id)target keyPath:(NSString *)keyPath toFloatValue:(float)targetValue delay:(NSTimeInterval)delay duration:(NSTimeInterval)duration ease:(TweenEasing)ease;

+ (Tween *)tweenWithTarget:(id)target keyPath:(NSString *)keyPath toFloatValue:(float)targetValue delay:(NSTimeInterval)delay duration:(NSTimeInterval)duration ease:(TweenEasing)ease onComplete:(SEL)onComplete onCompleteTarget:(id)onCompleteTarget;

- (void)update;
- (void)cancel;

@property(assign) id target;
@property(retain) id keyPath;
@property(assign) id onCompleteTarget;
@property(retain) id startTime;

@end

//
//  Tween.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "Tween.h"

#import "TweenManager.h"
#import "easing_functions.h"

@interface Tween ()
@property CGFloat startValue;
@property CGFloat targetValue;
@property NSTimeInterval duration;
@property SEL onComplete;
@property TweenEasing ease;
@end

@implementation Tween

@synthesize keyPath = _keyPath;
@synthesize startTime = _startTime;
@synthesize target = _target;
@synthesize onComplete = _onComplete;
@synthesize onCompleteTarget = _onCompleteTarget;

@synthesize startValue = _startValue;
@synthesize targetValue = _targetValue;
@synthesize duration = _duration;
@synthesize ease = _ease;
@synthesize tweenManager = _tweenManager;

- (void)dealloc {
    [_keyPath release];
    [_startTime release];
    [super dealloc];
}

- (instancetype)initWithTarget:(id)aTarget keyPath:(NSString *)aKeyPath toFloatValue:(float)targetValue delay:(NSTimeInterval)delay duration:(NSTimeInterval)duration ease:(TweenEasing)ease onComplete:(SEL)onComplete onCompleteTarget:(id)aOnCompleteTarget {
    self = [super init];
    if (self != nil) {
        self.target = aTarget;
        self.keyPath = aKeyPath;
        self.targetValue = targetValue;
        self.duration = duration;
        self.ease = ease;
        self.onComplete = onComplete;
        self.onCompleteTarget = aOnCompleteTarget;

        @try {
            self.startValue = [[self.target valueForKeyPath:self.keyPath] floatValue];
        } @catch (NSException *exception) {
            self.startValue = 0;
        }
        self.startTime = [NSDate dateWithTimeIntervalSinceNow:delay];
    }
    return self;
}

- (void)cancel {
    [self.tweenManager removeTween:self];
}

- (void)update {
    BOOL complete = NO;
    NSTimeInterval currentTimeValue = -[self.startTime timeIntervalSinceNow];
    if (currentTimeValue > 0) {
        float m = currentTimeValue / self.duration;
        float e;
        if (m >= 1.0) {
            m = 1.0;
            complete = YES;
        }
        switch (self.ease) {
            case kTweenQuadEaseInOut:
                e = quad_ease_in_out(m);
                break;
            case kTweenQuadEaseIn:
                e = quad_ease_in(m);
                break;
            case kTweenQuadEaseOut:
                e = quad_ease_out(m);
                break;
            case kTweenEaseOutBack:
                e = ease_out_back(m);
                break;
            default:
                e = m;
                break;
        }
        @try {
            [self.target setValue:[NSNumber numberWithFloat:self.startValue + (self.targetValue - self.startValue) * e] forKeyPath:self.keyPath];
        } @catch (NSException *exception) {
            // bail out
            //            complete = YES;
            [self.tweenManager removeTween:self];
        }
    }
    if (complete) {
        @try {
            if ([self.onCompleteTarget respondsToSelector:self.onComplete]) {
                [self.onCompleteTarget performSelector:self.onComplete withObject:self];
            }
        } @catch (NSException *exception) {
        }
        if (nil != self.onCompleteTarget) {
            DDLogVerbose(@"removing tween");
        }
        [self.tweenManager removeTween:self];
    }
}

@end

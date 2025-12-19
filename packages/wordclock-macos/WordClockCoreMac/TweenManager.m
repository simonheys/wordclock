//
//  TweenManager.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "TweenManager.h"

#import "Tween.h"

@implementation TweenManager

@synthesize tweens = _tweens;
@synthesize tweensForRemoval = _tweensForRemoval;

- (void)dealloc {
    [_tweens release];
    [_tweensForRemoval release];
    [super dealloc];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.tweens = [[[NSMutableArray alloc] init] autorelease];
        self.tweensForRemoval = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (Tween *)tweenWithTarget:(id)aTarget keyPath:(NSString *)aKeyPath toFloatValue:(float)targetValue delay:(NSTimeInterval)delay duration:(NSTimeInterval)duration ease:(TweenEasing)ease {
    Tween *tween = [[[Tween alloc] initWithTarget:aTarget keyPath:aKeyPath toFloatValue:targetValue delay:delay duration:duration ease:ease onComplete:nil onCompleteTarget:nil] autorelease];
    [self addTween:tween];
    return tween;
}

- (Tween *)tweenWithTarget:(id)aTarget keyPath:(NSString *)aKeyPath toFloatValue:(float)targetValue delay:(NSTimeInterval)delay duration:(NSTimeInterval)duration ease:(TweenEasing)ease onComplete:(SEL)onComplete onCompleteTarget:(id)aOnCompleteTarget {
    Tween *tween = [[[Tween alloc] initWithTarget:aTarget keyPath:aKeyPath toFloatValue:targetValue delay:delay duration:duration ease:ease onComplete:onComplete onCompleteTarget:aOnCompleteTarget] autorelease];
    [self addTween:tween];
    return tween;
}

- (void)addTween:(Tween *)tween {
    @synchronized(self) {
        tween.tweenManager = self;
        [self.tweens addObject:tween];
    }
}

- (void)removeAllTweens {
    @synchronized(self) {
        [self.tweens removeAllObjects];
    }
}

- (void)removeTween:(Tween *)tween {
    @synchronized(self) {
        [self.tweensForRemoval addObject:tween];
    }
}

- (void)removeTweensWithTarget:(id)target {
    @synchronized(self) {
        Tween *tween;
        for (tween in self.tweens) {
            if (tween.target == target) {
                [self removeTween:tween];
            }
        }
    }
}

- (void)removeTweensWithTarget:(id)target andKeyPath:(NSString *)keyPath {
    @synchronized(self) {
        Tween *tween;
        for (tween in self.tweens) {
            if (tween.target == target && [tween.keyPath isEqualToString:keyPath]) {
                [self removeTween:tween];
            }
        }
    }
}

// we also remove objects here
// so that this array can't be mutated while we are running
- (void)update {
    @synchronized(self) {
        Tween *tween;
        if ([self.tweensForRemoval count] > 0) {
            for (tween in self.tweensForRemoval) {
                [self.tweens removeObject:tween];
            }
            [self.tweensForRemoval removeAllObjects];
        } else {
            for (tween in self.tweens) {
                [tween update];
            }
        }
    }
}

@end

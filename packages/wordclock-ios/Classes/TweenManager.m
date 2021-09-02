//
//  TweenManager.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "TweenManager.h"
#import "Tween.h"

@interface TweenManager ()
@property (retain) NSMutableArray *tweens;
@property (retain) NSMutableArray *tweensForRemoval;
@end

@implementation TweenManager

- (void) dealloc
{
	[_tweens release];
	[_tweensForRemoval release];
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.tweens = [[[NSMutableArray alloc] init] autorelease];
		self.tweensForRemoval = [[[NSMutableArray alloc] init] autorelease];
	}
	return self;
}

- (void)addTween:(Tween *)tween {
    @synchronized (self) {
        [self.tweens addObject:tween];
    }
}

- (void)removeAllTweens {
    @synchronized (self) {
        Tween *tween;
        for ( tween in self.tweens ) {
            [self removeTween:tween];
        }
    }
}

- (void)removeTween:(Tween *)tween
{
    @synchronized (self) {
        [self.tweensForRemoval addObject:tween];
    }
}

- (void)removeTweensWithTarget:(id)target
{
    @synchronized (self) {
        Tween *tween;
        for ( tween in self.tweens ) {
            if ( tween.target == target ) {
                [self removeTween:tween];
            }
        }
    }
}

- (void)removeTweensWithTarget:(id)target andKeyPath:(NSString *)keyPath
{
    @synchronized (self) {
        Tween *tween;
        for ( tween in self.tweens ) {
            if ( tween.target == target && [tween.keyPath isEqualToString:keyPath] ) {
                [self removeTween:tween];
            }
        }
    }
}

// we also remove objects here
// so that this array can't be mutated while we are running
- (void)update
{	
    @synchronized (self) {
        Tween *tween;
        if ( [ self.tweensForRemoval count ] > 0 ) {
            for ( tween in self.tweensForRemoval ) {
                [self.tweens removeObject:tween];
            }
            [self.tweensForRemoval removeAllObjects];
        }
        else {
            for ( tween in self.tweens ) {
                [tween update];
            }
        }
    }
}



// ____________________________________________________________________________________________________ singleton

+ (TweenManager *)sharedInstance {
    static dispatch_once_t once;
    static TweenManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end


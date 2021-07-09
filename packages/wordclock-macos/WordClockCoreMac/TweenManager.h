//
//  TweenManager.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tween.h"

@interface TweenManager : NSObject {

@private
	NSMutableArray *_tweens;
	NSMutableArray *_tweensForRemoval;
}

- (void)update;
- (void)addTween:(Tween *)tween;
- (void)removeTween:(Tween *)tween;
- (void)removeTweensWithTarget:(id)target;
- (void)removeTweensWithTarget:(id)target andKeyPath:(NSString *)keyPath;
- (void)removeAllTweens;

-(Tween *)tweenWithTarget:(id)aTarget
		keyPath:(NSString *)aKeyPath
		toFloatValue:(float)targetValue 
		delay:(NSTimeInterval)delay 
		duration:(NSTimeInterval)duration
		ease:(TweenEasing)ease;

-(Tween *)tweenWithTarget:(id)aTarget
		keyPath:(NSString *)aKeyPath
		toFloatValue:(float)targetValue 
		delay:(NSTimeInterval)delay 
		duration:(NSTimeInterval)duration
		ease:(TweenEasing)ease
		onComplete:(SEL)onComplete
		onCompleteTarget:(id)aOnCompleteTarget;

@property (retain) NSMutableArray *tweens;
@property (retain) NSMutableArray *tweensForRemoval;
@end

//
//  TweenManager.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tween.h"
#import "DisplayLinkManager.h"

@class Tween;

@interface TweenManager : NSObject
- (void)update;
- (void)addTween:(Tween *)tween;
- (void)removeTween:(Tween *)tween;
- (void)removeTweensWithTarget:(id)target;
- (void)removeTweensWithTarget:(id)target andKeyPath:(NSString *)keyPath;
- (void)removeAllTweens;

+ (TweenManager*)sharedInstance;

@end

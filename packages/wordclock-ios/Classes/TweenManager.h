//
//  TweenManager.h
//  iphone_untility_app
//
//  Created by Simon on 08/03/2009.
//  Copyright 2009 Simon Heys. All rights reserved.
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

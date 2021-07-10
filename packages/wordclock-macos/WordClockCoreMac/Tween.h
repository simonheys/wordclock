//
//  Tween.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TweenManager;

typedef NS_ENUM(NSInteger, TweenEasing) {
	kTweenQuadEaseInOut,
	kTweenQuadEaseIn,
	kTweenQuadEaseOut,
	kTweenEaseOutBack
} ;

@interface Tween : NSObject {
@private
    NSString *_keyPath;
    NSDate *_startTime;
    TweenManager *_tweenManager;
    id _onCompleteTarget;
    id _target;
    CGFloat _startValue;
    CGFloat _targetValue;
    NSTimeInterval _duration;
    SEL _onComplete;
    TweenEasing _ease;
}

- (instancetype)initWithTarget:(id)aTarget
		keyPath:(NSString *)aKeyPath
		toFloatValue:(float)targetValue 
		delay:(NSTimeInterval)delay 
		duration:(NSTimeInterval)duration
		ease:(TweenEasing)ease 
		onComplete:(SEL)onComplete
		onCompleteTarget:(id)aOnCompleteTarget;
		
- (void)update;
- (void)cancel;

@property (nonatomic, assign) TweenManager *tweenManager;
@property (retain) NSString *keyPath;
@property (retain) NSDate *startTime;
@property (assign) id onCompleteTarget;
@property (assign) id target;

@end

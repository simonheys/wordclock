//
//  Tween.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "Tween.h"

@interface Tween ()
- (id)initWithTarget:(id)aTarget
		keyPath:(NSString *)aKeyPath
		toFloatValue:(float)targetValue 
		delay:(NSTimeInterval)delay 
		duration:(NSTimeInterval)duration
		ease:(TweenEasing)ease 
		onComplete:(SEL)onComplete
		onCompleteTarget:(id)aOnCompleteTarget;
@end

@implementation Tween

+(Tween *)tweenWithTarget:(id)aTarget
		keyPath:(NSString *)aKeyPath
		toFloatValue:(float)targetValue 
		delay:(NSTimeInterval)delay 
		duration:(NSTimeInterval)duration
		ease:(TweenEasing)ease
{
    Tween *tween = [[[Tween alloc] initWithTarget:aTarget
		keyPath:aKeyPath
		toFloatValue:targetValue 
		delay:delay 
		duration:duration
		ease:ease 
		onComplete:nil
		onCompleteTarget:nil
	] autorelease];
    [[TweenManager sharedInstance] addTween:tween];
    return tween;
}

+(Tween *)tweenWithTarget:(id)aTarget
		keyPath:(NSString *)aKeyPath
		toFloatValue:(float)targetValue 
		delay:(NSTimeInterval)delay 
		duration:(NSTimeInterval)duration
		ease:(TweenEasing)ease
		onComplete:(SEL)onComplete
		onCompleteTarget:(id)aOnCompleteTarget
{
    Tween *tween = [[[Tween alloc] initWithTarget:aTarget
		keyPath:aKeyPath
		toFloatValue:targetValue 
		delay:delay 
		duration:duration
		ease:ease 
		onComplete:onComplete
		onCompleteTarget:aOnCompleteTarget
	] autorelease];
    [[TweenManager sharedInstance] addTween:tween];
    return tween;
}

- (id)initWithTarget:(id)aTarget
		keyPath:(NSString *)aKeyPath
		toFloatValue:(float)targetValue 
		delay:(NSTimeInterval)delay 
		duration:(NSTimeInterval)duration
		ease:(TweenEasing)ease 
		onComplete:(SEL)onComplete
		onCompleteTarget:(id)aOnCompleteTarget
{
	self = [super init];
	if (self != nil) {
		self.target = aTarget;
		self.keyPath = aKeyPath;
		_targetValue = targetValue;
		_duration = duration;
		_ease = ease;
		_onComplete = onComplete;
		self.onCompleteTarget = aOnCompleteTarget;
        
        @try {
            _startValue = [[self.target valueForKeyPath:self.keyPath] floatValue];
        }
        @catch (NSException *exception) {
            _startValue = 0;
        }
		self.startTime = [NSDate dateWithTimeIntervalSinceNow:delay];
	}
	return self;
}

-(void)cancel
{
	[[TweenManager sharedInstance] removeTween:self];	
}

-(void)update
{
	BOOL complete = NO;
	NSTimeInterval currentTimeValue = -[self.startTime timeIntervalSinceNow];
	if ( currentTimeValue > 0 ) {
		float m = currentTimeValue / _duration;
		float e;
		if ( m >= 1.0 ) {
			m = 1.0;
			complete = YES;
		}
		switch ( _ease ) {
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
            [self.target setValue:[NSNumber numberWithFloat:_startValue+(_targetValue-_startValue)*e] forKeyPath:self.keyPath];
        }
        @catch ( NSException *exception ) {
            // bail out
            complete = YES;
        }
	}
	if ( complete ) {
        @try {
            if ( [self.onCompleteTarget respondsToSelector:_onComplete] )
            {
                [self.onCompleteTarget performSelector:_onComplete withObject:self];
            }
        }
        @catch ( NSException *exception ) {
        }
		[[TweenManager sharedInstance] removeTween:self];
	}
}

- (void)dealloc {
//    [target release];
    [keyPath release];
//    [onCompleteTarget release];
    [startTime release];
	[super dealloc];
}
@synthesize target;
@synthesize keyPath;
@synthesize onCompleteTarget;
@synthesize startTime;

@end

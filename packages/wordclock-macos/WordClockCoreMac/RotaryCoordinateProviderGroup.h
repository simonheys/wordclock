//
//  RotaryCoordinateProviderGroup.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordClockWordGroup.h"
#import "Tween.h"
#import "WordClockWordManager.h"

@class TweenManager;

// handles settings, animation and rotation for each group
// of a rotary coordinate provider
@interface RotaryCoordinateProviderGroup : NSObject {
@private
	float _angle;
	float _radius;
	float _displayedRadius;
	float _scaleFactor;
	float _maximumLabelWidth;
	BOOL _observingGroup;
	Tween *_angleTween;
	WordClockWordGroup *_group;
	RotaryCoordinateProviderGroup *_parent;
	RotaryCoordinateProviderGroup *_child;
    TweenManager *_tweenManager;
}

-(instancetype)initWithGroup:(WordClockWordGroup *)aGroup tweenManager:(TweenManager *)tweenManager;
@property (NS_NONATOMIC_IOSONLY, readonly) float outsideRadius;
- (void)parentOutsideRadiusWasUpdated;
- (void)update;
- (void)establishInitialValues;

/*
- (void)animateToAngle:(float)value;
- (CAAnimation*)rotationAnimationForKeyPath:(NSString*)keyPath to:(float)to duration:(float)duration;
- (void)checkAngleConstraint;
- (void)parentOutsideRadiusWasUpdated;
- (float)outsideRadius;
- (float)easeOutBack:(float)t b:(float)b c:(float)c d:(float)d;
*/
@property float angle;
@property float displayedRadius;
@property float radius;
@property float scaleFactor;
@property (readonly) float maximumLabelWidth;
@property (retain) WordClockWordGroup *group;
@property (assign) RotaryCoordinateProviderGroup *parent;
@property (assign) RotaryCoordinateProviderGroup *child;
@end

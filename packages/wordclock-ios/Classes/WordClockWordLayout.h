//
//  WordClockWordLayout.h
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "DLog.h"
#import "LinearCoordinateProvider.h"
#import "RotaryCoordinateProvider.h"
#import "WordClockViewControls.h"
#import "sin_and_cos_tables.h"
#import "easing_functions.h"
#import "culling.h"
#import "Tween.h"

extern NSString *const kWordClockWordLayoutTargetScaleAndTranslateDidChangeNotification;
extern NSString *const kWordClockWordLayoutTargetOrientationVectorDidChangeNotification;

@interface WordClockWordLayout : NSObject <UIAccelerometerDelegate>
{
@private
	BOOL _isTweening;
	BOOL _isLinearSelected;
	GLfloat *_vertices;
	WordClockRectsForCulling *_rectsForCulling;
	LinearCoordinateProvider *_linear;
	RotaryCoordinateProvider *_rotary;
	CoordinateProvider *_tweenSnapshotCoordinateProvider;
	UIDeviceOrientation _currentOrientation;
	BOOL _needsOrientationUpdateNotification;
	GLfloat _linearTranslateX;
	GLfloat _linearTranslateY;
	GLfloat _linearScale;
	GLfloat _rotaryTranslateX;
	GLfloat _rotaryTranslateY;
	GLfloat _rotaryScale;
	GLfloat _translateX;
	GLfloat _translateY;
	GLfloat _scale;
	
	Tween *_transitionTween;
	float _transitionTweenValue;
	
	UIAccelerationValue	_accelerometerValues[3];
	CFTimeInterval _lastShakeTime;
}

- (void)update;
- (void)setTranslateX:(GLfloat)value;
- (float)getTargetScale;
- (float)getTargetTranslateX;
- (float)getTargetTranslateY;
- (float)getLayoutWordScale;
- (WordClockOrientationVector)getTargetOrientationVector;
- (void)tweenFromCoordinateProvider:(CoordinateProvider *)target duration:(float)duration;
- (void)shake;

@property (nonatomic) CGSize size;
@property GLfloat *vertices;
@property WordClockRectsForCulling *rectsForCulling;
@property (nonatomic) GLfloat scale;
@property (nonatomic) GLfloat translateX;
@property (nonatomic) GLfloat translateY;
@property BOOL isTweening;

@property float transitionTweenValue;

@end

//
//  WordClockWordLayout.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoordinateProvider.h"
#import "culling.h"

@class TweenManager;
@class Tween;
@class WordClockWordManager;
@class LinearCoordinateProvider;
@class RotaryCoordinateProvider;

extern NSString *const kWordClockWordLayoutTargetScaleAndTranslateDidChangeNotification;
extern NSString *const kWordClockWordLayoutTargetOrientationVectorDidChangeNotification;

@interface WordClockWordLayout : NSObject
{
@private
	BOOL _isTweening;
	BOOL _isLinearSelected;
	GLfloat *_vertices;
	WordClockRectsForCulling *_rectsForCulling;
	LinearCoordinateProvider *_linear;
	RotaryCoordinateProvider *_rotary;
	CoordinateProvider *tweenSnapshotCoordinateProvider;
	WCDeviceOrientation _currentOrientation;
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

    CoordinateProvider *_tweenSnapshotCoordinateProvider;
    TweenManager *_tweenManager;
    WordClockWordManager *_wordClockWordManager;

}

- (instancetype)initWithWordClockWordManager:(WordClockWordManager *)wordClockWordManager tweenManager:(TweenManager *)tweenManager;
- (void)update;
- (void)setTranslateX:(GLfloat)value;
@property (NS_NONATOMIC_IOSONLY, getter=getTargetScale, readonly) float targetScale;
@property (NS_NONATOMIC_IOSONLY, getter=getTargetTranslateX, readonly) float targetTranslateX;
@property (NS_NONATOMIC_IOSONLY, getter=getTargetTranslateY, readonly) float targetTranslateY;
@property (NS_NONATOMIC_IOSONLY, getter=getLayoutWordScale, readonly) float layoutWordScale;
@property (NS_NONATOMIC_IOSONLY, getter=getTargetOrientationVector, readonly) WordClockOrientationVector targetOrientationVector;
- (void)tweenFromCoordinateProvider:(CoordinateProvider *)target reverse:(BOOL)reverse;
- (void)linearSelected:(id)sender;
- (void)rotarySelected:(id)sender;
- (void)texturesDidChange;

@property GLfloat *vertices;
@property (nonatomic) GLfloat scale;
@property (nonatomic) GLfloat translateX;
@property (nonatomic) GLfloat translateY;
@property BOOL isTweening;
@property WordClockRectsForCulling *rectsForCulling;
@property float transitionTweenValue;

@end

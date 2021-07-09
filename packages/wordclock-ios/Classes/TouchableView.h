//
//  TouchableView.h
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLog.h"
#import "uptime.h"

typedef enum _SwipeDirection {
    kSwipeDirectionLeft,
	kSwipeDirectionRight
} SwipeDirection;

#define kSwipeMinimumDistanceX 24
#define kSwipeMinimumDistanceY 24
#define kSwipeMinimumTimeInSeconds 0.03
#define kMinimumDragDistance 10
#define kTouchableViewMaximumScale 4.0f
#define kTouchableViewMinimumScale 0.2f

@interface TouchableView : UIView {
	id _delegate;
@private
	BOOL _enabled;

	CGFloat _scale;
	CGFloat _translationX;
	CGFloat _translationY;
	
	float _orientationVectorX;
	float _orientationVectorY;
	
//	CGPoint startTouchPosition;
//	CGFloat initialDistance;
	CFMutableDictionaryRef _initialTouchLocationDictionary;
	CFMutableDictionaryRef _currentTouchLocationDictionary;
	CFMutableDictionaryRef _previousTouchLocationDictionary;
	NSTimer *_tapTimer;
	

}

- (void)singleTap: (NSTimer*)timer;
- (void)reset;
- (void)setTranslationX:(float)translationX translationY:(float)translationY scale:(float)scale;

@property CGFloat scale;
@property CGFloat translationX;
@property CGFloat translationY;
@property float orientationVectorX;
@property float orientationVectorY;
@property (nonatomic, retain) id delegate;
@property BOOL enabled;
@end

@interface TouchableView(TouchableViewDelegate)
- (void)touchableViewScaleDidChange:(TouchableView*)view;
- (void)touchableViewTranslationDidChange:(TouchableView*)view;
- (void)touchableViewDidChange:(TouchableView*)view;
- (void)touchableViewSingleTap:(TouchableView*)view;
- (void)touchableViewDoubleTap:(TouchableView*)view;
- (void)touchableViewSwipe:(TouchableView*)view direction:(SwipeDirection)direction;

- (void)touchableViewTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchableViewTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchableViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchableViewTrackingTouchesBegan:(TouchableView*)view;
- (void)touchableViewTrackingTouchesEnded:(TouchableView*)view;

@end


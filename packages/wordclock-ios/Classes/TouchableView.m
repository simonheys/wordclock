//
//  TouchableView.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "TouchableView.h"

static inline CGFloat CGPointDistanceBetween(CGPoint fromPoint, CGPoint toPoint) 
{
	float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrtf(x * x + y * y);
}

@interface TouchableView (TouchableViewPrivate) 
	- (void)setup;
	- (void)updateCurrentToucheLocationDictionaryWithTouches:(NSSet *)touches;
	- (void)invalidateTapTimer;
	- (void)handleSwipe: (SwipeDirection) direction; 
@end

@implementation TouchableView

@synthesize scale = _scale;
@synthesize translationX = _translationX;
@synthesize translationY = _translationY;
@synthesize delegate = _delegate;
@synthesize orientationVectorX = _orientationVectorX;
@synthesize orientationVectorY = _orientationVectorY;
@synthesize enabled = _enabled;

- (id)initWithCoder:(NSCoder*)coder 
{
	if (self = [super initWithCoder:coder]) {
		DLog(@"initWithCoder");
		[self setMultipleTouchEnabled:YES];
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		DLog(@"initWithFrame");
		[self setMultipleTouchEnabled:YES];
		[self setup];
    }
    return self;
}

- (void)setup
{
	_currentTouchLocationDictionary = CFDictionaryCreateMutable(
		NULL, 
		0, 
		&kCFTypeDictionaryKeyCallBacks, 
		&kCFTypeDictionaryValueCallBacks
	); 
	
	_previousTouchLocationDictionary = CFDictionaryCreateMutable(
		NULL, 
		0, 
		&kCFTypeDictionaryKeyCallBacks, 
		&kCFTypeDictionaryValueCallBacks
	); 
	
	_initialTouchLocationDictionary = CFDictionaryCreateMutable(
		NULL, 
		0, 
		&kCFTypeDictionaryKeyCallBacks, 
		&kCFTypeDictionaryValueCallBacks
	); 

	_scale = 1.0f;
	_translationX = 0.0f;
	_translationY = 0.0f;
	
	_orientationVectorX = 1.0f;
	_orientationVectorY = 0.0f;
	
	_enabled = YES;
}

/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
//	CGContextRef context = UIGraphicsGetCurrentContext();
  //  CGRect    myFrame = self.bounds;
	[[UIColor redColor] set];
	//UIRectFrame(myFrame);
	
	UIRectFill(CGRectMake(_scale*_translationX+320.0f/2 - _scale * 50,_scale*_translationY+480.0f/2 - _scale * 50,_scale*100,_scale*100));
	
	[[UIColor whiteColor] set];
	UIRectFill(CGRectMake(_scale*_translationX+320.0f/2 - _scale * 50,_scale*_translationY+480.0f/2 - _scale * 50,_scale*50,_scale*50));
	UIRectFill(CGRectMake(_scale*_translationX+320.0f/2,_scale*_translationY+480.0f/2,_scale*50,_scale*50));
	
}
*/

- (void)dealloc {
    [self invalidateTapTimer];
	CFRelease(_initialTouchLocationDictionary);
	CFRelease(_currentTouchLocationDictionary);
	CFRelease(_previousTouchLocationDictionary);
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	DLog(@"touchesBegan");
	if ( CFDictionaryGetCount(_currentTouchLocationDictionary) == 0 ) {
		if ([_delegate respondsToSelector:@selector(touchableViewTrackingTouchesBegan:)]) {
			[_delegate touchableViewTrackingTouchesBegan:self];
		}				
	}
	
	// add starting points to dictionary
	for (UITouch *touch in touches) {
		CGPoint point = [touch locationInView:self];
		CFDictionaryRef pointRef = CGPointCreateDictionaryRepresentation(point);
		CFDictionaryAddValue(_initialTouchLocationDictionary, touch, pointRef);
		CFDictionaryAddValue(_currentTouchLocationDictionary, touch, pointRef);
		CFDictionaryAddValue(_previousTouchLocationDictionary, touch, pointRef);	
		CFRelease(pointRef);	
	}
	
    [self invalidateTapTimer];
	[self.nextResponder touchesBegan:touches withEvent:event];
	
	if ([_delegate respondsToSelector:@selector(touchableViewTouchesBegan:withEvent:)]) {
		[_delegate touchableViewTouchesBegan:touches withEvent:event];
	}				

}

- (void)updateCurrentToucheLocationDictionaryWithTouches:(NSSet *)touches 
{
	for (UITouch *touch in touches){
		CGPoint point = [touch locationInView:self];
		CFDictionaryRef pointRef = CGPointCreateDictionaryRepresentation(point);
		CFDictionarySetValue(_currentTouchLocationDictionary, touch, pointRef);
		CFRelease(pointRef);
	}
}

- (void)invalidateTapTimer
{
    if([_tapTimer isValid])
	{
        [_tapTimer invalidate];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	BOOL scaleChanged = NO;
	BOOL translationChanged = NO;
	uint i;
	CGFloat moveX = 0.0f;
	CGFloat moveY = 0.0f;
	CGFloat scale = 1.0f;
	
	// update coordinates in dictionary
	[self updateCurrentToucheLocationDictionaryWithTouches:touches];

	[self invalidateTapTimer];
		
	// unpack the dictionary	
	int count = CFDictionaryGetCount(_currentTouchLocationDictionary);
	const void **values = (const void **)malloc (sizeof(void *) * count);
	const void **keys = (const void **)malloc (sizeof(void *) * count);
	CGPoint *currentTouchPoint = malloc (sizeof(CGPoint) * count);
	CGPoint *previousTouchPoint = malloc (sizeof(CGPoint) * count);
	CFDictionaryGetKeysAndValues(_currentTouchLocationDictionary, keys, values);
	
	// get each point into an array
	for ( i = 0; i < count; i++ ) {
		CGPointMakeWithDictionaryRepresentation( (CFDictionaryRef)values[i], &currentTouchPoint[i] );
		CGPointMakeWithDictionaryRepresentation( 
			CFDictionaryGetValue(_previousTouchLocationDictionary, keys[i]),
			&previousTouchPoint[i]
		);
	}
	
	switch ( CFDictionaryGetCount(_currentTouchLocationDictionary)) {
		case 1:
			// only one finger moving
			
			moveX = (currentTouchPoint[0].x - previousTouchPoint[0].x)/_scale;
			moveY = (currentTouchPoint[0].y - previousTouchPoint[0].y)/_scale;

			break;
		
		case 2:
		
			break;
	
	}
    if ( CFDictionaryGetCount(_currentTouchLocationDictionary) == 2) {
		
        CGFloat currentDistance = CGPointDistanceBetween(currentTouchPoint[0], currentTouchPoint[1]);
		CGFloat previousDistance = CGPointDistanceBetween(previousTouchPoint[0], previousTouchPoint[1]); 
		 
		scale = currentDistance / previousDistance;

		// centre of transformation should be around the middle of the two points;		
		// this needs to be relative to centre of the whole thing
	
		CGFloat previousCentreX = ( previousTouchPoint[0].x + previousTouchPoint[1].x ) / 2;
		CGFloat previousCentreY = ( previousTouchPoint[0].y + previousTouchPoint[1].y ) / 2;

		CGFloat currentCentreX = ( currentTouchPoint[0].x + currentTouchPoint[1].x ) / 2;
		CGFloat currentCentreY = ( currentTouchPoint[0].y + currentTouchPoint[1].y ) / 2;
		
		moveX = (currentCentreX - previousCentreX) / _scale;
		moveY = (currentCentreY - previousCentreY) / _scale;
		
    }

//	tx = _translateX * _orientationVector.vx - _translateY * _orientationVector.vy;
//	ty = _translateX * _orientationVector.vy + _translateY * _orientationVector.vx;
	
	if ( _enabled ) {
		if ( moveX != 0.0f || moveY != 0.0f ) {
			_translationX += ( moveX * _orientationVectorX - moveY * _orientationVectorY);
			_translationY += ( moveX * _orientationVectorY + moveY * _orientationVectorX);
			translationChanged = YES;
			if ([_delegate respondsToSelector:@selector(touchableViewTranslationDidChange:)]) {
				[_delegate touchableViewTranslationDidChange:self];
			}			
		}
		
		if ( scale != 1.0f ) {
			_scale *= scale;
			if ( _scale > kTouchableViewMaximumScale ) { _scale = kTouchableViewMaximumScale; }
			if ( _scale < kTouchableViewMinimumScale ) { _scale = kTouchableViewMinimumScale; }
			scaleChanged = YES;
			if ([_delegate respondsToSelector:@selector(touchableViewScaleDidChange:)]) {
				[_delegate touchableViewScaleDidChange:self];
			}			
		}
		
		if ( translationChanged || scaleChanged ) {
			if ([_delegate respondsToSelector:@selector(touchableViewDidChange:)]) {
				[_delegate touchableViewDidChange:self];
			}				
		}
	}
	
	// previous becomes current
	for ( i = 0; i < count; i++ ) {
		CFDictionarySetValue(
			_previousTouchLocationDictionary, 
			keys[i], 
			CFDictionaryGetValue(_currentTouchLocationDictionary, keys[i])
		);
	}	

	free (values);
	free (keys);
	free (currentTouchPoint);
	free (previousTouchPoint);
	[self.nextResponder touchesMoved:touches withEvent:event];
	if ([_delegate respondsToSelector:@selector(touchableViewTouchesMoved:withEvent:)]) {
		[_delegate touchableViewTouchesMoved:touches withEvent:event];
	}				
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint initialTouchLocation;
	CGPoint currentTouchLocation;
	
	// update coordinates in dictionary
	[self updateCurrentToucheLocationDictionaryWithTouches:touches];
	
	if ( CFDictionaryGetCount(_currentTouchLocationDictionary) == 1 ) {
		// handle a single or double tap or swipe
		UITouch *touch = [[touches allObjects] objectAtIndex:0];
		
		// check it hasn't moved too much		
		CGPointMakeWithDictionaryRepresentation( 
			CFDictionaryGetValue(_initialTouchLocationDictionary, touch),
			&initialTouchLocation
		);
		
		currentTouchLocation = [touch locationInView:self];
		
		CGFloat distance = CGPointDistanceBetween(initialTouchLocation, currentTouchLocation);
		
		if ( distance < kMinimumDragDistance ) {
			// test for single or double tap
			switch ( [touch tapCount] ) {
				case 1:
					[self invalidateTapTimer];
					_tapTimer = [NSTimer 
						scheduledTimerWithTimeInterval:0.25 
						target:self 
						selector:@selector(singleTap:) 
						userInfo:nil 
						repeats:NO
					];
					[_tapTimer retain];
					break;
				case 2:
					[self invalidateTapTimer];
					_tapTimer = [NSTimer 
						scheduledTimerWithTimeInterval:0.15 
						target:self 
						selector:@selector(doubleTap:) 
						userInfo:nil 
						repeats:NO
					];
					[_tapTimer retain];
					break;
				default:
					[self invalidateTapTimer];
					break;
			}
		}
		else {
			// test for swipe
			NSTimeInterval touchTime = [touch timestamp];
			double upTime = getUpTime();

			if ( upTime - touchTime < kSwipeMinimumTimeInSeconds ) {				
				CGFloat distanceX = fabs(initialTouchLocation.x - currentTouchLocation.x);
				CGFloat distanceY = fabs(initialTouchLocation.y - currentTouchLocation.y);
				if ((distanceX >= kSwipeMinimumDistanceX) && (distanceY <= kSwipeMinimumDistanceY)) {
					NSLog(@"SWIPE");
					if ( initialTouchLocation.x < currentTouchLocation.x ) {
						[self handleSwipe:kSwipeDirectionLeft];
					}
					else {
						[self handleSwipe:kSwipeDirectionRight];
					}
				}
			}
		}	
	}
	
	// bin the touch from the dictionary
	for (UITouch *touch in touches){
		CFDictionaryRemoveValue(_currentTouchLocationDictionary, touch);
		CFDictionaryRemoveValue(_previousTouchLocationDictionary, touch);		
	}
	[self.nextResponder touchesEnded:touches withEvent:event];
	if ([_delegate respondsToSelector:@selector(touchableViewTouchesEnded:withEvent:)]) {
		[_delegate touchableViewTouchesEnded:touches withEvent:event];
	}				
	if ( CFDictionaryGetCount(_currentTouchLocationDictionary) == 0 ) {
		if ([_delegate respondsToSelector:@selector(touchableViewTrackingTouchesEnded:)]) {
			[_delegate touchableViewTrackingTouchesEnded:self];
		}				
	}
}

- (void)singleTap: (NSTimer*)timer {
    // must override
	NSLog(@"singleTap event");
	if ([_delegate respondsToSelector:@selector(touchableViewSingleTap:)]) {
		[_delegate touchableViewSingleTap:self];
	}			
}

- (void)doubleTap: (NSTimer*)timer {
    // must override
	NSLog(@"doubleTap event");
	
	_scale = 1.0f;
	_translationX = 0;
	_translationY = 0;
	[self setNeedsDisplay];
	if ([_delegate respondsToSelector:@selector(touchableViewDoubleTap:)]) {
		[_delegate touchableViewDoubleTap:self];
	}			
}


- (void)handleSwipe: (SwipeDirection) direction 
{
	if ([_delegate respondsToSelector:@selector(touchableViewSwipe:direction:)]) {
		[_delegate touchableViewSwipe:self direction:direction];
	}			
}

-(void)reset
{
	[self setTranslationX:0.0f translationY:0.0f scale:1.0f];
}

-(void)setTranslationX:(float)translationX translationY:(float)translationY scale:(float)scale
{
	BOOL translationChanged = NO;
	BOOL scaleChanged = NO;
	
	DLog(@"setTranslationX:%f translationY:%f scale:%f",translationX,translationY,scale);
	
	if ( _translationX != translationX || _translationY != translationY ) {
		_translationX = translationX;
		_translationY = translationY;
		translationChanged = YES;
		if ([_delegate respondsToSelector:@selector(touchableViewTranslationDidChange:)]) {
			[_delegate touchableViewTranslationDidChange:self];
		}			
	}
	
	if ( _scale != scale ) {
		_scale = scale;
		scaleChanged = YES;
		if ([_delegate respondsToSelector:@selector(touchableViewScaleDidChange:)]) {
			[_delegate touchableViewScaleDidChange:self];
		}			
	}
	
	if ( translationChanged || scaleChanged ) {
		if ([_delegate respondsToSelector:@selector(touchableViewDidChange:)]) {
			[_delegate touchableViewDidChange:self];
		}				
	}
}
/*
- (void)setScale:(float)value
{
	if ( _scale != value ) {
		_scale = value;
		if ([_delegate respondsToSelector:@selector(touchableViewScaleDidChange:)]) {
			[_delegate touchableViewScaleDidChange:self];
		}				
		if ([_delegate respondsToSelector:@selector(touchableViewDidChange:)]) {
			[_delegate touchableViewDidChange:self];
		}				
	}
}

- (void)setTranslationX:(float)value
{
	if ( _translationX != value ) {
		_translationX = value;
		if ([_delegate respondsToSelector:@selector(touchableViewTranslationDidChange:)]) {
			[_delegate touchableViewTranslationDidChange:self];
		}			
		if ([_delegate respondsToSelector:@selector(touchableViewDidChange:)]) {
			[_delegate touchableViewDidChange:self];
		}				
	}
}

- (void)setTranslationY:(float)value
{
	if ( _translationY != value ) {
		_translationY = value;
		if ([_delegate respondsToSelector:@selector(touchableViewTranslationDidChange:)]) {
			[_delegate touchableViewTranslationDidChange:self];
		}			
		if ([_delegate respondsToSelector:@selector(touchableViewDidChange:)]) {
			[_delegate touchableViewDidChange:self];
		}				
	}
}
*/
@end

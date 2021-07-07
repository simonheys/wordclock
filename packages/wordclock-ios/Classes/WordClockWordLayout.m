//
//  WordClockWordLayout.m
//  iphone_word_clock_open_gl
//
//  Created by Simon on 14/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WordClockWordLayout.h"


// NOTE: Code to build sine table not included in this excerpt.

NSString *const kWordClockWordLayoutTargetScaleAndTranslateDidChangeNotification = @"kWordClockWordLayoutTargetScaleAndTranslateDidChangeNotification";
NSString *const kWordClockWordLayoutTargetOrientationVectorDidChangeNotification = @"kWordClockWordLayoutTargetOrientationVectorDidChangeNotification";

static const int kAccelerometerFrequency = 25; //Hz
static const float kFilteringFactor = 0.1;
static const float kMinEraseInterval = 1.0f;
static const float kEraseAccelerationThreshold = 3.0;

#define MIN4(x,y,z,w) ((x)<(y)?((x)<(z)?((x)<(w)?(x):(w)):((w)<(z)?(w):(z))):\
                       ((y)<(z)?((y)<(w)?(y):(w)):((z)<(w)?(z):(w))))
					   
#define MAX4(x,y,z,w) ((x)>(y)?((x)>(z)?((x)>(w)?(x):(w)):((w)>(z)?(w):(z))):\
                       ((y)>(z)?((y)>(w)?(y):(w)):((z)>(w)?(z):(w))))

@implementation WordClockWordLayout

- (void)dealloc
{
	[_linear release];
	[_rotary release];
	if ( _tweenSnapshotCoordinateProvider ) {
		[_tweenSnapshotCoordinateProvider release];
	}
	UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer]; 
	if ( [accelerometer.delegate isEqual:self] ) {
		accelerometer.delegate = nil;
	}
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		buildSinAndCosTables();
		
		_rotary = [[RotaryCoordinateProvider alloc] init];
		_linear = [[LinearCoordinateProvider alloc] init];

		// TODO change this to use time-based tween;
		
		[[NSNotificationCenter defaultCenter] 
			 addObserver:self
			 selector:@selector(linearSelected:)
			 name:kWordClockViewControlsLinearSelected 
			 object:nil
		];
		
		[[NSNotificationCenter defaultCenter] 
			 addObserver:self
			 selector:@selector(rotarySelected:)
			 name:kWordClockViewControlsRotarySelected 
			 object:nil
		];
		
		_linearTranslateX = [WordClockPreferences sharedInstance].linearTranslateX;
		_linearTranslateY = [WordClockPreferences sharedInstance].linearTranslateY;
		_linearScale = [WordClockPreferences sharedInstance].linearScale;
		_rotaryTranslateX = [WordClockPreferences sharedInstance].rotaryTranslateX;
		_rotaryTranslateY = [WordClockPreferences sharedInstance].rotaryTranslateY;
		_rotaryScale = [WordClockPreferences sharedInstance].rotaryScale;
		
		_currentOrientation = [[UIDevice currentDevice] orientation];
		_needsOrientationUpdateNotification = NO;

		switch ( [WordClockPreferences sharedInstance].style  ) {
			case WCStyleLinear:
				_isLinearSelected = YES;
				_translateX = _linearTranslateX;
				_translateY = _linearTranslateY;
				_scale = _linearScale;
				break;
			case WCStyleRotary:
				_isLinearSelected = NO;
				_translateX = _rotaryTranslateX;
				_translateY = _rotaryTranslateY;
				_scale = _rotaryScale;
				break;
		}
		
//		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//		
//		[[NSNotificationCenter defaultCenter] 
//			addObserver:self
//			selector:@selector(deviceOrientationDidChange:)
//			name:@"UIDeviceOrientationDidChangeNotification" 
//			object:nil
//		];
		
		_lastShakeTime = 0;
		_accelerometerValues[0] = 0;
		_accelerometerValues[1] = 0;
		_accelerometerValues[2] = 0;
		
		UIAccelerometer* accelerometer = [UIAccelerometer sharedAccelerometer]; 
		accelerometer.updateInterval = 1.0 / kAccelerometerFrequency;
		accelerometer.delegate = self;

		_isTweening = NO;
		_transitionTweenValue = 0.0f;
	}
	return self;
}

// ____________________________________________________________________________________________________ shake

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	UIAccelerationValue length, x, y, z;
	_accelerometerValues[0] = acceleration.x * kFilteringFactor + _accelerometerValues[0] * (1.0 - kFilteringFactor);
	_accelerometerValues[1] = acceleration.y * kFilteringFactor + _accelerometerValues[1] * (1.0 - kFilteringFactor);
	_accelerometerValues[2] = acceleration.z * kFilteringFactor + _accelerometerValues[2] * (1.0 - kFilteringFactor);
	x = acceleration.x - _accelerometerValues[0];
	y = acceleration.y - _accelerometerValues[0];
	z = acceleration.z - _accelerometerValues[0];
	length = sqrt(x * x + y * y + z * z);
  
	if((length >= kEraseAccelerationThreshold)
      && (CFAbsoluteTimeGetCurrent() > _lastShakeTime + kMinEraseInterval)) {
		_lastShakeTime = CFAbsoluteTimeGetCurrent();

 		[self shake];
	}
}

- (void)shake
{
	if ( _isLinearSelected ) {
		[_linear shake];
		[self tweenFromCoordinateProvider:_linear duration:1.0f];
	}
	else {
		[_rotary shake];
		[self tweenFromCoordinateProvider:_rotary duration:1.0f];	
	}
	
}

// ____________________________________________________________________________________________________ orientation

- (void)setSize:(CGSize)size
{
    if ( CGSizeEqualToSize(size, _size)) {
        return;
    }
    _size = size;
    _linear.size = size;
    _rotary.size = size;
}


- (void)setTranslateX:(GLfloat)value
{
	if ( _isLinearSelected ) {
		_linearTranslateX = value;
		_linear.translateX = value;
	}
	else {
		_rotaryTranslateX = value;	
		_rotary.translateX = value;
	}
	_translateX = value;
}

- (void)setTranslateY:(GLfloat)value
{
	if ( _isLinearSelected ) {
		_linearTranslateY = value;
		_linear.translateY = value;
	}
	else {
		_rotaryTranslateY = value;	
		_rotary.translateY = value;
	}
	_translateY = value;
}

- (void)setScale:(GLfloat)value
{
	if ( _isLinearSelected ) {
		_linearScale = value;
		_linear.scale = value;
	}
	else {
		_rotaryScale = value;	
		_rotary.scale = value;
	}
	_scale = value;
}

- (float)getTargetScale
{
	if ( _isLinearSelected ) {
		return _linear.scale;
	}
	else {
		return _rotary.scale;	
	}
}

- (float)getTargetTranslateX
{
	if ( _isLinearSelected ) {
		return _linear.translateX;
	}
	else {
		return _rotary.translateX;	
	}
}

- (float)getTargetTranslateY
{
	if ( _isLinearSelected ) {
		return _linear.translateY;
	}
	else {
		return _rotary.translateY;	
	}
}

// TODO optimise; use notification when this changes

- (WordClockOrientationVector)getTargetOrientationVector
{
	if ( _isLinearSelected ) {
		return _linear.orientationVector;
	}
	else {
		return _rotary.orientationVector;	
	}
}

- (void)tweenFromCoordinateProvider:(CoordinateProvider *)target reverse:(BOOL)reverse {
//	self.tweenSnapshotCoordinateProvider = [target clone];
	if ( _tweenSnapshotCoordinateProvider ) {
		[_tweenSnapshotCoordinateProvider release];
	}
	_tweenSnapshotCoordinateProvider = [[target clone] retain];
	_isTweening = YES;
	
	/*
	self.transitionTweenValue = 0.0f;
	
	if ( _transitionTween ) {
		[_transitionTween cancel];
	}
	_transitionTween = [[Tween alloc] 
		initWithTarget:self 
		keyPath:@"transitionTweenValue" 
		toFloatValue:1.0f 
		delay:0.0f 
		duration:duration
		ease:kTweenQuadEaseInOut
		onComplete:@selector(transitionTweenComplete:)
		onCompleteTarget:self
	];
	
	[_transitionTween retain];
    */

	uint numberOfWords = [WordClockWordManager sharedInstance].numberOfWords;
    WordClockWord *word;
    float delay;
    float duration;
    
    for ( uint i = 0; i < numberOfWords; i++ ) {
        word = [[WordClockWordManager sharedInstance].word objectAtIndex:reverse ? (numberOfWords-1-i) : i];
        [[TweenManager sharedInstance] removeTweensWithTarget:word andKeyPath:@"tweenValue"];
        word.tweenValue = 0.0f;

//        switch ( [WordClockPreferences sharedInstance].transitionStyle ) {
//            case WCTransitionStyleSlow:
//                duration = 2.0f;
//                delay = i * quad_ease_out((float)i/numberOfWords) * 1 / 60.0f; 
//                break;
//            case WCTransitionStyleMedium:
//                duration = 2.0f;
//                delay = i * quad_ease_out((float)i/numberOfWords) * 1 / 180.0f; 
//                break;
//            case WCTransitionStyleFast:
//                duration = 1.5f;
//                delay = 0.0f;
//                break;                
//        }
                duration = 2.0f;
                delay = i * quad_ease_out((float)i/numberOfWords) * 1 / 180.0f; 

        if ( i == numberOfWords-1 ) {
            [Tween 
                tweenWithTarget:word 
                keyPath:@"tweenValue" 
                toFloatValue:1.0f 
                delay:delay 
                duration:duration 
                ease:kTweenQuadEaseInOut
                onComplete:@selector(transitionTweenComplete:)
                onCompleteTarget:self
            ];
        
        }
        else {
            [Tween 
                tweenWithTarget:word 
                keyPath:@"tweenValue" 
                toFloatValue:1.0f 
                delay:delay 
                duration:duration 
                ease:kTweenQuadEaseInOut
            ];
        }
    }
}

- (void)__tweenFromCoordinateProvider:(CoordinateProvider *)target duration:(float)duration
{
	if ( _tweenSnapshotCoordinateProvider ) {
		[_tweenSnapshotCoordinateProvider release];
	}
	_tweenSnapshotCoordinateProvider = [[target clone] retain];
	_isTweening = YES;
		
	self.transitionTweenValue = 0.0f;
	
	if ( _transitionTween ) {
		[_transitionTween cancel];
	}
	_transitionTween = [Tween 
        tweenWithTarget:self 
		keyPath:@"transitionTweenValue"
		toFloatValue:1.0f 
		delay:0.0f 
		duration:duration
		ease:kTweenQuadEaseInOut
		onComplete:@selector(transitionTweenComplete:)
		onCompleteTarget:self
	];
	
	[_transitionTween retain];
}

- (void)transitionTweenComplete:(Tween *)tween
{
	DLog(@"transitionTweenComplete");
	_isTweening = NO;
}

- (void)linearSelected:(id)sender
{
	DLog(@"linearSelected");
	_isLinearSelected = YES;
	[WordClockPreferences sharedInstance].style = WCStyleLinear;
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:kWordClockWordLayoutTargetScaleAndTranslateDidChangeNotification 
		object:self
	];
	_needsOrientationUpdateNotification = YES;
//	[self tweenFromCoordinateProvider:_rotary duration:2.0f];
	[self tweenFromCoordinateProvider:_rotary reverse:YES];

}

- (void)rotarySelected:(id)sender
{
	DLog(@"rotarySelected");
	_isLinearSelected = NO;
	[WordClockPreferences sharedInstance].style = WCStyleRotary;
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:kWordClockWordLayoutTargetScaleAndTranslateDidChangeNotification 
		object:self
	];
	_needsOrientationUpdateNotification = YES;
//	[self tweenFromCoordinateProvider:_linear duration:2.0f];
	[self tweenFromCoordinateProvider:_linear reverse:NO];
}

- (void)update
{
	GLfloat	width, height;
	
	GLfloat vx, vy;
	GLfloat ox, oy;
	GLfloat wvx;
	GLfloat wvy;
	GLfloat hvx;
	GLfloat hvy;
	
	float a;
	float m;
	
	CoordinateProvider *tweenFrom, *tweenTo, *current;

	if ( _isLinearSelected ) {
		[_linear update];
	}
	else {
		[_rotary update];
	}
		
	if ( _isTweening) {
		tweenFrom = _tweenSnapshotCoordinateProvider;
		m = self.transitionTweenValue;
		
//		m = quad_ease_in_out( _tweenTime / kTweenTimeMaximum );
//		DLog(@"transitionTweenValue:%f",self.transitionTweenValue);
//		printf("transitionTweenValue:%f",0.5f);
		if ( _isLinearSelected ) {			
//			tweenFrom = _rotary;
			tweenTo = _linear;
		}
		else {			
//			tweenFrom = _linear;
			tweenTo = _rotary;			
		}
	} else {
		if ( _isLinearSelected ) {
			current = _linear;
		}
		else {
			current = _rotary;
		}
	}
	
	//GLfloat *offset = _vertices;
	
	uint offset = 0;
	//uint cullingoffset = 0;
	uint numberOfWords = [WordClockWordManager sharedInstance].numberOfWords;
	
	float xtl;// = ox;
	float xtr;// = ox + wvx;
	float xbl;// = ox - hvy;
	float xbr;// = ox + wvx - hvy;
	float ytl;// = oy;
	float ytr;// = oy + wvy;
	float ybl;// = oy + hvx;
	float ybr;// = oy + wvy + hvx;
	
    WordClockWord *word;

	// TODO inform touchableView of the current vector orientation

	if ( _isTweening) {	
//		DLog(@"transitionTweenValue:%f",_transitionTweenValue);
		for ( uint i = 0; i < numberOfWords; i++ ) {
//			a = tweenFrom.coordinates[i].r+m*(tweenTo.coordinates[i].r-tweenFrom.coordinates[i].r);
            word = [[WordClockWordManager sharedInstance].word objectAtIndex:i];
            m = word.tweenValue;
                
			a = tweenFrom.coordinates[i].r+m*(tweenTo.coordinates[i].r-tweenFrom.coordinates[i].r);
						
			vx = getCosFromTable(a);
			vy = -getSinFromTable(a);

			width = tweenFrom.coordinates[i].w+m*(tweenTo.coordinates[i].w-tweenFrom.coordinates[i].w);
			height = tweenFrom.coordinates[i].h+m*(tweenTo.coordinates[i].h-tweenFrom.coordinates[i].h); 
			
			ox = tweenFrom.coordinates[i].x+m*(tweenTo.coordinates[i].x-tweenFrom.coordinates[i].x);
			oy = tweenFrom.coordinates[i].y+m*(tweenTo.coordinates[i].y-tweenFrom.coordinates[i].y);

			wvx = width * vx;
			wvy = width * vy;
			hvx = height * vx;
			hvy = height * vy;
			
			xtl = ox;
			xtr = ox + wvx;
			xbl = ox - hvy;
			xbr = ox + wvx - hvy;
			ytl = oy;
			ytr = oy + wvy;
			ybl = oy + hvx;
			ybr = oy + wvy + hvx;			
			
			// top left
			_vertices[offset++] = xtl;
			_vertices[offset++] = ytl;
			// top right
			_vertices[offset++] = xtr;
			_vertices[offset++] = ytr;
			// bottom left
			_vertices[offset++] = xbl;
			_vertices[offset++] = ybl;
			// bottom right
			_vertices[offset++] = xbr;
			_vertices[offset++] = ybr;

#ifdef ENABLE_CULL
			// printf("cull");
			width = tweenFrom.coordinates[i].w_bounds+m*(tweenTo.coordinates[i].w_bounds-tweenFrom.coordinates[i].w_bounds);
			height = tweenFrom.coordinates[i].h_bounds+m*(tweenTo.coordinates[i].h_bounds-tweenFrom.coordinates[i].h_bounds); 
			
			wvx = width * vx;
			wvy = width * vy;
			hvx = height * vx;
			hvy = height * vy;
			
			xtl = ox;
			xtr = ox + wvx;
			xbl = ox - hvy;
			xbr = ox + wvx - hvy;
			ytl = oy;
			ytr = oy + wvy;
			ybl = oy + hvx;
			ybr = oy + wvy + hvx;			
			
			_rectsForCulling[i].i = i;

			_rectsForCulling[i].xl = MIN4(xtl, xtr, xbl, xbr);
			_rectsForCulling[i].xr = MAX4(xtl, xtr, xbl, xbr);
			_rectsForCulling[i].yt = MIN4(ytl, ytr, ybl, ybr);
			_rectsForCulling[i].yb = MAX4(ytl, ytr, ybl, ybr);
#endif
		}
		/*
		if ( _tweenTime < kTweenTimeMaximum ) {
			_tweenTime += 0.01f;
		}
		else {
			_tweenTime = kTweenTimeMaximum;
			_isTweening = NO;
		}
		*/
	}
	else {
		for ( uint i = 0; i < numberOfWords; i++ ) {
			a = current.coordinates[i].r;
			
			vx = getCosFromTable(a);
			vy = -getSinFromTable(a);
			
			width = current.coordinates[i].w;
			height = current.coordinates[i].h; 
			
			ox = current.coordinates[i].x;
			oy = current.coordinates[i].y;
			
			wvx = width * vx;
			wvy = width * vy;
			hvx = height * vx;
			hvy = height * vy;
			
			xtl = ox;
			xtr = ox + wvx;
			xbl = ox - hvy;
			xbr = ox + wvx - hvy;
			ytl = oy;
			ytr = oy + wvy;
			ybl = oy + hvx;
			ybr = oy + wvy + hvx;			
			
			// top left
			_vertices[offset++] = xtl;
			_vertices[offset++] = ytl;
			// top right
			_vertices[offset++] = xtr;
			_vertices[offset++] = ytr;
			// bottom left
			_vertices[offset++] = xbl;
			_vertices[offset++] = ybl;
			// bottom right
			_vertices[offset++] = xbr;
			_vertices[offset++] = ybr;
			
#ifdef ENABLE_CULL
			width = current.coordinates[i].w_bounds;//+m*(tweenTo.coordinates[i].w_bounds-tweenFrom.coordinates[i].w_bounds);
			height = current.coordinates[i].h_bounds;//+m*(tweenTo.coordinates[i].h_bounds-tweenFrom.coordinates[i].h_bounds); 
			
			wvx = width * vx;
			wvy = width * vy;
			hvx = height * vx;
			hvy = height * vy;
			
			xtl = ox;
			xtr = ox + wvx;
			xbl = ox - hvy;
			xbr = ox + wvx - hvy;
			ytl = oy;
			ytr = oy + wvy;
			ybl = oy + hvx;
			ybr = oy + wvy + hvx;			
			
			_rectsForCulling[i].i = i;

			_rectsForCulling[i].xl = MIN4(xtl, xtr, xbl, xbr);
			_rectsForCulling[i].xr = MAX4(xtl, xtr, xbl, xbr);
			_rectsForCulling[i].yt = MIN4(ytl, ytr, ybl, ybr);
			_rectsForCulling[i].yb = MAX4(ytl, ytr, ybl, ybr);
#endif
		}		
	}
}



- (float)getLayoutWordScale
{
	if ( _isLinearSelected ) {
		return _linear.wordScale;
	}
	else {
		return 1.0f;
	}
}
@end

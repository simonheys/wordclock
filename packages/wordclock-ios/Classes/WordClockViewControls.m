//
//  WordClockViewControls.m
//  iphone_word_clock_open_gl
//
//  Created by Simon on 21/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WordClockViewControls.h"

NSString *const kWordClockViewControlsConfigSelected = @"kWordClockViewControlsConfigSelected";
NSString *const kWordClockViewControlsLinearSelected = @"kWordClockViewControlsLinearSelected";
NSString *const kWordClockViewControlsRotarySelected = @"kWordClockViewControlsRotarySelected";

@interface WordClockViewControls (WordClockViewControlsPrivate)
- (void)setShowing:(BOOL)b;
- (void)setState:(WordClockViewControlsState)newState;
- (void)resetBecomeHiddenTimer;
- (void)layoutForCurrentOrientation;
@end


@implementation WordClockViewControls

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.opaque = NO;
						
		_toolbar = [[UIToolbar alloc] init];
		[_toolbar sizeToFit];
		
        CGFloat toolbarHeight = [_toolbar frame].size.height;
		[_toolbar setFrame:CGRectMake(0, self.bounds.size.height-toolbarHeight, self.bounds.size.width, toolbarHeight)];
		[_toolbar setBarStyle:UIBarStyleBlackTranslucent];
		
		self.enabled = [WordClockPreferences sharedInstance].locked;

		_lockButton = [[UIBarButtonItem alloc] 
			initWithImage:[UIImage imageNamed: self.enabled ? @"padlock_open.png" : @"padlock_closed.png"] 
			style:UIBarButtonItemStylePlain 
			target:self 
			action:@selector(padlockSelected:)
		];
		
		_resetButton = [[UIBarButtonItem alloc] 
			initWithImage:[UIImage imageNamed:@"reset.png"] 
			style:UIBarButtonItemStylePlain 
			target:self 
			action:@selector(resetSelected:)
		];
		
		_linearOrRotaryButton = [[UIBarButtonItem alloc] 
			initWithImage:[UIImage imageNamed:[WordClockPreferences sharedInstance].style == WCStyleLinear ? @"linear_selected.png" : @"rotary_selected.png"] 
			style:UIBarButtonItemStylePlain 
			target:self 
			action:@selector(linearOrRotarySelected:)
		];
		
		
		UIBarButtonItem	*flexibleSpace = [[UIBarButtonItem alloc]
			initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
			target:nil 
			action:nil
		];
		
		UIBarButtonItem *configButton = [[UIBarButtonItem alloc]
			initWithImage:[UIImage imageNamed:@"gear.png"] 
			style:UIBarButtonItemStylePlain 
			target:self 
			action:@selector(configSelected:)
		];
		
		[_toolbar setItems:[NSArray arrayWithObjects:
			_lockButton,
			_resetButton,
			flexibleSpace,
//			[[UIBarButtonItem alloc] initWithCustomView:_segmentedControl],
			_linearOrRotaryButton,
			flexibleSpace,
			configButton,
			nil
		]];

		_resetButton.enabled = self.enabled;	
		[self addSubview:_toolbar];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		
		_state = kWordClockViewControlsHiddenState;
		_isCurrentTouchAcceptable = NO;
		
		// listen for scale / translate changes
		[[NSNotificationCenter defaultCenter] 
			addObserver:self
			selector:@selector(layoutTargetScaleAndTranslateChanged:)
			name:kWordClockWordLayoutTargetScaleAndTranslateDidChangeNotification 
			object:nil
		];

		// TODO we nee some kind of shared model for the view state
		// this appears in about 4 places
		switch ( [WordClockPreferences sharedInstance].style  ) {
			case WCStyleLinear:
				self.translationX = [WordClockPreferences sharedInstance].linearTranslateX;
				self.translationY = [WordClockPreferences sharedInstance].linearTranslateY;
				self.scale = [WordClockPreferences sharedInstance].linearScale;
				break;
			case WCStyleRotary:
				self.translationX = [WordClockPreferences sharedInstance].rotaryTranslateX;
				self.translationY = [WordClockPreferences sharedInstance].rotaryTranslateY;
				self.scale = [WordClockPreferences sharedInstance].rotaryScale;
				break;
		}

        [_toolbar setTransform: CGAffineTransformMakeTranslation(0, _toolbar.frame.size.height)];
   }
    return self;
}

// ____________________________________________________________________________________________________ orientation


- (void)layoutTargetScaleAndTranslateChanged:(NSNotification *)notification
{
	self.scale = [(WordClockWordLayout *)[notification object] getTargetScale];
	self.translationX = [(WordClockWordLayout *)[notification object] getTargetTranslateX];
	self.translationY = [(WordClockWordLayout *)[notification object] getTargetTranslateY];
//	DLog(@"layoutTargetScaleAndTranslateChanged: scale:%f tx:%f ty:%f",self.scale,self.translationX,self.translationY);
	
}

- (void)layoutTargetOrientationVectorChanged:(NSNotification *)notification
{
//	self.scale = [(WordClockWordLayout *)[notification object] getTargetScale];
//	self.translationX = [(WordClockWordLayout *)[notification object] getTargetTranslateX];
//	self.translationY = [(WordClockWordLayout *)[notification object] getTargetTranslateY];
	DLog(@"layoutTargetOrientationVectorChanged: vx:%f vy:%f",
		[(WordClockWordLayout *)[notification object] getTargetOrientationVector].vx,
		[(WordClockWordLayout *)[notification object] getTargetOrientationVector].vy
	);
	
	self.orientationVectorX = [(WordClockWordLayout *)[notification object] getTargetOrientationVector].vx;
	self.orientationVectorY = [(WordClockWordLayout *)[notification object] getTargetOrientationVector].vy;
	
	
}

- (void)invalidateStatusTimer
{
    if([_statusTimer isValid])
	{
        [_statusTimer invalidate];
	}
	//[_statusTimer release];
}


-(IBAction)linearOrRotarySelected:(id)sender
{
	DLog(@"linearOrRotarySelected");
	if ( [WordClockPreferences sharedInstance].style == WCStyleLinear ) {
		_linearOrRotaryButton.image = [UIImage imageNamed:@"rotary_selected.png"];
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:kWordClockViewControlsRotarySelected 
		 object:self
		 ];

	}
	else {
		_linearOrRotaryButton.image = [UIImage imageNamed:@"linear_selected.png"];
		[[NSNotificationCenter defaultCenter] 
		 postNotificationName:kWordClockViewControlsLinearSelected 
		 object:self
		 ];
	
	}

	// notify that values will now be different
	if ([_delegate respondsToSelector:@selector(touchableViewDidChange:)]) {
		[_delegate touchableViewDidChange:self];
	}				
	
	[self resetBecomeHiddenTimer];
}

- (void)doubleTap: (NSTimer*)timer
{
	DLog(@"DOUBLE TAP");
	/*
	int currentSelectedSegmentIndex = _segmentedControl.selectedSegmentIndex;
currentSelectedSegmentIndex = 1-currentSelectedSegmentIndex;
	[_segmentedControl setSelectedSegmentIndex:currentSelectedSegmentIndex];
	[self segmentedControlChanged:self];
	*/
	[self linearOrRotarySelected:self];
}


- (void)resetBecomeHiddenTimer
{
	[self invalidateStatusTimer];
	if (_statusTimer) {
		[_statusTimer release];
	}
	_statusTimer = [NSTimer 
		scheduledTimerWithTimeInterval:5.0f 
		target:self 
		selector:@selector(handleBecomeHidden:) 
		userInfo:nil 
		repeats:NO
	];
	[_statusTimer retain];
}



-(IBAction)configSelected:(id)sender
{
	DLog(@"configSelected");
	[self invalidateStatusTimer];
	[self setState:kWordClockViewControlsPreparingToFlipState];
}

-(IBAction)padlockSelected:(id)sender
{
	DLog(@"padlockSelected");
	self.enabled = !self.enabled;
	[WordClockPreferences sharedInstance].locked = self.enabled;
	if ( self.enabled ) {
		_lockButton.image = [UIImage imageNamed:@"padlock_open.png"];
		_resetButton.enabled = YES;	
	}
	else {
		_lockButton.image = [UIImage imageNamed:@"padlock_closed.png"];	
		_resetButton.enabled = NO;	
	}
	[self resetBecomeHiddenTimer];
}

-(IBAction)resetSelected:(id)sender
{
	DLog(@"resetSelected");
//	[self reset];
//	Tween *_scaleTween;
//	Tween *_translateXTween;
//	Tween *_translateYTween;
	
	float targetScale;
	float targetTranslationX;
	float targetTranslationY;
	
	switch ( [WordClockPreferences sharedInstance].style  ) {
		case WCStyleLinear:
			targetTranslationX = [[WordClockPreferences factoryDefaults] floatForKey:WCLinearTranslateXKey];
			targetTranslationY = [[WordClockPreferences factoryDefaults] floatForKey:WCLinearTranslateYKey];
			targetScale = [[WordClockPreferences factoryDefaults] floatForKey:WCLinearScaleKey];
			break;
		case WCStyleRotary:
			targetTranslationX = [[WordClockPreferences factoryDefaults] floatForKey:WCRotaryTranslateXKey];
			targetTranslationY = [[WordClockPreferences factoryDefaults] floatForKey:WCRotaryTranslateYKey];
			targetScale = [[WordClockPreferences factoryDefaults] floatForKey:WCRotaryScaleKey];
			break;
	}
	/*
	_scaleTween = [[Tween alloc] 
		initWithTarget:self 
		keyPath:@"scale" 
		toFloatValue:targetScale 
		delay:0.0f 
		duration:0.5f
		ease:kTweenQuadEaseOut
	];
	_translateXTween = [[Tween alloc] 
		initWithTarget:self 
		keyPath:@"translationX" 
		toFloatValue:targetTranslationX 
		delay:0.0f 
		duration:0.5f
		ease:kTweenQuadEaseOut
	];
	_translateYTween = [[Tween alloc] 
		initWithTarget:self 
		keyPath:@"translationY" 
		toFloatValue:targetTranslationY 
		delay:0.0f 
		duration:0.5f
		ease:kTweenQuadEaseOut
	];
	*/
	[self setTranslationX:targetTranslationX translationY:targetTranslationY scale:targetScale];
	switch ( [WordClockPreferences sharedInstance].style  ) {
		case WCStyleLinear:
			[WordClockPreferences sharedInstance].linearTranslateX = targetTranslationX;
			[WordClockPreferences sharedInstance].linearTranslateY = targetTranslationY;
			[WordClockPreferences sharedInstance].linearScale = targetScale;
			break;
		case WCStyleRotary:
			[WordClockPreferences sharedInstance].rotaryTranslateX = targetTranslationX;
			[WordClockPreferences sharedInstance].rotaryTranslateY = targetTranslationY;
			[WordClockPreferences sharedInstance].rotaryScale = targetScale;
			break;
	}
	
//	DLog(@"default:%f",[[NSUserDefaults standardUserDefaults] floatForKey:WCRotaryTranslateXKey]);
	[self resetBecomeHiddenTimer];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}

/*

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//	DLog(@"touchesBegan");
	if ( !_isCurrentTouchAcceptable ) {
		_isCurrentTouchAcceptable = YES;
	}
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//	DLog(@"touchesMoved");
	//if ( _isCurrentTouchAcceptable ) {
		_isCurrentTouchAcceptable = NO;
	//}
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	DLog(@"touchesEnded");
    UITouch* touch = [touches anyObject];
    NSUInteger numTaps = [touch tapCount];
    if (_isCurrentTouchAcceptable && numTaps < 2) {
		[self setState:kWordClockViewControlsWaitingToBecomeVisibleState];
	}
	else {
		[self setState:kWordClockViewControlsHiddenState];		
	}
	_isCurrentTouchAcceptable = NO;
	[super touchesEnded:touches withEvent:event];
}
*/
- (void)singleTap: (NSTimer*)timer 
{
	[super singleTap:timer];
	switch ( _state ) {
		case kWordClockViewControlsHiddenState:
			[self setState:kWordClockViewControlsVisibleState];
			break;
//		case kWordClockViewControlsWaitingToBecomeVisibleState:
		case kWordClockViewControlsVisibleState:
			[self setState:kWordClockViewControlsHiddenState];

			break;
	}
}
- (void)setState:(WordClockViewControlsState)newState
{
	if ( _state == newState ) {
		return;
	}
    
	switch ( newState ) {
		case kWordClockViewControlsPreparingToFlipState:
			[UIView beginAnimations:@"appear" context:NULL];
			[UIView setAnimationDuration:0.1f];
            [_toolbar setTransform: CGAffineTransformMakeTranslation(0, _toolbar.frame.size.height)];
			[UIView commitAnimations];
			[self invalidateStatusTimer];
			_statusTimer = [NSTimer 
				scheduledTimerWithTimeInterval:0.1f 
				target:self 
				selector:@selector(handleFlipView:) 
				userInfo:nil 
				repeats:NO
			];
			[_statusTimer retain];
			break;
		case kWordClockViewControlsHiddenState:
			[self invalidateStatusTimer];
			
			[UIView beginAnimations:@"appear" context:NULL];
			[UIView setAnimationDuration:0.25];
            [_toolbar setTransform: CGAffineTransformMakeTranslation(0, _toolbar.frame.size.height)];
			[UIView commitAnimations];
			break;
			
		case kWordClockViewControlsVisibleState:
			
			[UIView beginAnimations:@"appear" context:NULL];
			[UIView setAnimationDuration:0.25];
            [_toolbar setTransform: CGAffineTransformMakeTranslation(0, 0)];
			[UIView commitAnimations];
			[self resetBecomeHiddenTimer];
			break;
			
		case kWordClockViewControlsWaitingToBecomeVisibleState:
			// set a timer
			[self invalidateStatusTimer];
			_statusTimer = [NSTimer 
				scheduledTimerWithTimeInterval:1.0f 
				target:self 
				selector:@selector(handleBecomeVisible:) 
				userInfo:nil 
				repeats:NO
			];
			[_statusTimer retain];
			
			break;
	}
	
	_state = newState;
}

-(void)handleBecomeVisible: (NSTimer*)timer
{
	if ( _state == kWordClockViewControlsWaitingToBecomeVisibleState ) {
		[self setState:kWordClockViewControlsVisibleState];
	}
}

-(void)handleBecomeHidden: (NSTimer*)timer
{
	if ( _state == kWordClockViewControlsVisibleState ) {
		[self setState:kWordClockViewControlsHiddenState];
	}
}

-(void)handleFlipView: (NSTimer*)timer
{
	if ( _state == kWordClockViewControlsPreparingToFlipState ) {
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:kWordClockViewControlsConfigSelected 
			object:self
		];
		_state = kWordClockViewControlsHiddenState;
	}
}

@end

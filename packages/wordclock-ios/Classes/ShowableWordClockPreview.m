//
//  ShowableWordClockPreview.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "ShowableWordClockPreview.h"
#import "RootViewController.h"
#import "Tween.h"

/*
@interface ShowableWordClockPreview (ShowableWordClockPreviewPrivate)
- (float)getScale;
@end
*/

@implementation ShowableWordClockPreview

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
	{
		_showing = NO;
		self.hidden = YES;
		self.alpha = 0.0f;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		_contentScale = [RootViewController getScale];
		
		_maskImage = [self createCircularMaskImageWithWidth:120*_contentScale height:120*_contentScale];
		_bufferImageRef = CreateARGBBitmapContext( 120*_contentScale, 120*_contentScale );
		_shadow = [UIImage imageNamed:@"showable_preview_shadow.png"];
		[_shadow retain];
		
		//self.clipsToBounds = NO;
		//[self setClipsToBounds:NO];
		//[self.layer setMasksToBounds:NO];//  .masksToBounds = NO;
   }
    return self;
}
- (void)invalidateStatusTimer
{
    if([_statusTimer isValid])
	{
        [_statusTimer invalidate];
	}
}

- (void)resetBecomeHiddenTimer
{
	[self invalidateStatusTimer];
	if (_statusTimer) {
		[_statusTimer release];
	}
	_statusTimer = [NSTimer 
		scheduledTimerWithTimeInterval:1.0f 
		target:self 
		selector:@selector(handleBecomeHidden:) 
		userInfo:nil 
		repeats:NO
	];
	[_statusTimer retain];
}

-(void)drawRect:(CGRect)rect 
{
	[_shadow drawAtPoint:CGPointZero];

	//draw preview in our context
	UIGraphicsPushContext(_bufferImageRef);
	[super drawRect:CGRectMake(0,0,120*_contentScale,120*_contentScale)];
	UIGraphicsPopContext();
	
	CGImageRef bufferImage=CGBitmapContextCreateImage(_bufferImageRef);
	CGImageRef maskedImage=CGImageCreateWithMask(bufferImage,_maskImage);

//	DLog(@"retain count: bufferImage:%d maskedImage:%d",CFGetRetainCount(bufferImage),CFGetRetainCount(maskedImage));

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, CGRectMake(60,60,120,120), maskedImage);

	CGImageRelease(bufferImage);
// don't release mask here; it throws an error...
	CGImageRelease(maskedImage);
}

- (void)setShowing:(BOOL)visible
{
	if ( visible == _showing ) {
		return;
	}
	
	_showing = visible;
	
	switch (_showing ) {
		case YES:
			[_visibilityTween cancel];
			[self invalidateStatusTimer];
			self.backgroundColour = [WordClockPreferences sharedInstance].backgroundColour;
			self.foregroundColour = [WordClockPreferences sharedInstance].foregroundColour;
			self.highlightColour = [WordClockPreferences sharedInstance].highlightColour;
//			[_visibilityTween release];
//			_visibilityTween = [Tween tw
//				initWithTarget:self 
//				keyPath:@"alpha" 
//				toFloatValue:1.0f 
//				delay:0.0f 
//				duration:0.1f 
//				ease:kTweenQuadEaseIn
//			];
//			[_visibilityTween retain];
            [UIView animateWithDuration:0.1f animations:^{self.alpha = 1.0f;}];
			self.hidden = NO;
			break;
		case NO:
			[self resetBecomeHiddenTimer];
			break;
	}
}

-(void)handleBecomeHidden: (NSTimer*)timer
{
	[self invalidateStatusTimer];
//	[_visibilityTween cancel];
//	[_visibilityTween release];
//	_visibilityTween = [[Tween alloc] 
//		initWithTarget:self 
//		keyPath:@"alpha" 
//		toFloatValue:0.0f 
//		delay:0.0f 
//		duration:0.25f 
//		ease:kTweenQuadEaseIn
//		onComplete:@selector(handleVisiblityTweenComplete:)
//		onCompleteTarget:self
//	];
//	[_visibilityTween retain];
    [UIView animateWithDuration:0.25f animations:^{self.alpha = 0.0f;} completion:^(BOOL finished){self.hidden=YES;}];

}

-(void)handleVisiblityTweenComplete
{
	self.hidden = YES;
}

- (void)dealloc 
{
	CGImageRelease(_maskImage);
	CGContextRelease(_bufferImageRef);
	[_visibilityTween cancel];
	[_visibilityTween retain];
	[_statusTimer release];
	[_shadow release];
    [super dealloc];
}






- (CGImageRef)createCircularMaskImageWithWidth:(int)pixelsWide height:(int)pixelsHigh
{
	CGImageRef theCGImage = NULL;
    CGContextRef maskBitmapContext = NULL;
    CGColorSpaceRef colorSpace;
	
	// Our gradient is always black-white and the mask
	// must be in the gray colorspace
    colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
    maskBitmapContext = CGBitmapContextCreate(
		NULL, 
		pixelsWide, 
		pixelsHigh,
		8, 
		0, 
		colorSpace, 
		kCGImageAlphaNone
	);
	
	// clean up the colorspace
	CGColorSpaceRelease(colorSpace);

	if (maskBitmapContext == NULL) {
        return NULL;
    }
    CGContextClearRect(maskBitmapContext, CGRectMake(0,0,pixelsWide,pixelsHigh));
    CGContextSetGrayFillColor(maskBitmapContext, 1.0f, 1.0f);
    CGContextFillEllipseInRect(maskBitmapContext, CGRectMake(0,0,pixelsWide,pixelsHigh));
    
    // convert the context into a CGImageRef and release the
    // context
    theCGImage=CGBitmapContextCreateImage(maskBitmapContext);
    CGContextRelease(maskBitmapContext);
	
	// return the imageref containing the gradient
    return theCGImage;
}


@end

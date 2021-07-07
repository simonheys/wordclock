//
//  ColourGradientSliderControl.m
//  iphone_word_clock_open_gl
//
//  Created by Simon on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ColourGradientSliderControl.h"
#import "RootViewController.h"

@interface ColourGradientSliderControl (ColourGradientSliderControlPrivate)
	- (void)customSetup;
	- (void)updateCursorPositionForTouch:(UITouch *)touch;
	- (void)updateColour;
	- (void)updateGradient;
@end

@implementation ColourGradientSliderControl

@synthesize hue = _hue;
@synthesize saturation = _saturation;
@synthesize value = _value;
@synthesize delegate = _delegate;

- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder])) {
		[self customSetup];
	}	
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self customSetup];
    }
    return self;
}

- (void)customSetup
{
	_trackImage = nil;
	
	self.backgroundColor = [UIColor clearColor];
	_stencilImage = [UIImage imageNamed:@"track_stencil.png"];
	_min = self.frame.size.height / 2;
	_max = CGRectGetMaxX(self.bounds)-_min;

	_contentScale = [RootViewController getScale];

	_cursor = [[FlipsideColourPickerCursorView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.height,self.frame.size.height)];

	[self addSubview:_cursor];
	self.hue = 0.5f;
	self.saturation = 0.5f;
	self.value = 0.5f;
}

- (void) dealloc
{
	CGImageRelease(_trackImage);
	[_stencilImage release];
	[_cursor release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(context, 1.0, -1.0);  
	CGContextDrawImage(context,CGRectMake(0.5f*(self.frame.size.width-_stencilImage.size.width),-23,_stencilImage.size.width,_stencilImage.size.height),_trackImage);	
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self updateCursorPositionForTouch:touch];
	return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{

}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self updateCursorPositionForTouch:touch];
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self updateCursorPositionForTouch:touch];
}

- (void)updateCursorPositionForTouch:(UITouch *)touch
{
	CGPoint currentTouchLocation = [touch locationInView:self];
	float x = currentTouchLocation.x;
	if ( x < _min ) { x = _min; }
	if ( x > _max ) {
		x = _max;
	}
	float newValue = (x-_min) / (_max-_min);
	if ( _value != newValue ) {
		self.value = newValue;
		if ([_delegate respondsToSelector:@selector(colourGradientSliderControlValueDidChange:)]) {
			[_delegate colourGradientSliderControlValueDidChange:self];
		}	
	}

}

-(void)setValue:(float)value
{
	if ( value < 0 ) { value = 0; }
	if ( value > 1 ) { value = 1; }
	_value = value;
	_cursor.center = CGPointMake((int)(_min + _value * ( _max - _min)),  self.frame.size.height / 2);
	[self updateColour];
}

-(void)setHue:(float)value
{
	_hue = value;
	[self updateColour];
	[self updateGradient];
}

-(void)setSaturation:(float)value
{
	_saturation = value;
	[self updateColour];
	[self updateGradient];
}

-(void)updateColour
{
	UIColor *newColour = [UIColor colorWithHue:_hue saturation:_saturation brightness:_value alpha:1.0f];
	_cursor.colour = newColour;
	[self setNeedsDisplay];
}

-(void)updateGradient
{
    @synchronized(self) {
        UIColor *fullValueColour = [UIColor colorWithHue:_hue saturation:_saturation brightness:1.0f alpha:1.0f];

        CGRect rect = CGRectMake(0,0,_stencilImage.size.width*_contentScale,_stencilImage.size.height*_contentScale);
        CGContextRef context;
        CGGradientRef myGradient;	
        CGColorSpaceRef myColorspace;	

        myColorspace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[2] = { 0.0, 1.0 };
        size_t num_locations = 2;
        CGFloat components[8] = { 
            0.0, 0.0, 0.0, 1.0,  // Start color
            1.0, 1.0, 1.0, 1.0 }; // End color

        const CGFloat *rgbComponents = CGColorGetComponents(fullValueColour.CGColor);
        CGFloat red = rgbComponents[0];
        CGFloat green = rgbComponents[1];
        CGFloat blue = rgbComponents[2];
        
        components[4] = red;
        components[5] = green;
        components[6] = blue;
            
        myGradient = CGGradientCreateWithColorComponents(
             myColorspace, 
             components,
             locations,
             num_locations
        );	
            
        // create the normal image
        context = CreateARGBBitmapContext(rect.size.width, rect.size.height);
        CGContextDrawLinearGradient(context, myGradient, CGPointMake(0,0), CGPointMake(_stencilImage.size.width*_contentScale,0), 0);
        CGContextDrawImage(context, rect, _stencilImage.CGImage);
        
        if ( _trackImage != nil ) {
            CGImageRelease(_trackImage);
            _trackImage = nil;
        }
        _trackImage = CGBitmapContextCreateImage(context);
    //	CGImageRetain(_trackImage);
        
        CGContextRelease(context);
        CGGradientRelease(myGradient);
        CGColorSpaceRelease(myColorspace);
	
        [self setNeedsDisplay];
    }	
}

@end

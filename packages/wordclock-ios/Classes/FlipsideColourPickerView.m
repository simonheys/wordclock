//
//  FlipsideColourPickerView.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "FlipsideColourPickerView.h"

@interface FlipsideColourPickerView ()
@property BOOL picking;
@end

@implementation FlipsideColourPickerView

@synthesize delegate = _delegate;
@synthesize colour;
@synthesize brightness = _brightness;
@synthesize hue = _hue;
@synthesize saturation = _saturation;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return self;
}

-(void)awakeFromNib
{
	_colourPickerCentreX = colourPicker.center.x;
	_colourPickerCentreY = colourPicker.center.y;
	_colourPickerRadius = colourPicker.frame.size.width/2;
	self.picking = NO;
}


- (void)drawRect:(CGRect)rect {

}

-(void)setBrightness:(float)value
{
	_brightness = value;
//	colourPicker.alpha = value;
	colourPicker.layer.opacity = value;
	
	[self updatePickerCursorColourAndPosition];
	/*
	if ([_delegate respondsToSelector:@selector(flipsideColourPickerViewDidChange:)]) {
		[_delegate flipsideColourPickerViewDidChange:self];
	}	
	 */
}

- (void)dealloc {
	[_delegate release];
//	[_colour release];
	[super dealloc];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( !self.picking ) {
		[self.nextResponder touchesMoved:touches withEvent:event];
		return;
	}
	UITouch *touch = [touches anyObject];
	CGPoint location;
	location = [touch locationInView:colourPicker];
	
	[self updateHueAndSaturationForLocationWithinColourPicker:location];
	[self updatePickerCursorColourAndPosition];	
//	[colourPickerCursor setExpanded:YES];
	
	
	if ([_delegate respondsToSelector:@selector(flipsideColourPickerViewDidChange:)]) {
		[_delegate flipsideColourPickerViewDidChange:self];
	}	
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location;
	location = [touch locationInView:colourPicker];
	
	if ( [self isLocationWithinColourPicker:location] ) {
		[self updateHueAndSaturationForLocationWithinColourPicker:location];
		[self updatePickerCursorColourAndPosition];
		self.picking = YES;
	//	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(delayPassedSinceTouchesBegan) userInfo:nil repeats:NO];
	}
}

-(void)delayPassedSinceTouchesBegan
{
	if ( self.picking ) {
//		[colourPickerCursor setExpanded:YES];
	}
}

- (BOOL)isLocationWithinColourPicker:(CGPoint)location
{
	float vx, vy, l;
	
	vx = location.x - _colourPickerRadius;
	vy = location.y - _colourPickerRadius;
	
	l = sqrtf(vx*vx+vy*vy);
	
	return ( l < _colourPickerRadius+15 );
}

/*
- (void)positionColourPickerForLocation:(CGPoint)location
{
	float vx, vy, l;
	
	vx = location.x - _colourPickerRadius;
	vy = location.y - _colourPickerRadius;
	
	l = sqrtf(vx*vx+vy*vy);
	
	if ( l > _colourPickerRadius ) {
		vx = _colourPickerRadius * vx / l;
		vy = _colourPickerRadius * vy / l;
	}
	colourPickerCursor.center = CGPointMake(_colourPickerCentreX + vx, _colourPickerCentreY + vy-30);
}
*/

- (void)updateHueAndSaturationForLocationWithinColourPicker:(CGPoint)location
{
	float vx, vy, l;
	
	vx = location.x - _colourPickerRadius;
	vy = location.y - _colourPickerRadius;
	
	l = sqrtf(vx*vx+vy*vy);
	
	if ( l > _colourPickerRadius ) {
		vx = _colourPickerRadius * vx / l;
		vy = _colourPickerRadius * vy / l;
	}
	
	// hue angle goes from -PI to +PI
	float hueAngle = atan2f(vx, vy);
	
	float hue = (hueAngle+M_PI)/(2*M_PI)+0.25;
	if ( hue > 1.0f ) { hue -= 1.0f; }
	float saturation = l / _colourPickerRadius;
	if ( saturation > 1.0f ) { saturation = 1.0f; }
	
//	NSLog(@"hue:%f",hue);
//	NSLog(@"saturation:%f",saturation);
	
	_hue = hue;
	_saturation = saturation;
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( !self.picking ) {
		return;
	}
	UITouch *touch = [touches anyObject];
	CGPoint location;
	location = [touch locationInView:colourPicker];
	
	[self updateHueAndSaturationForLocationWithinColourPicker:location];
	//[self positionColourPickerForLocation:location];
	[self updatePickerCursorColourAndPosition];
//	[colourPickerCursor setExpanded:NO];
	self.picking = NO;
	if ([_delegate respondsToSelector:@selector(flipsideColourPickerViewDidChange:)]) {
		[_delegate flipsideColourPickerViewDidChange:self];
	}	
//	[self positionPickerCursorForColour:_colour];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//	[colourPickerCursor setExpanded:NO];
}

-(void)updatePickerCursorColourAndPosition
{	
	float vx, vy;

	UIColor *newColour = [UIColor colorWithHue:_hue saturation:_saturation brightness:_brightness alpha:1.0f];
	
	colourPickerCursor.colour = newColour;	
//	self.colour = newColour;
	
	vx = (_colourPickerRadius * _saturation) * sinf(2*M_PI*_hue+M_PI/2);
	vy = (_colourPickerRadius * _saturation) * cosf(2*M_PI*_hue+M_PI/2);
	//colourPickerCursor.colour = value;
	colourPickerCursor.center = CGPointMake((int)(_colourPickerCentreX + vx), (int)(_colourPickerCentreY + vy));
	
	/*
	if ( _colour ) {
		[_colour release];
	}
	_colour = [newColour retain];
	*/
//	DLog(@"updatePickerCursorColourAndPosition");
}

-(void)positionPickerCursorForColour:(UIColor *)value
{

}

-(UIColor *)colour
{
//	NSLog(@"getColour:%@",colourPickerCursor.colour);
	return colourPickerCursor.colour;
}


-(void)setColour:(UIColor *)value
{
/*
	if ( _colour ) {
		[_colour release];
	}

	_colour = [value retain];
	*/
	
		CGColorRef ref = value.CGColor;
		const float* components = CGColorGetComponents(ref);
		NSLog(@"HE  L L O");
		
		float r = components[0];
		float g = components[1];
		float b = components[2];

		float min, max, delta;
		float h, s, v;
		
		BOOL bail = NO;
		
	min = r;
    if (g < min)
	min = g;
    if (b < min)
	min = b;
    max = r;
    if (g > max)
	max = g;
    if (b > max)    
	max = b;
    v = max;				// v
    delta = max - min;
    if(max != 0.0f)
		s = delta / max;		// s
    else { // r,g,b= 0			// s = 0, v is undefined
		s = 0.0f;
		h = 0.0f; // really -1,
//		return;
		bail = YES;
    }
	if ( !bail) {
		if(r == max)
			if (( g - b ) > 0 ) {
				h = (g - b) / delta;		// between yellow & magenta
			} else {
				h = 0.0f;
			}
		else if(g == max)
			h = 2.0f + (b - r) / delta;	// between cyan & yellow
		else
			h = 4.0f + (r - g) / delta;	// between magenta & cyan
		if ( h != 0.0f ) {
			h /= 6.0f;				// 0 -> 1
		}
		if(h < 0.0f)
			h += 1.0f;
	}
	

		// h is 1-saturation

		NSLog(@"h:%f",h);
		NSLog(@"s:%f",s);
		NSLog(@"v:%f",v);
	
	_hue = h;
	_saturation = s;
	_brightness = v;
	colourPicker.alpha = v;
	
	[self updatePickerCursorColourAndPosition];
}

@end

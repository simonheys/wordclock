//
//  FlipsideColourPickerCursorView.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "FlipsideColourPickerCursorView.h"


@implementation FlipsideColourPickerCursorView

@synthesize colour = _colour;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		_colour = [UIColor redColor];
		self.backgroundColor = [UIColor clearColor];
		[self setUserInteractionEnabled:NO];
	}
	return self;
}

-(void)awakeFromNib
{
	_colour = [UIColor redColor];
	self.backgroundColor = [UIColor clearColor];
	[self setUserInteractionEnabled:NO];
//	self.layer.bounds = CGRectMake(0,0,40,40);
}

- (void)drawRect:(CGRect)rect 
{	
	CGContextRef context = UIGraphicsGetCurrentContext();	
	
	CGRect rectInt = CGRectMake((int)rect.origin.x, (int)rect.origin.y, (int)rect.size.width, (int)rect.size.height);

	[[UIColor whiteColor] set];
	CGContextFillEllipseInRect (
								context,
								rectInt
								);
	/*
	[[UIColor whiteColor] set];
	CGContextFillEllipseInRect (
								context,
								CGRectInset(rect, 2, 2)
								);
	*/
	[_colour set];
	CGContextFillEllipseInRect (
								context,
								CGRectInset(rectInt, 3, 3)
								);	
								
	[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f] set];
	CGContextStrokeEllipseInRect(context, CGRectInset(rectInt, 3, 3));
}

-(void)setColour:(UIColor *)value
{
	[_colour release];
	_colour = [value retain];
	[self setNeedsDisplay];
}

- (void)dealloc {
	[_colour release];
	[super dealloc];
}


@end

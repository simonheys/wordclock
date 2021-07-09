//
//  ColourWellControl.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "ColourWellControl.h"

@interface ColourWellControl (ColourWellControlPrivate)
	- (void)customSetup;
@end

@implementation ColourWellControl

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
	[self setColour:[UIColor redColor]];
	_colourWellEmboss = [[UIImage imageNamed:@"colour_well_emboss.png"] retain];
	_colourWellHighlight = [[UIImage imageNamed:@"colour_well_highlight.png"] retain];
}

- (void) dealloc
{
	[_colourWellEmboss release];
	[_colourWellHighlight release];
	if (_colour) {
		[_colour release];
	}
	[super dealloc];
}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_colour set];
	CGContextFillEllipseInRect(context, CGRectInset(rect,4,4));

	if ( self.selected ) {
		[_colourWellHighlight drawInRect:CGRectInset(rect,1,1)];
	}
	else {
		[_colourWellEmboss drawInRect:CGRectInset(rect,1,1)];
	}
}

-(void)setSelected:(BOOL)value
{
	[self setNeedsDisplay];
	[super setSelected:value];
}

-(void)setColour:(UIColor *)colour
{
	if (_colour) {
		[_colour release];
	}
	_colour = colour;
	[_colour retain];
	[self setNeedsDisplay];
}

@end

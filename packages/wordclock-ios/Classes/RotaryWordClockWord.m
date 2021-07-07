//
//  RotaryWordClockWord.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "RotaryWordClockWord.h"


@implementation RotaryWordClockWord

@synthesize labelWidth = _labelWidth;
@synthesize scaleFactor;

-(id)initWithLabel:(NSString *)label
{
	if ( self = [super initWithLabel:label] ) {
		self.scaleFactor = 0.0f;
	}
	return self;
}

-(void)setHighlighted:(BOOL)value
{
	if ( value != _highlighted ) {
		_highlighted = value;
		[self setNeedsDisplay];
	}
}

-(void)setFont:(UIFont *)font
{
	_font = font;
	self.scaleFactor = 1.0f;
}

-(void)setScaleFactor:(float)value
{
//	DLog(@"setScaleFactor:%f",value);
	if ( value == self.scaleFactor ) {
		return;
	}
	CGSize size;
	_scaledFont = [UIFont fontWithName:_font.fontName size:_font.pointSize*value];
	
	float width;
	float totalWidth;
	
	totalWidth = 0.0f;
	
	for ( int i = 0; i < [_labelCharacterStringArray count]; i++ ) {
		width = ([[_labelCharacterStringArray objectAtIndex:i] sizeWithFont:_scaledFont]).width;
		// don't add final tracking
		if ( i < [_labelCharacterStringArray count] - 1) {
			width += self.tracking * _scaledFont.pointSize;
		}
		_width[i] = width;
		totalWidth += width;
	}

	size = [_label sizeWithFont:_scaledFont];
	_labelWidth = totalWidth;

	//fixme need to remake texture
	[self setNeedsDisplay];
}
@end

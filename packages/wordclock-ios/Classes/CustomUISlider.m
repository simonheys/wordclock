//
//  CustomUISlider.m
//  iphone_untility_app
//
//  Created by Simon on 08/03/2009.
//  Copyright 2009 Simon Heys. All rights reserved.
//

#import "CustomUISlider.h"


@implementation CustomUISlider

- (id)initWithCoder:(NSCoder*)coder
{
	DLog(@"initWithCoder");
	if((self = [super initWithCoder:coder])) {
		[self setBounds:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 45.0f)];
		[self setupCustomView];
	}
	return self;
}

-(void)setupCustomView
{
	self.backgroundColor = [UIColor clearColor];	
	UIImage *stretchLeftTrack = [[UIImage imageNamed:@"track_minimum.png"]
									stretchableImageWithLeftCapWidth:22.0 topCapHeight:0.0];
	UIImage *stretchRightTrack = [[UIImage imageNamed:@"track_maximum.png"]
									stretchableImageWithLeftCapWidth:22.0 topCapHeight:0.0];
	[self setThumbImage: [UIImage imageNamed:@"track_thumb.png"] forState:UIControlStateNormal];
	[self setMinimumTrackImage:stretchLeftTrack forState:UIControlStateNormal];
	[self setMaximumTrackImage:stretchRightTrack forState:UIControlStateNormal];
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setupCustomView];
	}
	return self;
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
//	NSLog(@"trackRectForBounds: bounds: %f, %f, %f, %f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    CGRect trackRect = [super trackRectForBounds:bounds];
//	NSLog(@"trackRectForBounds: trackRect: %f, %f, %f, %f",trackRect.origin.x,trackRect.origin.y,trackRect.size.width,trackRect.size.height);
	trackRect.origin.x-=22.5;
	trackRect.size.width +=45;
	return trackRect;
}

@end

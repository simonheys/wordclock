//
//  DisplayLinkManagerTarget.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "DisplayLinkManagerTarget.h"


@implementation DisplayLinkManagerTarget

@synthesize target;
@synthesize selector;

-(id)initWithTarget:(NSObject *)theTarget selector:(SEL)theSelector
{
	self = [super init];
	if (self != nil) {
		self.target = theTarget;
		self.selector = theSelector;
	}
	return self;
}

-(void)callSelector
{
	[self.target performSelector:self.selector];
}
@end

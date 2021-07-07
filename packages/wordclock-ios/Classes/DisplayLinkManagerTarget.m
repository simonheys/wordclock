//
//  DisplayLinkManagerTarget.m
//  iphone_word_clock_open_gl
//
//  Created by Simon on 17/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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

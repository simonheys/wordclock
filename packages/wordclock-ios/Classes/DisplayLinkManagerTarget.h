//
//  DisplayLinkManagerTarget.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 17/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayLinkManagerTarget : NSObject {
@private
	NSObject *target;
	SEL selector;
}

-(id)initWithTarget:(NSObject *)theTarget selector:(SEL)theSelector;
-(void)callSelector;

@property (assign) NSObject *target;
@property (assign) SEL selector;

@end

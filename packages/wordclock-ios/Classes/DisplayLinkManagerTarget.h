//
//  DisplayLinkManagerTarget.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
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

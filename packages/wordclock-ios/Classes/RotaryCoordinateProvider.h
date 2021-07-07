//
//  RotaryCoordinateProvider.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 15/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoordinateProvider.h"
#import "sin_and_cos_tables.h"
#import "WordClockWordGroup.h"
#import "RotaryCoordinateProviderGroup.h"

@interface RotaryCoordinateProvider : CoordinateProvider {
@private
	NSMutableArray *_rotaryCoordinateProviderGroup;
	float _orientationScale;
}

@end

//
//  RotaryCoordinateProvider.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
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

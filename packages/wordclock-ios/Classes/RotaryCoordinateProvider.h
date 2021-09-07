//
//  RotaryCoordinateProvider.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoordinateProvider.h"
#import "RotaryCoordinateProviderGroup.h"
#import "WordClockWordGroup.h"
#import "sin_and_cos_tables.h"

@interface RotaryCoordinateProvider : CoordinateProvider {
   @private
    NSMutableArray *_rotaryCoordinateProviderGroup;
    float _orientationScale;
}

@end

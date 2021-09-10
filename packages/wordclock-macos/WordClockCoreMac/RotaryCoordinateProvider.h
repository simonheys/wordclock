//
//  RotaryCoordinateProvider.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

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

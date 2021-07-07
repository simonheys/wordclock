//
//  LinearWordClockWord.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordClockPreferences.h"
//#import "NSLog.h"

#define FONT_SIZE_FOR_CALCULATION 12.0f

#import "WordClockWord.h"

@interface LinearWordClockWord : WordClockWord {
	CGSize _baseFontSizeForCalculation;
}

- (CGSize)sizeWithFont:(UIFont *)font;
- (void)setFontNameForSizeCalculation:(NSString *)fontName;
- (CGSize)sizeForCalculation:(float)size;

@end

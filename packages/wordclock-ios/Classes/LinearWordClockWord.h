//
//  WordClockWord.h
//  iphone_word_clock
//
//  Created by Simon on 17/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
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

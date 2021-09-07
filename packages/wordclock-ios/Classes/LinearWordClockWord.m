//
//  LinearWordClockWord.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "LinearWordClockWord.h"

@implementation LinearWordClockWord

- (void)setFontNameForSizeCalculation:(NSString *)fontName {
    //	DLog(@"setFontNameForSizeCalculation:%@",fontName);
    UIFont *font = [UIFont fontWithName:fontName size:FONT_SIZE_FOR_CALCULATION];
    _baseFontSizeForCalculation = [self sizeWithFont:font];
    //	[font release];
}

- (CGSize)sizeForCalculation:(float)size {
    //	DLog(@"sizeForCalculation:%f",size);
    float m = size / FONT_SIZE_FOR_CALCULATION;
    return CGSizeMake(_baseFontSizeForCalculation.width * m, _baseFontSizeForCalculation.height * m);
}

- (CGSize)sizeWithFont:(UIFont *)font {
    CGSize result;

    // this will at least give the correct height
    result = [_label sizeWithFont:font];

    result.width = 0;

    NSString *c;

    for (c in _labelCharacterStringArray) {
        result.width += ([c sizeWithFont:font]).width;
    }

    // add the result fo tracking inbetween letters
    result.width += self.tracking * font.pointSize * ([_label length] - 1);

    //	result.width += tracking * font.pointSize * [_label length];

    return result;
}

@end

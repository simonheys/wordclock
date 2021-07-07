//
//  RotaryWordClockWord.h
//  iphone_word_clock
//
//  Created by Simon on 07/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordClockWord.h"

@interface RotaryWordClockWord : WordClockWord {
	float _labelWidth;
	float scaleFactor;
	UIFont *_scaledFont;
	CATransform3D _radiusTransform;
	CATransform3D _angleTransform;
}

@property float labelWidth;
@property float scaleFactor;

@end

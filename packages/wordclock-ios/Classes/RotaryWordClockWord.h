//
//  RotaryWordClockWord.h
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
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

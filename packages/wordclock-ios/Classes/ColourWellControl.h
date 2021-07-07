//
//  ColourWellControl.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColourWellControl : UIControl {
	UIColor *_colour;
	UIImage *_colourWellEmboss;
	UIImage *_colourWellHighlight;
}
-(void)setColour:(UIColor *)colour;
@end

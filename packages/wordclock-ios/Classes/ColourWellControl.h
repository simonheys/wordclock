//
//  ColourWellControl.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColourWellControl : UIControl {
    UIColor *_colour;
    UIImage *_colourWellEmboss;
    UIImage *_colourWellHighlight;
}
- (void)setColour:(UIColor *)colour;
@end

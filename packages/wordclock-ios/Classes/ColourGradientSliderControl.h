//
//  ColourGradientSliderControl.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 25/10/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FlipsideColourPickerCursorView.h"
#import "image_utilities.h"
#import "DLog.h"

@interface ColourGradientSliderControl : UIControl {
	FlipsideColourPickerCursorView *_cursor;
	float _hue;
	float _saturation;
	float _value;
	float _min;
	float _max;
	float _contentScale;
	IBOutlet id _delegate;
	CGImageRef _trackImage;
	UIImage *_stencilImage;
}
@property (nonatomic, retain) id delegate;
@property (nonatomic) float hue;
@property (nonatomic) float saturation;
@property (nonatomic) float value;
@end

@interface ColourGradientSliderControl(ColourGradientSliderControlDelegate)
- (void)colourGradientSliderControlValueDidChange:(ColourGradientSliderControl*)control;
@end

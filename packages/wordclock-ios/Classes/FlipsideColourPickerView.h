//
//  FlipsideColourPickerView.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DLog.h"
#import "FlipsideColourPickerCursorView.h"
#import "WordClockPreview.h"

@interface FlipsideColourPickerView : UIView {
    IBOutlet UIImageView *colourPicker;
    IBOutlet FlipsideColourPickerCursorView *colourPickerCursor;
    float _colourPickerCentreX;
    float _colourPickerCentreY;
    float _colourPickerRadius;
    id _delegate;
    UIColor *colour;
    float _brightness;
    float _hue;
    float _saturation;
}

- (void)updatePickerCursorColourAndPosition;
- (BOOL)isLocationWithinColourPicker:(CGPoint)location;
- (void)updateHueAndSaturationForLocationWithinColourPicker:(CGPoint)location;
//- (void)positionColourPickerForLocation:(CGPoint)location;

@property(nonatomic, retain) id delegate;
@property(assign) UIColor *colour;
@property(readonly) BOOL picking;
@property(nonatomic) float hue;
@property(nonatomic) float saturation;
@property(nonatomic) float brightness;
@end

@interface FlipsideColourPickerView (FlipsideColourPickerViewDelegate)
- (void)flipsideColourPickerViewDidChange:(FlipsideColourPickerView *)view;
@end

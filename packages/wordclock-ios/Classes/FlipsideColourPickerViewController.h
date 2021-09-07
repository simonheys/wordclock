//
//  FlipsideColourPickerViewController.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ColourGradientSliderControl.h"
#import "ColourWellControl.h"
#import "DLog.h"
#import "FlipsideColourPickerView.h"
#import "FlipsideTabViewController.h"
#import "WordClockPreferences.h"
#import "WordClockPreview.h"

typedef enum _ColourTabViewControllerState { kNormalState, kEditingForegroundColourState, kEditingBackgroundColourState, kEditingHighlightColourState } ColourTabViewControllerState;

@interface FlipsideColourPickerViewController : FlipsideTabViewController {
    IBOutlet ColourWellControl *highlightColourWell;
    IBOutlet ColourWellControl *foregroundColourWell;
    IBOutlet ColourWellControl *backgroundColourWell;
    IBOutlet WordClockPreview *preview;
    //	id _delegate;
   @private
    ColourTabViewControllerState _state;
    //	UIColor *_colour;
    //	FlipsideColourPickerView *_pickerView;
    IBOutlet ColourGradientSliderControl *_colourSlider;
}
- (void)backgroundColourWellSelected;
- (void)foregroundColourWellSelected;
- (void)highlightColourWellSelected;
- (void)saveChanges;

//@property (nonatomic, retain) id delegate;
//@property (nonatomic, retain) UIColor *colour;
@property(retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property(retain, nonatomic) IBOutlet FlipsideColourPickerView *pickerView;

@end

/*
@interface FlipsideColourPickerViewController(FlipsideColourPickerViewControllerDelegate)
- (void)flipsideColourPickerViewControllerDidChange:(FlipsideColourPickerViewController*)controller;
@end
*/

//
//  FourthTabViewController.h
//  iphone_word_clock
//
//  Created by Simon on 17/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipsideTabViewController.h"
#import "FlipsideColourPickerView.h"
#import "WordClockPreferences.h"
#import "DLog.h"
#import "ColourWellControl.h"
#import "WordClockPreview.h"
#import "ColourGradientSliderControl.h"

typedef enum _ColourTabViewControllerState {
	kNormalState,
	kEditingForegroundColourState,
	kEditingBackgroundColourState,
	kEditingHighlightColourState
} ColourTabViewControllerState;

@interface FlipsideColourPickerViewController : FlipsideTabViewController 
{
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
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet FlipsideColourPickerView *pickerView;

@end

/*
@interface FlipsideColourPickerViewController(FlipsideColourPickerViewControllerDelegate)
- (void)flipsideColourPickerViewControllerDidChange:(FlipsideColourPickerViewController*)controller;
@end
*/
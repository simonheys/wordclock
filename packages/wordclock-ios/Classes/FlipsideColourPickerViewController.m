//
//  FlipsideColourPickerViewController.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FlipsideColourPickerViewController.h"

@interface FlipsideColourPickerViewController ()
@end


@implementation FlipsideColourPickerViewController

- (void)dealloc 
{
	[_colourSlider release];
    [_scrollView release];
    [_pickerView release];
    [super dealloc];
}

- (instancetype)init {
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Colour", @"");
		self.tabBarItem.image = [UIImage imageNamed:@"colour.png"];		
	}
	return self;
}

- (void)backgroundColourWellSelected
{
 	[self setState:kEditingBackgroundColourState];
}

- (void)foregroundColourWellSelected
{
 	[self setState:kEditingForegroundColourState];
}

- (void)highlightColourWellSelected
{
 	[self setState:kEditingHighlightColourState];
}

- (void)colourGradientSliderControlValueDidChange:(ColourGradientSliderControl*)control
{
	self.pickerView.brightness = control.value;
	[self updateColourWellsWithColourFromPicker];
}

-(void)setState:(ColourTabViewControllerState)value
{
	if ( _state == value ) {
		return;
	}
		
	switch (_state) {
		case kEditingForegroundColourState:
			[self saveChanges];
			foregroundColourWell.selected = NO;
			foregroundColourWell.enabled = YES;
			break;
		case kEditingBackgroundColourState:
			[self saveChanges];
			backgroundColourWell.selected = NO;
			backgroundColourWell.enabled = YES;
			break;
		case kEditingHighlightColourState:
			[self saveChanges];
			highlightColourWell.selected = NO;
			highlightColourWell.enabled = YES;
			break;	
	}
	
	_state = value;
	
	switch (_state) {
		case kEditingBackgroundColourState:
			backgroundColourWell.selected = YES;
			backgroundColourWell.enabled = NO;
			self.pickerView.colour = [WordClockPreferences sharedInstance].backgroundColour;	
			_colourSlider.value = self.pickerView.brightness;
			_colourSlider.hue = self.pickerView.hue;
			_colourSlider.saturation = self.pickerView.saturation;
			break;
		case kEditingForegroundColourState:
			foregroundColourWell.selected = YES;
			foregroundColourWell.enabled = NO;
			self.pickerView.colour = [WordClockPreferences sharedInstance].foregroundColour;
			_colourSlider.value = self.pickerView.brightness;
			_colourSlider.hue = self.pickerView.hue;
			_colourSlider.saturation = self.pickerView.saturation;
			break;
		case kEditingHighlightColourState:
			highlightColourWell.selected = YES;
			highlightColourWell.enabled = NO;
			self.pickerView.colour = [WordClockPreferences sharedInstance].highlightColour;	
			_colourSlider.value = self.pickerView.brightness;
			_colourSlider.hue = self.pickerView.hue;
			_colourSlider.saturation = self.pickerView.saturation;
			break;
	}
}

- (void)flipsideColourPickerViewDidChange:(FlipsideColourPickerView*)view
{
	[self updateColourWellsWithColourFromPicker];
	_colourSlider.hue = self.pickerView.hue;
	_colourSlider.saturation = self.pickerView.saturation;
}

-(void)updateColourWellsWithColourFromPicker
{
	switch (_state) {
		case kEditingBackgroundColourState:
			[backgroundColourWell setColour:self.pickerView.colour];
			preview.backgroundColour = self.pickerView.colour;
			break;
		case kEditingForegroundColourState:
			[foregroundColourWell setColour:self.pickerView.colour];
			preview.foregroundColour = self.pickerView.colour;
			break;
		case kEditingHighlightColourState:
			[highlightColourWell setColour:self.pickerView.colour];
			preview.highlightColour = self.pickerView.colour;
			break;
	}

}

-(IBAction)doneSelected 
{
	[self saveChanges];
	[super doneSelected];
}

-(void)saveChanges
{
	switch (_state) {
		case kEditingBackgroundColourState:
			[WordClockPreferences sharedInstance].backgroundColour = self.pickerView.colour;
			break;
		case kEditingForegroundColourState:
			[WordClockPreferences sharedInstance].foregroundColour = self.pickerView.colour;	
			break;
		case kEditingHighlightColourState:
			[WordClockPreferences sharedInstance].highlightColour = self.pickerView.colour;		
			break;
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	DLog(@"viewWillDisappear");
	[self saveChanges];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[preview updateFromPreferences];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( [keyPath isEqual:@"picking"] ) {
        self.scrollView.scrollEnabled = !self.pickerView.picking;
    }
}
 
- (void)viewDidLoad 
{
	BOOL isRunningOnPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

//	self.pickerView = (FlipsideColourPickerView *)self.view;
//	self.pickerView.delegate = self;

    [self.pickerView addObserver:self forKeyPath:@"picking" options:NSKeyValueObservingOptionNew context:NULL];
    self.pickerView.delegate = self;
	
	backgroundColourWell.backgroundColor = [UIColor clearColor];
	foregroundColourWell.backgroundColor = [UIColor clearColor];
	highlightColourWell.backgroundColor = [UIColor clearColor];
	
	[backgroundColourWell setColour:[WordClockPreferences sharedInstance].backgroundColour];
	[foregroundColourWell setColour:[WordClockPreferences sharedInstance].foregroundColour];
	[highlightColourWell setColour:[WordClockPreferences sharedInstance].highlightColour];
		
	[backgroundColourWell addTarget:self action:@selector(backgroundColourWellSelected) forControlEvents:UIControlEventTouchUpInside];
	[foregroundColourWell addTarget:self action:@selector(foregroundColourWellSelected) forControlEvents:UIControlEventTouchUpInside];
	[highlightColourWell addTarget:self action:@selector(highlightColourWellSelected) forControlEvents:UIControlEventTouchUpInside];
	_state = kNormalState;
	[self setState:kEditingHighlightColourState];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    if ( isRunningOnPad ) {
        self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    }
    else {
         self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = self.pickerView.bounds.size;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    preview.layer.masksToBounds = YES;
    preview.layer.cornerRadius = 45.0f;
}


- (void)viewDidUnload {
    [self.pickerView removeObserver:self forKeyPath:@"picking"];
    [self setScrollView:nil];
    [self setPickerView:nil];
    [super viewDidUnload];
}
@end

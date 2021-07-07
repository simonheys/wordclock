//
//  ThirdTabViewController.h
//  iphone_word_clock
//
//  Created by Simon on 17/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordClockPreferences.h"
#import "CustomUISlider.h"
#import "ShowableWordClockPreview.h"
#import "FlipsideTabViewController.h"

//#import "NSLog.h"

@interface TypographyTabViewController : FlipsideTabViewController 
{
	IBOutlet UISegmentedControl *justifyControl;
	IBOutlet UISegmentedControl *caseControl;
	IBOutlet CustomUISlider *trackingSlider;
	IBOutlet CustomUISlider *leadingSlider;
	
@private
	ShowableWordClockPreview *_preview;
	UIDeviceOrientation _currentOrientation;
}
@property (nonatomic, retain) IBOutlet UIView *wrapperView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)justifyChanged;
- (IBAction)caseChanged;
- (IBAction)trackingChanged;
- (IBAction)leadingChanged;
- (IBAction)trackingChangeFinished;
- (IBAction)leadingChangeFinished;
- (IBAction)trackingChangeStarted;
- (IBAction)leadingChangeStarted;
@end

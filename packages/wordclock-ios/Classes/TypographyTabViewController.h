//
//  TypographyTabViewController.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomUISlider.h"
#import "FlipsideTabViewController.h"
#import "ShowableWordClockPreview.h"
#import "WordClockPreferences.h"

// #import "NSLog.h"

@interface TypographyTabViewController : FlipsideTabViewController {
    IBOutlet UISegmentedControl *justifyControl;
    IBOutlet UISegmentedControl *caseControl;
    IBOutlet CustomUISlider *trackingSlider;
    IBOutlet CustomUISlider *leadingSlider;

   @private
    ShowableWordClockPreview *_preview;
    UIDeviceOrientation _currentOrientation;
}
@property(nonatomic, retain) IBOutlet UIView *wrapperView;
@property(retain, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)justifyChanged;
- (IBAction)caseChanged;
- (IBAction)trackingChanged;
- (IBAction)leadingChanged;
- (IBAction)trackingChangeFinished;
- (IBAction)leadingChangeFinished;
- (IBAction)trackingChangeStarted;
- (IBAction)leadingChangeStarted;
@end

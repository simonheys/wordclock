//
//  RootViewController.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DLog.h"
#import "FlipsideViewController.h"
#import "WordClockViewController.h"
#import "WordClockViewControls.h"

@class WordClockViewController;
@class FlipsideViewController;

@interface RootViewController : UIViewController <FlipsideViewControllerDelegate> {
    WordClockViewController *wordClockViewController;
    FlipsideViewController *flipsideViewController;
    IBOutlet UIImageView *startupImage;
    BOOL _startingUp;
    UIView *_mainView;
}

@property(nonatomic, retain) WordClockViewController *wordClockViewController;
@property(nonatomic, retain) FlipsideViewController *flipsideViewController;

- (void)wordClockDidCompleteParsing:(WordClockViewController *)controller;
- (void)loadFlipsideViewController;

- (IBAction)showInfo;

+ (float)getScale;

@end

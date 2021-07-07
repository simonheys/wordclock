//
//  RootViewController.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordClockViewController.h"
#import "FlipsideViewController.h"
#import "DLog.h"
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

@property (nonatomic, retain) WordClockViewController *wordClockViewController;
@property (nonatomic, retain) FlipsideViewController *flipsideViewController;

- (void)wordClockDidCompleteParsing:(WordClockViewController*)controller;
- (void)loadFlipsideViewController;




- (IBAction)showInfo;


+(float)getScale;

@end


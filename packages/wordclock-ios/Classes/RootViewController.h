//
//  iphone_word_clockViewController.h
//  iphone_word_clock
//
//  Created by Simon on 21/07/2008.
//  Copyright Simon Heys 2008. All rights reserved.
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


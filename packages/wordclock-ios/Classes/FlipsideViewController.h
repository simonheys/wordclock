//
//  FlipsideViewController.h
//  iphone_word_clock
//
//  Created by Simon on 22/07/2008.
//  Copyright 2008 Simon Heys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordsTabViewController.h"
#import "FontTabViewController.h"
#import "TypographyTabViewController.h"
#import "FlipsideColourPickerViewController.h"
#import "AboutTabViewController.h"
#import "WordClockXmlFileParser.h"
#import "DLog.h"

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <UITabBarControllerDelegate> {
	UIViewController *_currentSelectedViewController;
	UITabBarController *_tabBarController;
	UIImageView *_gradientBackground;

	id <FlipsideViewControllerDelegate> delegate;

}
-(void)flipsideViewDone:(NSNotification *)notification;




@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
//- (IBAction)done;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end


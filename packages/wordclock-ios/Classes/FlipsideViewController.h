//
//  FlipsideViewController.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AboutTabViewController.h"
#import "DLog.h"
#import "FlipsideColourPickerViewController.h"
#import "FontTabViewController.h"
#import "TypographyTabViewController.h"
#import "WordsTabViewController.h"

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController <UITabBarControllerDelegate>
- (void)flipsideViewDone:(NSNotification *)notification;
@property(nonatomic, assign) id<FlipsideViewControllerDelegate> delegate;
@end

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

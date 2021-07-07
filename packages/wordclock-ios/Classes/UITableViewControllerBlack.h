//
//  UITableViewControllerBlack.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 11/04/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLog.h"
#import "TableLoadingViewController.h"

@interface UITableViewControllerBlack : UITableViewController {
	UIImageView *_accessorySelected;
	UIActivityIndicatorView *_activityIndicator;
	UIBarButtonItem *_activityButton;
	UIBarButtonItem *_doneButton;
	TableLoadingViewController *loadingViewController;
	BOOL _loading;
}
- (IBAction)doneSelected;
-(void)setLoading:(BOOL)value;

@property (nonatomic, retain) TableLoadingViewController *loadingViewController;

@end

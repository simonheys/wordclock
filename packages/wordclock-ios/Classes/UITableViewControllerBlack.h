//
//  UITableViewControllerBlack.h
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
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

//
//  FontTabViewController.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DLog.h"
#import "UITableViewControllerBlack.h"
#import "WordsTabViewController.h"

@interface FontTabViewController : UITableViewControllerBlack {
    NSArray *displayList;
    NSDictionary *currentFont;
    NSIndexPath *currentIndexPath;

    BOOL _dataLoaded;
}
@property(nonatomic, retain) NSArray *displayList;
@property(nonatomic, retain) NSDictionary *currentFont;
@property(nonatomic, retain) NSIndexPath *currentIndexPath;

- (void)setUpDisplayList;
- (void)saveChanges;
- (void)loadData;
@end

//
//  SecondTabViewController.h
//  iphone_word_clock
//
//  Created by Simon on 17/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordsTabViewController.h"
#import "UITableViewControllerBlack.h"
#import "DLog.h"

@interface FontTabViewController : UITableViewControllerBlack 
{
	NSArray *displayList;
	NSDictionary *currentFont;
	NSIndexPath *currentIndexPath;
	
	BOOL _dataLoaded;
}
@property (nonatomic, retain) NSArray *displayList;
@property (nonatomic, retain) NSDictionary *currentFont;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;

- (void)setUpDisplayList;
-(void)saveChanges;
- (void)loadData;
@end

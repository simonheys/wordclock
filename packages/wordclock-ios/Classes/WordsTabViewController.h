//
//  WordsTabViewController.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordClockXmlFileParser.h"
#import "WordClockPreferences.h"
#import "UITableViewControllerBlack.h"
#import "DLog.h"

NSMutableDictionary *sectionDictionaryWithNameInArray(NSString *name, NSArray *array);

typedef enum _WordsTabViewControllerState {
    kWordsTabViewControllerLoadingState,
    kWordsTabViewControllerNotLoadedState,
	kWordsTabViewControllerLoadedState
} WordsTabViewControllerState;


@interface WordsTabViewController : UITableViewControllerBlack
{
	NSArray *displayList;
	NSDictionary *currentFile;
	NSIndexPath *currentIndexPath;
	WordsTabViewControllerState _state;
	BOOL _dataLoaded;
}

@property (nonatomic, retain) NSArray *displayList;
@property (nonatomic, retain) NSDictionary *currentFile;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;

- (void)setupDisplayList;
//- (void)loadLoadingViewController;
- (void)setState:(WordsTabViewControllerState)state;
- (void)loadData;

@end

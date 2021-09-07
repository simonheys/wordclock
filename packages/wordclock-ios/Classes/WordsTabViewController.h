//
//  WordsTabViewController.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DLog.h"
#import "UITableViewControllerBlack.h"
#import "WordClockPreferences.h"
#import "WordClockWordsManifestFileParser.h"

NSMutableDictionary *sectionDictionaryWithNameInArray(NSString *name, NSArray *array);

typedef enum _WordsTabViewControllerState { kWordsTabViewControllerLoadingState, kWordsTabViewControllerNotLoadedState, kWordsTabViewControllerLoadedState } WordsTabViewControllerState;

@interface WordsTabViewController : UITableViewControllerBlack <WordClockWordsManifestFileParserDelegate> {
    NSArray *displayList;
    NSDictionary *currentFile;
    NSIndexPath *currentIndexPath;
    WordsTabViewControllerState _state;
    BOOL _dataLoaded;
}

@property(nonatomic, retain) NSArray *displayList;
@property(nonatomic, retain) NSDictionary *currentFile;
@property(nonatomic, retain) NSIndexPath *currentIndexPath;

- (void)setupDisplayList;
//- (void)loadLoadingViewController;
- (void)setState:(WordsTabViewControllerState)state;
- (void)loadData;

@end

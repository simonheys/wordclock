//
//  WordClockWordManager.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 14/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WordClockWordGroup.h"

extern NSString *const kWordClockWordManagerNumberOfWordsDidChangeNotification;
extern NSString *const kWordClockWordManagerLogicaAndLabelsDidChangeNotification;
extern NSString *const kWordClockWordManagerLogicaAndLabelsWillChangeNotification;

@interface WordClockWordManager : NSObject 
{
@private
	NSMutableArray *_group;
	NSMutableArray *_word;
	NSArray *_logic;
	NSArray *_label;
	uint _numberOfWords;
	uint _longestLabelIndex;
}
+ (WordClockWordManager*)sharedInstance;
- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray;
- (void)highlightForCurrentTime;
- (NSArray *)longestLabelArray;

@property (readonly) NSMutableArray *group;
@property (readonly) NSMutableArray *word;
@property (readonly) uint numberOfWords;
@end

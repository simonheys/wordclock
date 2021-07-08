//
//  WordClockWordGroup.h
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "DLog.h"
#import "WordClockWord.h"
#import "LogicParser.h"

//@class WordClockWord;
//@class LogicParser;

@interface WordClockWordGroup : NSObject {
	WordClockWordGroup *_parent;
	WordClockWordGroup *_child;
	NSArray *_logic;
	NSMutableArray *_word;	
	int _selectedIndex;
	uint _numberOfWords;
}
- (id)initWithLogic:(NSArray *)logicArray label:(NSArray *)labelArray;
- (void)setParent:(WordClockWordGroup *)value;
- (void)setChild:(WordClockWordGroup *)value;
- (void)highlightForCurrentTime;
- (void)highlightForIndex:(int)value;
//- (WordClockWord *)createWordWithLabel:(NSString *)label;

@property (readonly) uint numberOfWords;
@property (readonly) NSMutableArray *word;
@property int selectedIndex;

@end

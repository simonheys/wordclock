//
//  WordClockWordGroup.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 02/11/2008.
//  Copyright 2008 Simon Heys. All rights reserved.
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

//
//  WordClockWordGroup.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WordClockWordGroup;
@class TweenManager;

@interface WordClockWordGroup : NSObject {
@private
	WordClockWordGroup *_parent;
	WordClockWordGroup *_child;
    TweenManager *_tweenManager;
    NSMutableArray *_word;
    NSArray *_logic;
    NSInteger _numberOfWords;
    NSInteger _selectedIndex;
}
- (instancetype)initWithLogic:(NSArray *)logicArray label:(NSArray *)labelArray tweenManager:(TweenManager *)tweenManager;
- (void)setParent:(WordClockWordGroup *)value;
- (void)setChild:(WordClockWordGroup *)value;
- (void)highlightForCurrentTime;
- (void)highlightForIndex:(NSInteger)value;
//- (WordClockWord *)createWordWithLabel:(NSString *)label;

@property (readonly) NSInteger numberOfWords;
@property (nonatomic, retain, readonly) NSMutableArray *word;
@property NSInteger selectedIndex;

@end

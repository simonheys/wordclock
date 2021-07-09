//
//  WordClockWordManager.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//


#import "WordClockWordGroup.h"

@class TweenManager;

extern NSString *const kWordClockWordManagerNumberOfWordsDidChangeNotification;
extern NSString *const kWordClockWordManagerLogicaAndLabelsDidChangeNotification;
extern NSString *const kWordClockWordManagerLogicaAndLabelsWillChangeNotification;

@interface WordClockWordManager : NSObject 
{
@private
	uint _longestLabelIndex;
    TweenManager *_tweenManager;
    NSMutableArray *_group;
    NSMutableArray *_word;
    NSArray *_logic;
    NSArray *_label;
    NSInteger _numberOfWords;
}
- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray tweenManager:(TweenManager *)tweenManager;
- (void)highlightForCurrentTime;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *longestLabelArray;

@property (nonatomic, retain, readonly) NSMutableArray *group;
@property (nonatomic, retain, readonly) NSMutableArray *word;
@property (readonly) NSInteger numberOfWords;
@end

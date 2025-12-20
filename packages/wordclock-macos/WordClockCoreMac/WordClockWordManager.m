//
//  WordClockWordManager.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

/*
 * This class is responsible for holding all the groups in the current clock
 */
#import "WordClockWordManager.h"

#import "TweenManager.h"
#import "WordClockWord.h"

NSString *const kWordClockWordManagerNumberOfWordsDidChangeNotification = @"kWordClockWordManagerNumberOfWordsDidChangeNotification";
NSString *const kWordClockWordManagerLogicaAndLabelsDidChangeNotification = @"kWordClockWordManagerLogicaAndLabelsDidChangeNotification";
NSString *const kWordClockWordManagerLogicaAndLabelsWillChangeNotification = @"kWordClockWordManagerLogicaAndLabelsWillChangeNotification";

@interface WordClockWordManager ()
@property(nonatomic, retain) TweenManager *tweenManager;
@property(nonatomic, retain) NSMutableArray *group;
@property(nonatomic, retain) NSMutableArray *word;
@property(nonatomic, retain) NSArray *logic;
@property(nonatomic, retain) NSArray *label;
@property NSInteger numberOfWords;
@end

@implementation WordClockWordManager

@synthesize tweenManager = _tweenManager;
@synthesize group = _group;
@synthesize word = _word;
@synthesize logic = _logic;
@synthesize label = _label;
@synthesize numberOfWords = _numberOfWords;

// ____________________________________________________________________________________________________
// dealloc

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [_logic release];
    [_label release];
    [_group release];
    [_word release];
    [_tweenManager release];
    [super dealloc];
}

// ____________________________________________________________________________________________________
// logic

- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray tweenManager:(TweenManager *)tweenManager {
    [[NSNotificationCenter defaultCenter] postNotificationName:kWordClockWordManagerLogicaAndLabelsWillChangeNotification object:self];

    self.logic = logicArray;
    self.label = labelArray;
    self.tweenManager = tweenManager;

    int i;

    WordClockWord *word;
    _longestLabelIndex = 0;
    int numberOfWordsInCurrentLabels;
    int numberOfWordsInLongestLabels = 0;

    self.group = [[[NSMutableArray alloc] init] autorelease];
    self.word = [[[NSMutableArray alloc] init] autorelease];

    for (i = 0; i < [logicArray count]; i++) {
        WordClockWordGroup *wordClockWordGroup = [[[WordClockWordGroup alloc] initWithLogic:logicArray[i] label:labelArray[i] tweenManager:self.tweenManager] autorelease];

        if (i > 0) {
            [wordClockWordGroup setParent:(WordClockWordGroup *)[self.group lastObject]];  // objectAtIndex:[self.group
                                                                                           // count]-1]];
        }

        [self.group addObject:wordClockWordGroup];

        // only add the ones that are not spaces
        numberOfWordsInCurrentLabels = 0;
        for (word in wordClockWordGroup.word) {
            if (!word.isSpace) {
                [self.word addObject:word];
                numberOfWordsInCurrentLabels++;
            }
        }

        if (numberOfWordsInCurrentLabels > numberOfWordsInLongestLabels) {
            numberOfWordsInLongestLabels = numberOfWordsInCurrentLabels;
            _longestLabelIndex = i;
        }
    }

    // if the number of words has changed, let everyone know
    if ([self.word count] != self.numberOfWords) {
        self.numberOfWords = [self.word count];

        [[NSNotificationCenter defaultCenter] postNotificationName:kWordClockWordManagerNumberOfWordsDidChangeNotification object:self];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kWordClockWordManagerLogicaAndLabelsDidChangeNotification object:self];
}

// ____________________________________________________________________________________________________
// highlight

- (void)highlightForCurrentTime {
    for (WordClockWordGroup *group in self.group) {
        [group highlightForCurrentTime];
    }
}

// ____________________________________________________________________________________________________
// preview

- (NSArray *)longestLabelArray {
    return (self.label)[_longestLabelIndex];
}

@end

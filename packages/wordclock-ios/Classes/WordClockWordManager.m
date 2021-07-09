//
//  WordClockWordManager.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

/*
 * This class is responsible for holding all the groups in the current clock
 */
#import "WordClockWordManager.h"

NSString *const kWordClockWordManagerNumberOfWordsDidChangeNotification = @"kWordClockWordManagerNumberOfWordsDidChangeNotification";

NSString *const kWordClockWordManagerLogicaAndLabelsDidChangeNotification = @"kWordClockWordManagerLogicaAndLabelsDidChangeNotification";

NSString *const kWordClockWordManagerLogicaAndLabelsWillChangeNotification = @"kWordClockWordManagerLogicaAndLabelsWillChangeNotification";

@implementation WordClockWordManager

// ____________________________________________________________________________________________________ logic

- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray
{
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:kWordClockWordManagerLogicaAndLabelsWillChangeNotification 
		object:self
	];

	DLog(@"setLogic");
	if ( _logic ) {
		[_logic release];
	}
	_logic = [logicArray retain];
	
	if ( _label ) {
		[_label release];
	}
	_label = [labelArray retain];
	
	int i;
	
	WordClockWordGroup *wg;
	WordClockWord *word;
	_longestLabelIndex = 0;
	int numberOfWordsInCurrentLabels;
	int numberOfWordsInLongestLabels = 0;
	
	if ( _group ) {
		[_group release];
	}
	if ( _word ) {
		[_word release];
	}
	_group = [[NSMutableArray alloc] init];
	_word = [[NSMutableArray alloc] init];
	
	for ( i = 0; i < [logicArray count]; i++) {	
		wg = [[WordClockWordGroup alloc] 
			initWithLogic:[logicArray objectAtIndex:i] 
			label:[labelArray objectAtIndex:i]
		];		
	
		if ( i > 0 ) {
			[wg setParent:(WordClockWordGroup *)[_group lastObject]];// objectAtIndex:[_group count]-1]];
		}

		[_group addObject:wg];
		
		// only add the ones that are not spaces
		numberOfWordsInCurrentLabels = 0;
		for ( word in wg.word ) {
			if ( !word.isSpace ) {
				[_word addObject:word];
				numberOfWordsInCurrentLabels++;
			}
		}
		
		if ( numberOfWordsInCurrentLabels > numberOfWordsInLongestLabels ) {
			numberOfWordsInLongestLabels = numberOfWordsInCurrentLabels;
			_longestLabelIndex = i;
		}
		//[_word addObjectsFromArray:wg.word];
		
		[wg release];
	}
	
	// if the number of words has changed, let everyone know
	if ( [_word count] != _numberOfWords ) {
		_numberOfWords = [_word count];
		
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:kWordClockWordManagerNumberOfWordsDidChangeNotification 
			object:self
		];
	}
	
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:kWordClockWordManagerLogicaAndLabelsDidChangeNotification 
		object:self
	];
}

// ____________________________________________________________________________________________________ highlight

- (void)highlightForCurrentTime
{
	for ( WordClockWordGroup *group in _group) {	
		[group highlightForCurrentTime];
	}
}


// ____________________________________________________________________________________________________ preview

- (NSArray *)longestLabelArray
{
/*
	int mostWordsSoFar = 0;
	WordClockWordGroup *result;
	for ( WordClockWordGroup *group in _group) {	
		if ( group.numberOfWords > mostWordsSoFar ) {
			mostWordsSoFar = group.numberOfWords;
			result = group;
		}
	}
	
	return result;*/
	return [_label objectAtIndex:_longestLabelIndex];
}

// ____________________________________________________________________________________________________ dealloc

- (void)dealloc 
{
	[_logic release];
	[_label release];
	[_group release];
	[_word release];
	[super dealloc];
}

// ____________________________________________________________________________________________________ accessors

@synthesize group = _group;
@synthesize word = _word;
@synthesize numberOfWords = _numberOfWords;

// ____________________________________________________________________________________________________ singleton

static WordClockWordManager *shareWordClockWordManagerInstance = nil;

+ (WordClockWordManager*)sharedInstance
{
    @synchronized(self) {
        if (shareWordClockWordManagerInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return shareWordClockWordManagerInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (shareWordClockWordManagerInstance == nil) {
            shareWordClockWordManagerInstance = [super allocWithZone:zone];
            return shareWordClockWordManagerInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


@end

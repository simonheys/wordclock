//
//  WordClockWordGroup.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockWordGroup.h"
#import "TweenManager.h"
#import "WordClockWord.h"
#import "LogicParser.h"

@interface WordClockWordGroup ()
@property (nonatomic, retain) TweenManager *tweenManager;
@property (nonatomic, retain) NSMutableArray *word;
@property (nonatomic, retain) NSArray *logic;
@property NSInteger numberOfWords;
@end

@implementation WordClockWordGroup

@synthesize tweenManager = _tweenManager;
@synthesize word = _word;
@synthesize logic = _logic;
@synthesize numberOfWords = _numberOfWords;
@synthesize selectedIndex = _selectedIndex;

- (void)dealloc 
{
//    DDLogVerbose(@"dealloc");
	[_logic release];
	[_word release];
    [_tweenManager release];
	[super dealloc];
}

-(instancetype)initWithLogic:(NSArray *)logicArray label:(NSArray *)labelArray tweenManager:(TweenManager *)tweenManager
{
    self = [super init];
    if (self) {
        self.numberOfWords = 0;		
		self.word = [[[NSMutableArray alloc] init] autorelease];
        self.tweenManager = tweenManager;
		for ( NSInteger i = 0; i < [logicArray count]; i++ ) {
			WordClockWord  *w = [[[WordClockWord alloc] initWithLabel:labelArray[i] tweenManager:tweenManager] autorelease];
			[self.word addObject:w];
		}		
		self.numberOfWords = [logicArray count];		
		self.logic = logicArray;		
		self.selectedIndex = -1;
	}
	return self;
}

// ____________________________________________________________________________________________________ highlight

-(void)highlightForCurrentTime
{
//	DDLogVerbose(@"highlightForCurrentTime");
	// go through each logic, find something that's true and rotate to it
	BOOL found = NO;
	NSInteger i;
	NSInteger result;
	NSInteger offset = self.selectedIndex == -1 ? 0 : self.selectedIndex;
	NSInteger test;
	i = 0;
	
	// if current logic is 'else' then start again from the beginning
	if ( [(NSString *)(self.logic)[offset] isEqualToString:@"else"] ) {
		offset = 0;
	}
	
	while (!found && i < [self.logic count]) {
		test = (i+offset) % [self.logic count];
//		DDLogVerbose(@"test:%d  logic:%@",test,[_logic objectAtIndex:test]);
		//trace(_logic[test]);
		//if ( _logic[test].length != 0 ){
		if ( [(self.logic)[test] length] != 0 ) {
			//result = LogicParser.getInstance().parse(_logic[test]);
			
			result = [[LogicParser sharedInstance] parse:(self.logic)[test]];
//			DDLogVerbose(@"testing:%@  result:%@",[_logic objectAtIndex:test], result ? @"true" : @"false");
			//trace("index:"+i+" testing '"+_logic[i]+"' result="+result);
			if ( result == TRUE ) {
				found = YES;
				[self highlightForIndex:test];
			}
		}
		i++;
	}
}

// ____________________________________________________________________________________________________ highlight

-(void)highlightForIndex:(NSInteger)value
{
//	DDLogVerbose(@"highlightForIndex:%d",value);
	
	if ( value != self.selectedIndex ) {
		if ( self.selectedIndex != -1 ) {
			[(WordClockWord *)(self.word)[self.selectedIndex] setHighlighted:NO];
		}
		// using self allows value observation
		self.selectedIndex = value;
		[(WordClockWord *)(self.word)[self.selectedIndex] setHighlighted:YES];
	}
}

// ____________________________________________________________________________________________________ parent / child

-(void)setParent:(WordClockWordGroup *)value
{
	//	DDLogVerbose(@"setParent:%@",value);
	// we'll need to implement this
	_parent = value;	
	[_parent setChild:self];
}

-(void)setChild:(WordClockWordGroup *)value
{
	_child = value;
}

// ____________________________________________________________________________________________________ delloc

@end

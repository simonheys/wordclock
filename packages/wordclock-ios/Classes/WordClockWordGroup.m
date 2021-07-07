//
//  WordClockWordGroup.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockWordGroup.h"


@implementation WordClockWordGroup

-(id)initWithLogic:(NSArray *)logicArray label:(NSArray *)labelArray
{
	_numberOfWords = 0;
	
//	DLog(@"initWithLogic");
	if ( self = [super init] ) {
		WordClockWord *w;
		int i;
		
		_word = [[NSMutableArray alloc] init];
		
		for ( i = 0; i < [logicArray count]; i++ ) {
			w = [[WordClockWord alloc] initWithLabel:[labelArray objectAtIndex:i]];
			
			[_word addObject:w];
			//w is retained by the array
			[w release];
		}
		
		_numberOfWords = [logicArray count];
		
		_logic = [logicArray retain];
		
		_selectedIndex = -1;
		
		
	}
	return self;
}

// ____________________________________________________________________________________________________ highlight

-(void)highlightForCurrentTime
{
//	DLog(@"highlightForCurrentTime");
	// go through each logic, find something that's true and rotate to it
	BOOL found = NO;
	int i;
	int result;
	int offset = _selectedIndex == -1 ? 0 : _selectedIndex;
	int test;
	i = 0;
	
	// if current logic is 'else' then start again from the beginning
	if ( [(NSString *)[_logic objectAtIndex:offset] isEqualToString:@"else"] ) {
		offset = 0;
	}
	
	while (!found && i < [_logic count]) {
		test = (i+offset) % [_logic count];
//		DLog(@"test:%d  logic:%@",test,[_logic objectAtIndex:test]);
		//trace(_logic[test]);
		//if ( _logic[test].length != 0 ){
		if ( [[_logic objectAtIndex:test] length] != 0 ) {
			//result = LogicParser.getInstance().parse(_logic[test]);
			
			result = [[LogicParser sharedInstance] parse:[_logic objectAtIndex:test]];
//			DLog(@"testing:%@  result:%@",[_logic objectAtIndex:test], result ? @"true" : @"false");
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

-(void)highlightForIndex:(int)value
{
//	DLog(@"highlightForIndex:%d",value);
	
	if ( value != _selectedIndex ) {
		if ( _selectedIndex != -1 ) {
			[(WordClockWord *)[_word objectAtIndex:_selectedIndex] setHighlighted:NO];
		}
		// using self allows value observation
		self.selectedIndex = value;
		[(WordClockWord *)[_word objectAtIndex:_selectedIndex] setHighlighted:YES];
	}
}

// ____________________________________________________________________________________________________ parent / child

-(void)setParent:(WordClockWordGroup *)value
{
	//	DLog(@"setParent:%@",value);
	// we'll need to implement this
	_parent = value;	
	[_parent setChild:self];
}

-(void)setChild:(WordClockWordGroup *)value
{
	_child = value;
}

// ____________________________________________________________________________________________________ delloc

- (void)dealloc 
{
//	DLog(@"dealloc");
//	DLog(@"parent");
	if ( _parent ) {
		//		[_parent release];
	}
	if ( _child ) {
		//		[_child release];
	}
//	DLog(@"logic");
	//	if ( _logic ) {
	[_logic release];
	//	}
	//	if ( _word ) {
	// FIXME is this necessary?
//	DLog(@"word");
	[_word removeAllObjects];
	[_word release];
	//	}
	[super dealloc];
}

@synthesize numberOfWords = _numberOfWords;
@synthesize word = _word;
@synthesize selectedIndex = _selectedIndex;
@end

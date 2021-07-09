//
//  LogicXmlFileParser.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "LogicXmlFileParser.h"


@implementation LogicXmlFileParser

-(void)parseFile:(NSString *)pathToFile
{
	BOOL success;
	
    NSURL *xmlURL = [NSURL fileURLWithPath:pathToFile];
    if (_parser) {
        [_parser release];
	}
	
	if ( _groupLogic ) {
		[_groupLogic release];
	}
	
	// FIXME memory leak here. releasing this causes a crash
	if ( _groupLabel ) {
	//	[_groupLabel release];
	}
	
	if ( _resultLogic ) {
		[_resultLogic release];
	}
	if ( _resultLabel ) {
		[_resultLabel release];
	}
	
	_resultLogic = [[NSMutableArray alloc] init];
	_resultLabel = [[NSMutableArray alloc] init];
	_parsingGroup = NO;
	
    _parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [_parser setDelegate:self];
    [_parser setShouldResolveExternalEntities:NO];
    success = [_parser parse]; // return value not used
}

- (void)parser:(NSXMLParser *)parser 
	didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
//	NSLog(@"parser:didStartElement:%@",elementName);
	
   if ( [elementName isEqualToString:@"group"]) {
		_parsingGroup = YES;	
		if ( _groupLogic ) {
			[_groupLogic release];
		}
		if ( _groupLabel ) {
			[_groupLabel release];
		}
		_groupLogic = [[NSMutableArray alloc] init];
		_groupLabel = [[NSMutableArray alloc] init];
	}
	
	if ( _parsingGroup ) {
		if ( [elementName isEqualToString:@"item"]) {
			[_groupLogic addObject:[attributeDict valueForKey:@"highlight"]];
		}	
		else if ( [elementName isEqualToString:@"sequence"]) {
			_bind = [attributeDict valueForKey:@"bind"];
			_first = atoi([[attributeDict valueForKey:@"first"] cStringUsingEncoding:NSUTF8StringEncoding]);
//			NSLog(@"_first:%d",_first);
			_delimeter = [attributeDict valueForKey:@"delimeter"];
		}	
		else if ( [elementName isEqualToString:@"space"]) {
			int count = atoi([[attributeDict valueForKey:@"count"] cStringUsingEncoding:NSUTF8StringEncoding]);
			int i;
			for ( i = 0; i < count; i++ ) {
				[_groupLogic addObject:@""];
				[_groupLabel addObject:@""];
			}
		}
	}
	
	_currentlyParsingTag = elementName;
}

- (void)parser:(NSXMLParser *)parser 
	didEndElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
{
//	NSLog(@"parser:didEndElement:%@",elementName);
	
	// TODO find a nicer way of doing this; it's horrible
	while ( [_groupLabel count] < [_groupLogic count] ) {
		[_groupLabel addObject:@""];	
	}
	
    if ( [elementName isEqualToString:@"group"]) {
		_parsingGroup = NO;
		[_resultLogic addObject:_groupLogic];
		[_resultLabel addObject:_groupLabel];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//	NSLog(@"parser:parserDidEndDocument");
	//int i;
	//for ( i = 0; i < [_resultLogic count]; i++ ) {
	//	NSLog(@"Label: %@      Logic: %@",[_resultLabel objectAtIndex:i],[_resultLogic objectAtIndex:i]);
	//}
	
	if ([_delegate respondsToSelector:@selector(logicXmlFileParserDidCompleteParsing:)]) {
		[_delegate logicXmlFileParserDidCompleteParsing:self];
	}	
	//_ready = YES;
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
//	DLog(@"foundCDATA");
	NSString *cdataString;
	NSString *item;
	cdataString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
//	DLog(@"foundCDATA:%@",cdataString);
	if ( [_currentlyParsingTag isEqualToString:@"item"] ) {
		[_groupLabel addObject:cdataString];
//		[cdataString release];
	}
	else if ( [_currentlyParsingTag isEqualToString:@"sequence"] ) {
		NSArray *contentsArray;	
		int i;
		contentsArray = [cdataString componentsSeparatedByString:_delimeter];
		for ( i = 0; i < [contentsArray count]; i++ ) {
			[_groupLogic addObject:[NSString stringWithFormat:@"%@==%d",_bind,_first+i]];
			item = [contentsArray objectAtIndex:i];
			[_groupLabel addObject:item];
			// release; it's retained by the mutablearray
			// no don't
			//[item release];
		}
	}
	// FIXME check if we have a memory leak with assignign cdtaaString to other pointers
//	DLog(@"cdataString retainCount:%u",[cdataString retainCount]);
	[cdataString release];
}

// ____________________________________________________________________________________________________ delegate

- (void) setDelegate:(id)delegate
{
	[delegate retain];
	if ( _delegate ) {
		[_delegate release];
	}
	_delegate = delegate;
}

- (id)delegate
{
	return _delegate;
}

// ____________________________________________________________________________________________________ delloc

- (void) dealloc {
	if ( _delegate ) {
		[_delegate release];
	}
    if (_parser) {
        [_parser release];
	}
	if ( _groupLogic ) {
		[_groupLogic release];
	}
	if ( _groupLabel ) {
		[_groupLabel release];
	}
	if ( _resultLogic ) {
		[_resultLogic release];
	}
	if ( _resultLabel ) {
		[_resultLabel release];
	}
	[super dealloc];
}

// ____________________________________________________________________________________________________ Getters / Setters

@synthesize logic = _resultLogic;
@synthesize label = _resultLabel;

@end

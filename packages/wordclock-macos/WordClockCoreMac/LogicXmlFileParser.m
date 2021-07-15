//
//  LogicXmlFileParser.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "LogicXmlFileParser.h"
#import "NSXMLParser+App.h"

@interface LogicXmlFileParser ()
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *logic;
@property (nonatomic, retain) NSMutableArray *label;
@property (nonatomic, retain) NSMutableArray *groupLogic;
@property (nonatomic, retain) NSMutableArray *groupLabel;
@property (nonatomic) BOOL parsingGroup;
@property (nonatomic, retain) NSString *bind;
@property (nonatomic, retain) NSString *delimeter;
@property (nonatomic) NSInteger first;
@property (nonatomic, retain) NSString *currentlyParsingTag;

//
//	BOOL _parsingGroup;
//	NSString *_currentlyParsingTag;
//	
//	NSString *_bind;
//	NSString *_delimeter;
//	int _first;
//	
//	id<LogicXmlFileParserDelegate> _delegate;
@end


@implementation LogicXmlFileParser

//@synthesize delegate = _delegate;
//@synthesize logic = _resultLogic;
//@synthesize label = _resultLabel;

// ____________________________________________________________________________________________________ delloc

- (void)dealloc
{
    [_parser release];
    [_groupLogic release];
    [_groupLabel release];
    [_logic release];
    [_label release];
	[super dealloc];
}

-(void)parseFile:(NSString *)pathToFile
{  
    DDLogVerbose(@"pathToFile:%@",pathToFile);
	
    NSURL *xmlURL = [NSURL fileURLWithPath:pathToFile];
	
	self.logic = [[NSMutableArray new] autorelease];
	self.label = [[NSMutableArray new] autorelease];
	self.parsingGroup = NO;
 
    NSData *data = [NSData dataWithContentsOfFile:pathToFile];
    NSError *error = nil;
    id model = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
 	NSArray *groups = model[@"groups"];
    [groups enumerateObjectsUsingBlock:^(NSArray *group, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *groupLogic = [NSMutableArray new];
        NSMutableArray *groupLabel = [NSMutableArray new];
        [group enumerateObjectsUsingBlock:^(NSDictionary *entry, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *type = entry[@"type"];
            if ( [type isEqualToString:@"item"]) {
                NSArray *items = entry[@"items"];
                [items enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *highlight = item[@"highlight"];
                    NSString *text = item[@"text"];
                    [groupLogic addObject:highlight];
                    [groupLabel addObject:text ? text: @""];
                }];
            }
            else if ([type isEqualToString:@"sequence"]) {
                NSString *bind = entry[@"bind"];
                NSUInteger first = [entry[@"first"] unsignedIntegerValue];
                NSArray *textArray = entry[@"text"];
                [textArray enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *highlight = [NSString stringWithFormat:@"%@==%@",bind,@(first+idx)];
                    [groupLogic addObject:highlight];
                    [groupLabel addObject:text];
                }];
            }
            else if ( [type isEqualToString:@"space"]) {
                NSUInteger count = [entry[@"count"] unsignedIntegerValue];
                for ( NSUInteger i = 0; i < count; i++ ) {
                    [groupLogic addObject:@""];
                    [groupLabel addObject:@""];
                }
            }
        }];
        [self.logic addObject:groupLogic];
        [self.label addObject:groupLabel];
    }];
  
  if ([self.delegate respondsToSelector:@selector(logicXmlFileParserDidCompleteParsing:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate logicXmlFileParserDidCompleteParsing:self];
        });
	}
//    dispatch_async([NSXMLParser sharedQueue], ^{
//        NSXMLParser *parser = [[[NSXMLParser alloc] initWithContentsOfURL:xmlURL] autorelease];
//        parser.delegate = self;
//        parser.shouldResolveExternalEntities = NO;
//        [parser parse];
//    });
}

- (void)parser:(NSXMLParser *)parser 
	didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
//	DDLogVerbose(@"parser:didStartElement:%@",elementName);
	
   if ( [elementName isEqualToString:@"group"]) {
		self.parsingGroup = YES;
		self.groupLogic = [[NSMutableArray new] autorelease];
		self.groupLabel = [[NSMutableArray new] autorelease];
	}
	
	if ( self.parsingGroup ) {
		if ( [elementName isEqualToString:@"item"]) {
			[self.groupLogic addObject:[attributeDict valueForKey:@"highlight"]];
		}	
		else if ( [elementName isEqualToString:@"sequence"]) {
			self.bind = [attributeDict valueForKey:@"bind"];
			self.first = atoi([[attributeDict valueForKey:@"first"] cStringUsingEncoding:NSUTF8StringEncoding]);
//			DDLogVerbose(@"_first:%d",_first);
			self.delimeter = [attributeDict valueForKey:@"delimeter"];
		}	
		else if ( [elementName isEqualToString:@"space"]) {
			NSInteger count = atoi([[attributeDict valueForKey:@"count"] cStringUsingEncoding:NSUTF8StringEncoding]);
			for ( NSInteger i = 0; i < count; i++ ) {
				[self.groupLogic addObject:@""];
				[self.groupLabel addObject:@""];
			}
		}
	}
	
	self.currentlyParsingTag = elementName;
}

- (void)parser:(NSXMLParser *)parser 
	didEndElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
{
//	DDLogVerbose(@"parser:didEndElement:%@",elementName);
	
	// TODO find a nicer way of doing this; it's horrible
	while ( [self.groupLabel count] < [self.groupLogic count] ) {
		[self.groupLabel addObject:@""];
	}
	
    if ( [elementName isEqualToString:@"group"]) {
		self.parsingGroup = NO;
		[self.logic addObject:_groupLogic];
		[self.label addObject:_groupLabel];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//	DDLogVerbose(@"parser:parserDidEndDocument");
	//int i;
	//for ( i = 0; i < [_resultLogic count]; i++ ) {
	//	DDLogVerbose(@"Label: %@      Logic: %@",[_resultLabel objectAtIndex:i],[_resultLogic objectAtIndex:i]);
	//}
 
 DDLogVerbose(@"self.logic:%@",self.logic);
  DDLogVerbose(@"self.label:%@",self.label);
 
	if ([self.delegate respondsToSelector:@selector(logicXmlFileParserDidCompleteParsing:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate logicXmlFileParserDidCompleteParsing:self];
        });
	}	
	//_ready = YES;
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
//	DDLogVerbose(@"foundCDATA");
	NSString *cdataString;
	NSString *item;
	cdataString = [[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding] autorelease];
//	DDLogVerbose(@"foundCDATA:%@",cdataString);
	if ( [self.currentlyParsingTag isEqualToString:@"item"] ) {
		[self.groupLabel addObject:cdataString];
//		[cdataString release];
	}
	else if ( [self.currentlyParsingTag isEqualToString:@"sequence"] ) {
		NSArray *contentsArray;	
		contentsArray = [cdataString componentsSeparatedByString:self.delimeter];
		for ( NSInteger i = 0; i < [contentsArray count]; i++ ) {
			[self.groupLogic addObject:[NSString stringWithFormat:@"%@==%@",self.bind,@(self.first+i)]];
			item = contentsArray[i];
			[self.groupLabel addObject:item];
			// release; it's retained by the mutablearray
			// no don't
			//[item release];
		}
	}
	// FIXME check if we have a memory leak with assignign cdtaaString to other pointers
//	DDLogVerbose(@"cdataString retainCount:%u",[cdataString retainCount]);
//	[cdataString release];
}



// ____________________________________________________________________________________________________ Getters / Setters


@end

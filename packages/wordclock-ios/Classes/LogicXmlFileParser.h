//
//  LogicXmlFileParser.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//


#import "DLog.h"

@interface LogicXmlFileParser : NSObject {
	NSXMLParser	*_parser;
	NSMutableArray *_resultLogic;
	NSMutableArray *_resultLabel;
	NSMutableArray *_groupLogic;
	NSMutableArray *_groupLabel;
	
	BOOL _parsingGroup;
	NSString *_currentlyParsingTag;
	
	NSString *_bind;
	NSString *_delimeter;
	int _first;
	
	id _delegate;		
}
- (void)setDelegate:(id)delegate;
- (id)delegate;
- (void)parseFile:(NSString *)pathToFile;

@property (readonly) NSMutableArray *logic;
@property (readonly) NSMutableArray *label;

@end


@interface LogicXmlFileParser(LogicXmlFileParserDelegate)
- (void)logicXmlFileParserDidCompleteParsing:(LogicXmlFileParser*)parser;
@end

//
//  LogicXmlFileParser.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//


@protocol LogicXmlFileParserDelegate;

@interface LogicXmlFileParser : NSObject <NSXMLParserDelegate> {
//	NSXMLParser	*_parser;
//	NSMutableArray *_resultLogic;
//	NSMutableArray *_resultLabel;
//	NSMutableArray *_groupLogic;
//	NSMutableArray *_groupLabel;
//	
//	BOOL _parsingGroup;
//	NSString *_currentlyParsingTag;
//	
//	NSString *_bind;
//	NSString *_delimeter;
//	int _first;
//	
//	id<LogicXmlFileParserDelegate> _delegate;		
}
- (void)parseFile:(NSString *)pathToFile;
@property (nonatomic, assign) id<LogicXmlFileParserDelegate> delegate;
//@property (readonly) NSMutableArray *logic;
//@property (readonly) NSMutableArray *label;
@property (nonatomic, retain, readonly) NSMutableArray *logic;
@property (nonatomic, retain, readonly) NSMutableArray *label;

@end


@protocol LogicXmlFileParserDelegate <NSObject>
- (void)logicXmlFileParserDidCompleteParsing:(LogicXmlFileParser*)parser;
@end

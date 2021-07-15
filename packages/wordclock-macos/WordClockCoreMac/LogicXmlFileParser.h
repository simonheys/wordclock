//
//  LogicXmlFileParser.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

@protocol LogicXmlFileParserDelegate;

@interface LogicXmlFileParser : NSObject <NSXMLParserDelegate> {
}
- (void)parseFile:(NSString *)pathToFile;
@property (nonatomic, assign) id<LogicXmlFileParserDelegate> delegate;
@property (nonatomic, retain, readonly) NSMutableArray *logic;
@property (nonatomic, retain, readonly) NSMutableArray *label;
@end

@protocol LogicXmlFileParserDelegate <NSObject>
- (void)logicXmlFileParserDidCompleteParsing:(LogicXmlFileParser*)parser;
@end

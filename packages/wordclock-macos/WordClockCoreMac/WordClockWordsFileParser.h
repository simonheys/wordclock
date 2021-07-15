//
//  WordClockWordsFileParser.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

@protocol WordClockWordsFileParserDelegate;

@interface WordClockWordsFileParser : NSObject <NSXMLParserDelegate> {
}
- (void)parseFile:(NSString *)pathToFile;
@property (nonatomic, assign) id<WordClockWordsFileParserDelegate> delegate;
@property (nonatomic, retain, readonly) NSMutableArray *logic;
@property (nonatomic, retain, readonly) NSMutableArray *label;
@end

@protocol WordClockWordsFileParserDelegate <NSObject>
- (void)wordClockWordsFileParserDidCompleteParsing:(WordClockWordsFileParser*)parser;
@end

//
//  WordClockXmlFileParser.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *WordClockLinearDisplayType;
extern NSString *WordClockRotaryDisplayType;

@protocol WordClockWordsManifestFileParserDelegate;

@interface WordClockWordsManifestFileParser : NSObject
@property (nonatomic, retain) NSMutableArray *xmlFiles;
@property (nonatomic, assign) id <WordClockWordsManifestFileParserDelegate> delegate;
- (void)parseManifestFile;
@end

@protocol WordClockWordsManifestFileParserDelegate <NSObject>
- (void)wordClockWordsManifestFileParserDidCompleteParsingManifest:(WordClockWordsManifestFileParser*)parser;
@end



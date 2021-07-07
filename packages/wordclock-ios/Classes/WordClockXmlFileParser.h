//
//  WordClockXmlFileParser.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLog.h"

extern NSString *WordClockLinearDisplayType;
extern NSString *WordClockRotaryDisplayType;

@interface WordClockXmlFileParser : NSObject {
	NSMutableArray *_xmlManifestFiles;
	NSMutableArray *_xmlManifestLanguageCode;
	NSMutableArray *_xmlManifestLanguageTitle;
	NSMutableArray *_xmlFiles;
	NSMutableArray *_xmlFilesRotary;
	NSMutableArray *_xmlFilesLinear;
	
	int _currentXmlFile;
	
	NSString *_currentlyParsingTag;
	NSString *_language;
	id _delegate;		
	NSXMLParser	*_manifestParser;
	NSXMLParser	*_parser;
	
	NSString *_manifestFile;
}

@property (nonatomic, retain) NSString *manifestFile;

+ (WordClockXmlFileParser*)sharedInstance;
- (void)setDelegate:(id)delegate;
- (id)delegate;
- (void)parseManifestFile;
- (NSString *)languageTitleForCode:(NSString *)code;
- (NSArray *)arrayOfLanguageStrings;
- (NSArray *)arrayOfLanguageCodesForDisplayType:(NSString *)displayType;
- (void)parseXmlFiles;
- (void)parseNextXmlFile;
- (void)parseFile:(NSString *)pathToFile;
- (NSArray *)arrayOfXmlFileLanguageCodes;
- (NSString *)languageTitleForIndex:(int)i;
- (NSArray *)xmlFiles;
- (void)continueWithNextXmlFile;
@end

@interface WordClockXmlFileParser(WordClockXmlFileParserDelegate)
- (void)wordClockXmlFileParserDidCompleteParsingManifest:(WordClockXmlFileParser*)parser;
@end

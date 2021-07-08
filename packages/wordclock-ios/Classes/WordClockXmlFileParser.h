//
//  WordClockXmlFileParser.h
//  iphone_word_clock
//
//  Created by Simon on 23/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *WordClockLinearDisplayType;
extern NSString *WordClockRotaryDisplayType;

@protocol WordClockXmlFileParserDelegate;

@interface WordClockXmlFileParser : NSObject {
//@private
//	NSMutableArray *_xmlManifestFiles;
//	NSMutableArray *_xmlManifestLanguageCode;
//	NSMutableArray *_xmlManifestLanguageTitle;
//	NSMutableArray *_xmlFilesRotary;
//	NSMutableArray *_xmlFilesLinear;
//
//	NSMutableArray *_xmlFiles;
//    NSXMLParser *_parser;
//
//	int _currentXmlFile;
//
//	NSString *_currentlyParsingTag;
//	NSString *_language;
//	id <WordClockXmlFileParserDelegate> _delegate;
//	NSXMLParser	*_manifestParser;
//
//	NSString *_manifestFile;
    
}

@property (nonatomic, retain) NSString *manifestFile;
@property (nonatomic, retain) NSMutableArray *xmlFiles;
@property (nonatomic, assign) id <WordClockXmlFileParserDelegate> delegate;

- (void)parseManifestFile;
- (NSString *)languageTitleForCode:(NSString *)code;
- (NSArray *)arrayOfLanguageStrings;
- (NSArray *)arrayOfLanguageCodesForDisplayType:(NSString *)displayType;
- (void)parseXmlFiles;
- (void)parseNextXmlFile;
- (void)parseFile:(NSString *)pathToFile;
- (NSArray *)arrayOfXmlFileLanguageCodes;
- (NSString *)languageTitleForIndex:(int)i;
- (void)continueWithNextXmlFile;
@end

@protocol WordClockXmlFileParserDelegate <NSObject>
- (void)wordClockXmlFileParserDidCompleteParsingManifest:(WordClockXmlFileParser*)parser;
@end

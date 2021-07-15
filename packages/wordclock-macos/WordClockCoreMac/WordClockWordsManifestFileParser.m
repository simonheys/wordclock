//
//  WordClockXmlFileParser.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockWordsManifestFileParser.h"

NSString *WordClockLinearDisplayType = @"linear";
NSString *WordClockRotaryDisplayType = @"rotary";

@interface WordClockWordsManifestFileParser () <NSXMLParserDelegate>
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *xmlManifestLanguageCode;
@property (nonatomic, retain) NSMutableArray *xmlManifestLanguageTitle;
@end

@implementation WordClockWordsManifestFileParser

// ____________________________________________________________________________________________________ delloc

- (void)dealloc
{
    [_xmlFiles release];
    [_xmlManifestLanguageCode release];
    [_xmlManifestLanguageTitle release];
	[super dealloc];
}

// ____________________________________________________________________________________________________ Parse

- (void)parseManifestFile
{
	self.xmlFiles = [[NSMutableArray new] autorelease];
	self.xmlManifestLanguageCode = [[NSMutableArray new] autorelease];
	self.xmlManifestLanguageTitle = [[NSMutableArray new] autorelease];

    NSBundle *thisBundle = [self bundle];
    NSString *path = [thisBundle pathForResource:@"Manifest" ofType:@"json" inDirectory:@"json"];
    
    DDLogVerbose(@"path:%@",path);
	NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    id model = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
    if ( nil != error ) {
        DDLogError(@"error:%@",error);
    }
    DDLogVerbose(@"model:%@",model);
    
    NSDictionary *languages = model[@"languages"];
    [languages enumerateKeysAndObjectsUsingBlock:^(NSString *code, NSString *languageTitle, BOOL * _Nonnull stop) {
        DDLogVerbose(@"code:%@ languageTitle:%@",code,languageTitle);
        [self.xmlManifestLanguageCode addObject:code];
        [self.xmlManifestLanguageTitle addObject:languageTitle];
    }];
    
    NSArray *files = model[@"files"];
    [files enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        @try {
            NSString *path = [thisBundle pathForResource:fileName ofType:nil inDirectory:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSError *error = nil;
            id model = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
            id meta = model[@"meta"];
            if ( meta) {
                NSDictionary *fileDictionary = @{
                    @"fileName": fileName,
                    @"fileTitle": meta[@"title"],
                    @"fileLanguageCode": meta[@"language"],
                    @"fileLanguageTitle": languages[meta[@"language"]]
                };
                [self.xmlFiles addObject:fileDictionary];
            }
        } @catch (NSException *exception) {
            DDLogError(@"Error parsing:%@",exception);
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(wordClockWordsManifestFileParserDidCompleteParsingManifest:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate wordClockWordsManifestFileParserDidCompleteParsingManifest:self];
        });
    }
}

//____________________________________________________________________________________________________ xml files

- (NSBundle *)bundle
{
#ifdef SCREENSAVER
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
#else
	NSBundle *bundle = [NSBundle mainBundle];
#endif
    return bundle;
}

@end

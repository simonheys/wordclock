//
//  WordClockXmlFileParser.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockXmlFileParser.h"
#import "NSXMLParser+App.h"

NSString *WordClockLinearDisplayType = @"linear";
NSString *WordClockRotaryDisplayType = @"rotary";

@interface WordClockXmlFileParser () <NSXMLParserDelegate>
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *xmlManifestFiles;
@property (nonatomic, retain) NSMutableArray *xmlManifestLanguageCode;
@property (nonatomic, retain) NSMutableArray *xmlManifestLanguageTitle;
@property (nonatomic, retain) NSMutableArray *xmlFilesRotary;
@property (nonatomic, retain) NSMutableArray *xmlFilesLinear;
@property (nonatomic, retain) NSString *currentlyParsingTag;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSXMLParser *manifestParser;
@property (nonatomic) NSInteger currentXmlFile;
@end

@implementation WordClockXmlFileParser

// ____________________________________________________________________________________________________ delloc

- (void)dealloc
{
    [_manifestFile release];
    [_parser release];
    [_xmlFiles release];
    [_manifestParser release];
    [_xmlManifestFiles release];
    [_xmlManifestLanguageCode release];
    [_xmlManifestLanguageTitle release];
    [_xmlFilesRotary release];
    [_xmlFilesLinear release];
	[super dealloc];
}

// ____________________________________________________________________________________________________ Parse

- (void)parseManifestFile
{
//    __block NSURL *xmlURL = [NSURL fileURLWithPath:self.manifestFile];
	
	self.xmlManifestFiles = [[NSMutableArray new] autorelease];
	self.xmlManifestLanguageCode = [[NSMutableArray new] autorelease];
	self.xmlManifestLanguageTitle = [[NSMutableArray new] autorelease];
	self.xmlFilesRotary = [[NSMutableArray new] autorelease];
	self.xmlFilesLinear = [[NSMutableArray new] autorelease];
	
	self.xmlFiles = [[NSMutableArray new] autorelease];
    
    dispatch_async([NSXMLParser sharedQueue], ^{
        NSURL *xmlURL = [NSURL fileURLWithPath:self.manifestFile];
        NSXMLParser *manifestParser = [[[NSXMLParser alloc] initWithContentsOfURL:xmlURL] autorelease];
        self.manifestParser = manifestParser;
        manifestParser.delegate = self;
        manifestParser.shouldResolveExternalEntities = NO;
        [manifestParser parse];
    });
    
	DDLogVerbose(@"parseManifestFile:done");			
//	[apool release];
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

-(void)parseXmlFiles
{
	self.currentXmlFile = 0;
	[self parseNextXmlFile];
}

-(void)parseNextXmlFile
{
	NSBundle *thisBundle = [self bundle];
	[self parseFile:[thisBundle pathForResource:self.xmlManifestFiles[self.currentXmlFile] ofType:nil inDirectory:@"xml"]];
//	[thisBundle release];
}

-(void)parseFile:(NSString *)pathToFile
{
	NSData *xmlData = [NSData dataWithContentsOfFile:pathToFile];	
    dispatch_async([NSXMLParser sharedQueue], ^{
        NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:xmlData] autorelease];
        if ( nil != parser ) {
            [parser setDelegate:self];
            [parser setShouldResolveExternalEntities:NO];
            [parser parse];
        }
        else {
            [self continueWithNextXmlFile];
        }
    });
}

- (void)parser:(NSXMLParser *)parser 
	didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
//	DDLogVerbose(@"parser:didStartElement:%@",elementName);
	NSString *value;
	
	self.currentlyParsingTag = elementName;
	if ( [parser isEqual:self.manifestParser] ) {
		if ( [elementName isEqualToString:@"language"]) {
			// value is reelease because it's retained by the array
			value = [attributeDict valueForKey:@"code"];
			[self.xmlManifestLanguageCode addObject:value];
//			[value release];
			value = [attributeDict valueForKey:@"title"];
			[self.xmlManifestLanguageTitle addObject:value];
//			[value release];
		}
	}
	else {
		if ( [elementName isEqualToString:@"wordclock"]) {
			
			self.language = [attributeDict valueForKey:@"language"];
			// TODO implement suitability
			
		}	
	}
}

- (void)parser:(NSXMLParser *)parser 
	didEndElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
{
//	DDLogVerbose(@"parser:didEndElement:%@",elementName);
	self.currentlyParsingTag = @"";
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//	DDLogVerbose(@"parser:parserDidEndDocument");
	//int i;
	//for ( i = 0; i < [self.resultLogic count]; i++ ) {
	//	DDLogVerbose(@"Label: %@      Logic: %@",[self.resultLabel objectAtIndex:i],[self.resultLogic objectAtIndex:i]);
	//}
//    @weakify(self);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @strongify(self);
        if ( [parser isEqual:self.manifestParser] ) {
            [self parseXmlFiles];
        }
        else {
            [self continueWithNextXmlFile];
        }
//    });
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	DDLogVerbose(@"Error %i, Description: %@, Line: %i, Column: %i", 
		[parseError code],
        [[parser parserError] localizedDescription], 
		[parser lineNumber],
        [parser columnNumber]
	);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
	DDLogVerbose(@"Error %i, Description: %@, Line: %i, Column: %i", 
		[validError code],
        [[parser parserError] localizedDescription], 
		[parser lineNumber],
        [parser columnNumber]
	);
}

- (void)continueWithNextXmlFile
{
	self.currentXmlFile++;
	if ( self.currentXmlFile < [self.xmlManifestFiles count] ) {
		[self parseNextXmlFile];
	}
	else {
		if ([self.delegate respondsToSelector:@selector(wordClockXmlFileParserDidCompleteParsingManifest:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate wordClockXmlFileParserDidCompleteParsingManifest:self];
            });
		}
		DDLogVerbose(@"continueWithNextXmlFile:done");			
	}		
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if ( [parser isEqual:self.manifestParser] ) {
		if ( [self.currentlyParsingTag isEqualToString:@"file"] ) {
			[self.xmlManifestFiles addObject:string];
			// release becasue it's retained by the array
//			[string release];
		}
	}
}


- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	NSString *cdataString;
	cdataString = [[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding] autorelease];
//    DDLogVerbose(@"foundCDATA:<<<<%@>>>>",cdataString);
	if ( [parser isEqual:self.manifestParser] ) {
		if ( [self.currentlyParsingTag isEqualToString:@"item"] ) {
		}
		else if ( [self.currentlyParsingTag isEqualToString:@"sequence"] ) {
		}
	}
	else {
		if ( [self.currentlyParsingTag isEqualToString:@"title"] ) {
			NSDictionary *fileDictionary = [[[NSDictionary alloc] initWithObjectsAndKeys:
				self.xmlManifestFiles[self.currentXmlFile], @"fileName",
				cdataString, @"fileTitle",
				self.language, @"fileLanguageCode",
				[self languageTitleForCode:self.language], @"fileLanguageTitle",
				nil
			] autorelease];
			[self.xmlFiles addObject:fileDictionary];
		}
	}
}

// ____________________________________________________________________________________________________ Interrogate


// return array of langauges and display names for each
- (NSArray *)arrayOfLanguageStrings
{
	return self.xmlManifestLanguageTitle;
}

// return array of langauges and display names for each
- (NSArray *)arrayOfLanguageCodesForDisplayType:(NSString *)displayType
{
	NSString *alreadyAdded;
	NSString *code;
	NSMutableArray *result;
	alreadyAdded = @"";
	result = [[NSMutableArray new] autorelease];
	for ( int i = 0; i < [self.xmlFiles count]; i++ ) {
		code = (self.xmlFiles)[i][2];
		DDLogVerbose(@"code:%@",code);
		if ( [alreadyAdded rangeOfString:code].location == NSNotFound ) {
			alreadyAdded = [NSString stringWithFormat:@"%@,%@",alreadyAdded,code];
			[result addObject:code];
		}
	}
			
	return result;
}

-(NSArray *)arrayOfXmlFileLanguageCodes
{
	return self.xmlManifestLanguageCode;
}

- (NSString *)languageTitleForIndex:(int)i
{
	return self.xmlManifestLanguageTitle[i];
}


- (NSString *)languageTitleForCode:(NSString *)code
{
	for ( int i = 0; i < [self.xmlManifestLanguageCode count]; i++ ) {
		if ( [self.xmlManifestLanguageCode[i] isEqualToString:code] ) {
			return self.xmlManifestLanguageTitle[i];
		}
	}
	return @"<undefined>";
}

@end

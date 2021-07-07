//
//  WordClockXmlFileParser.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockXmlFileParser.h"

NSString *WordClockLinearDisplayType = @"linear";
NSString *WordClockRotaryDisplayType = @"rotary";

@implementation WordClockXmlFileParser

@synthesize manifestFile = _manifestFile;

// ____________________________________________________________________________________________________ Parse

-(void)parseManifestFile
{
//	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];

	BOOL success;	

    NSURL *xmlURL = [NSURL fileURLWithPath:_manifestFile];
    if (_manifestParser) {
		// addressParser is an NSXMLParser instance variable
        [_manifestParser release];
	}
	
	_xmlManifestFiles = [[NSMutableArray alloc] init];
	_xmlManifestLanguageCode = [[NSMutableArray alloc] init];
	_xmlManifestLanguageTitle = [[NSMutableArray alloc] init];
	_xmlFiles = [[NSMutableArray alloc] init];
	_xmlFilesRotary = [[NSMutableArray alloc] init];
	_xmlFilesLinear = [[NSMutableArray alloc] init];
	
    _manifestParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [_manifestParser setDelegate:self];
    [_manifestParser setShouldResolveExternalEntities:NO];
    success = [_manifestParser parse]; // return value not used
	
	DLog(@"parseManifestFile:done");			
//	[apool release];
}

//____________________________________________________________________________________________________ xml files


-(void)parseXmlFiles
{
	_currentXmlFile = 0;
	[self parseNextXmlFile];
}

-(void)parseNextXmlFile
{
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	DLog(@"lookign for:%@",[_xmlManifestFiles objectAtIndex:_currentXmlFile]);
	[self parseFile:[thisBundle pathForResource:[_xmlManifestFiles objectAtIndex:_currentXmlFile] ofType:nil]];
//	[thisBundle release];
}

-(void)parseFile:(NSString *)pathToFile
{
	BOOL success;
	
    if (_parser) {
//        [_parser release];
	}

	DLog(@"parseFile:%@",pathToFile);

	NSData *xmlData = [NSData dataWithContentsOfFile:pathToFile];
	
    _parser = [[NSXMLParser alloc] initWithData:xmlData];
	if ( nil != _parser ) {
		[_parser setDelegate:self];
		[_parser setShouldResolveExternalEntities:NO];
		success = [_parser parse]; // return value not us
		if (success) {
			DLog(@"No Errors:%@",pathToFile);
		} 
		else {
			DLog(@"Error parsing XML file:%@",pathToFile);
		}
	}
	else {
		[self continueWithNextXmlFile];
	}
//	[xmlData release];
}

- (void)parser:(NSXMLParser *)parser 
	didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict 
{
//	DLog(@"parser:didStartElement:%@",elementName);
	NSString *value;
	
	_currentlyParsingTag = elementName;
	if ( [parser isEqual:_manifestParser] ) {
//		DLog(@"parsing manifest");
		if ( [elementName isEqualToString:@"language"]) {
//			DLog(@"adding language");
			// value is reelease because it's retained by the array
			value = [attributeDict valueForKey:@"code"];
			[_xmlManifestLanguageCode addObject:value];
//			[value release];
			value = [attributeDict valueForKey:@"title"];
			[_xmlManifestLanguageTitle addObject:value];
//			[value release];
		}
	}
	else {
		if ( [elementName isEqualToString:@"wordclock"]) {
			
			_language = [attributeDict valueForKey:@"language"];
			// TODO implement suitability
			
		}	
	}
}

- (void)parser:(NSXMLParser *)parser 
	didEndElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
{
//	NSLog(@"parser:didEndElement:%@",elementName);
	_currentlyParsingTag = @"";
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//	DLog(@"parser:parserDidEndDocument");
	//int i;
	//for ( i = 0; i < [_resultLogic count]; i++ ) {
	//	NSLog(@"Label: %@      Logic: %@",[_resultLabel objectAtIndex:i],[_resultLogic objectAtIndex:i]);
	//}
	
	if ( [parser isEqual:_manifestParser] ) {
		[self parseXmlFiles];
	}
	else {
		[self continueWithNextXmlFile];
	}
	//_ready = YES;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	DLog(@"Error %i, Description: %@, Line: %i, Column: %i", 
		[parseError code],
        [[parser parserError] localizedDescription], 
		[parser lineNumber],
        [parser columnNumber]
	);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
	DLog(@"Error %i, Description: %@, Line: %i, Column: %i", 
		[validError code],
        [[parser parserError] localizedDescription], 
		[parser lineNumber],
        [parser columnNumber]
	);
}

- (void)continueWithNextXmlFile
{
	_currentXmlFile++;
	if ( _currentXmlFile < [_xmlManifestFiles count] ) {
		[self parseNextXmlFile];
	}
	else {
		if ([_delegate respondsToSelector:@selector(wordClockXmlFileParserDidCompleteParsingManifest:)]) {
			[_delegate wordClockXmlFileParserDidCompleteParsingManifest:self];
		}
		DLog(@"continueWithNextXmlFile:done");			
	}		
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//	DLog(@"foundCharacters:%@",string);		
	if ( [parser isEqual:_manifestParser] ) {
		if ( [_currentlyParsingTag isEqualToString:@"file"] ) {
			DLog(@"adding file:%@",string);
			[_xmlManifestFiles addObject:string];
			// release becasue it's retained by the array
			//[string release];
		}
	}
}


- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	NSString *cdataString;
	cdataString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
//	DLog(@"foundCDATA:<<<<%@>>>>",cdataString);
	if ( [parser isEqual:_manifestParser] ) {
		if ( [_currentlyParsingTag isEqualToString:@"item"] ) {
		}
		else if ( [_currentlyParsingTag isEqualToString:@"sequence"] ) {
		}
	}
	else {
		if ( [_currentlyParsingTag isEqualToString:@"title"] ) {
			NSDictionary *fileDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
				[_xmlManifestFiles objectAtIndex:_currentXmlFile], @"fileName",
				cdataString, @"fileTitle",
				_language, @"fileLanguageCode",
				[self languageTitleForCode:_language], @"fileLanguageTitle",
				nil
			];
				/*
			NSArray *o = [NSArray arrayWithObjects:
				[_xmlManifestFiles objectAtIndex:_currentXmlFile],
				cdataString,
				_language,
				nil
			];
			*/
			[_xmlFiles addObject:fileDictionary];
			// release because it's retained by the array
			[fileDictionary release];
		}	
	}
	// FIXME check if we have a memory leak with assignign cdtaaString to other pointers
	[cdataString release];
}

// ____________________________________________________________________________________________________ Interrogate


// return array of langauges and display names for each
- (NSArray *)arrayOfLanguageStrings
{
	return _xmlManifestLanguageTitle;
}

// return array of langauges and display names for each
- (NSArray *)arrayOfLanguageCodesForDisplayType:(NSString *)displayType
{
	NSString *alreadyAdded;
	NSString *code;
	NSMutableArray *result;
	alreadyAdded = @"";
	result = [[NSMutableArray alloc] init];
	for ( int i = 0; i < [_xmlFiles count]; i++ ) {
		code = [[_xmlFiles objectAtIndex:i] objectAtIndex:2];
		NSLog(@"code:%@",code);
		if ( [alreadyAdded rangeOfString:code].location == NSNotFound ) {
			alreadyAdded = [NSString stringWithFormat:@"%@,%@",alreadyAdded,code];
			//[result addObject:[self languageTitleForCode:code]];
			[result addObject:code];
			// release because it's retained by the array
//			[code release];
		}
	}
			
	// TODO implement suitability
	return [result autorelease];
}

-(NSArray *)arrayOfXmlFileLanguageCodes
{
	return _xmlManifestLanguageCode;
}

- (NSString *)languageTitleForIndex:(int)i
{
	return [_xmlManifestLanguageTitle objectAtIndex:i];
}


- (NSString *)languageTitleForCode:(NSString *)code
{
	for ( int i = 0; i < [_xmlManifestLanguageCode count]; i++ ) {
		if ( [[_xmlManifestLanguageCode objectAtIndex:i] isEqualToString:code] ) {
			return [_xmlManifestLanguageTitle objectAtIndex:i];
		}
	}
	return @"<undefined>";
}

- (NSArray *)xmlFiles
{
	return _xmlFiles;
}

// ____________________________________________________________________________________________________ Singleton

static WordClockXmlFileParser *sharedWordClockXmlFileParserInstance = nil;

+ (WordClockXmlFileParser*)sharedInstance
{
    @synchronized(self) {
        if (sharedWordClockXmlFileParserInstance == nil) {
//			DLog(@"******* making  sharedInstance *******");
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedWordClockXmlFileParserInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedWordClockXmlFileParserInstance == nil) {
            sharedWordClockXmlFileParserInstance = [super allocWithZone:zone];
            return sharedWordClockXmlFileParserInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

// ____________________________________________________________________________________________________ delegate

- (void) setDelegate:(id)delegate
{
	[delegate retain];
	if ( _delegate ) {
		[_delegate release];
	}
	_delegate = delegate;
}

- (id)delegate
{
	return _delegate;
}

// ____________________________________________________________________________________________________ delloc

- (void) dealloc {
	if ( _delegate ) {
		[_delegate release];
	}
    if (_manifestParser) {
        [_manifestParser release];
	}
    if (_parser) {
        [_parser release];
	}	
	if ( _xmlManifestFiles ) {
		[_xmlManifestFiles release];
	}
	if ( _xmlManifestLanguageCode ) {
		[_xmlManifestLanguageCode release];
	}
	if ( _xmlManifestLanguageTitle ) {
		[_xmlManifestLanguageTitle release];
	}
	if ( _xmlFiles ) {
		[_xmlFiles release];
	}
	if ( _xmlFilesRotary ) {
		[_xmlFilesRotary release];
	}
	if ( _xmlFilesLinear ) {
		[_xmlFilesLinear release];
	}
	[super dealloc];
}
@end

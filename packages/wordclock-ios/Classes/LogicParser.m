//
//  LogicParser.m
//  iphone_word_clock
//
//  Created by Simon on 16/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LogicParser.h"
#import "LogicParserStringUtil.h"

NSString *LogicParserOperators = @"!%&*()-+=|/<>";

@implementation LogicParser

// ____________________________________________________________________________________________________ Singleton

static LogicParser *shareNSLogicParserInstance = nil;

+ (LogicParser*)sharedInstance
{
    @synchronized(self) {
        if (shareNSLogicParserInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return shareNSLogicParserInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (shareNSLogicParserInstance == nil) {
            shareNSLogicParserInstance = [super allocWithZone:zone];
            return shareNSLogicParserInstance;  // assignment and return on first allocation
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

// ____________________________________________________________________________________________________ Init

+ (void)initialize
{
	LogicParserEqualityOperators = [[NSArray arrayWithObjects:@"==", @"!=", @">=", @"<=", @">", @"<", nil] retain];
	LogicParserMathOperators = [[NSArray arrayWithObjects:@"%", @"*", @"/", @"+", @"-", nil] retain];
	LogicParserBooleanOperators = [[NSArray arrayWithObjects:@"&&", @"||", nil] retain];
	LogicParserConversionOperators = [[NSArray arrayWithObjects:@"-", @"!", nil] retain];
}

-(int)parse:(NSString *)source
{
//	NSLog(@"------------------------");
//	NSLog(@"parse:<<<<%@>>>>",source);
	if ( ![LogicParserStringUtil checkBalancedBraces:source]) {
		NSLog(@"Syntax Error: mismatching braces: %@",source);
		return 0;
	}
	return [self processTerm:[self term:source]];
}

// ____________________________________________________________________________________________________ delloc

- (void) dealloc {
	[LogicParserEqualityOperators release];
	[LogicParserMathOperators release];
	[LogicParserBooleanOperators release];
	[LogicParserConversionOperators release];
	[super dealloc];
}


// ____________________________________________________________________________________________________ Term

-(NSString *)term:(NSString *)source
{
	NSArray *terms;
	BOOL parsing;
	int result;
			
//	NSLog(@"term input:<%@>",source);
		
	parsing = YES;
			
	while ( parsing )
	{
		// parse brackets
		if ( [LogicParserStringUtil containsBraces:source]) {
			terms = [LogicParserStringUtil extractStringContainedInOutermostBraces:source];
//			NSLog(@"extracted braces:%@",terms);
			source = [NSString 
				stringWithFormat:@"%@%@%@",
				[terms objectAtIndex:0], 
				[self term:[terms objectAtIndex:1]],
				[terms objectAtIndex:2]
			];
		}
		else {
			// parse math operators
			result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserMathOperators];
			if ( result !=-1 ) {
				terms = [LogicParserStringUtil 
					extractTermsAroundPivot:source 
					pivot:[LogicParserMathOperators objectAtIndex:result]
				];//  MATH_OPERATORS[result]);
				source = [NSString
					stringWithFormat:@"%@%@%@",
					[terms objectAtIndex:0], 
					[self 
						performOperationOnTermOne:[terms objectAtIndex:1]
						termTwo:[terms objectAtIndex:2]
						operator:[LogicParserMathOperators objectAtIndex:result]
					],
					[terms objectAtIndex:3]
				];
				//  terms[0]+performOperation(terms[1],terms[2],MATH_OPERATORS[result])+terms[3];
				//trace(terms);				
			}
			else {
				// parse equality operators	
				result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserEqualityOperators];
				if ( result !=-1 ) {
					terms = [LogicParserStringUtil 
						extractTermsAroundPivot:source
						pivot:[LogicParserEqualityOperators objectAtIndex:result]
					];
					source = [NSString
						stringWithFormat:@"%@%@%@",
						[terms objectAtIndex:0], 
						[self 
							performOperationOnTermOne:[terms objectAtIndex:1]
							termTwo:[terms objectAtIndex:2]
							operator:[LogicParserEqualityOperators objectAtIndex:result]
						],
						[terms objectAtIndex:3]
					];
					//source = terms[0]+performOperation(terms[1],terms[2],EQUALITY_OPERATORS[result])+terms[3];
					//trace(terms);				
				}
				else {
					// parse boolean operators	
					result = [LogicParserStringUtil 
						scanForInstanceOf:source
						inArray:LogicParserBooleanOperators
					];
					if ( result !=-1 ) {
						terms = [LogicParserStringUtil
							extractTermsAroundPivot:source 
							pivot:[LogicParserBooleanOperators objectAtIndex:result]
						];
						source = [NSString
							stringWithFormat:@"%@%@%@",
							[terms objectAtIndex:0], 
							[self 
								performOperationOnTermOne:[terms objectAtIndex:1]
								termTwo:[terms objectAtIndex:2]
								operator:[LogicParserBooleanOperators objectAtIndex:result]
							],
							[terms objectAtIndex:3]
						];
					}
					else {
						parsing = NO;
					}
				}
			}
		}	
	}
//	NSLog(@"term output:<%@>",source);
	return source;
}


// ____________________________________________________________________________________________________ Process

// check for var names, - and !
-(int)processTerm:(NSString *)source
{
//	NSLog(@"processTerm:%@",source);
	int result;
	source = [LogicParserStringUtil trim:source];// StringUtils.trim(source);
	
	
	if ( [source length] == 1 ) {
//		NSLog(@"returning:%d",[source intValue]);
		return [source intValue];
	}
	
	// FIXME a minus sign causes infinite recursion at present
	// because we repeatedly have a term starting "-"
	// and recursively subtract it from 0
	// a hack might just be to have a flag checking for this special case
	if ( [source characterAtIndex:0] == '-') { 
		return 0-[self processTerm:[source substringFromIndex:1]];
	}
	if ( [source characterAtIndex:1] == '!' ) {
		result = [self processTerm:[source substringFromIndex:1]];
		// invert result
		return result ? FALSE : TRUE;
	}
	// TODO re-order these in terms of probability; 'seconds' is most frequent, then minutes etc.
	//swap out variable names here
	if ( [source isEqualToString:@"else"] ) {
		// 'else' is used as a convenient phrase for the xml, logically it's the equivalent of 'true'
		return TRUE;
	}
	else if ( [source isEqualToString:@"false"] ) {
		return FALSE;
	}
	else if ( [source isEqualToString:@"true"] ) {
		return TRUE;
	}
	else if ( [source isEqualToString:@"day"] ) {
//		NSLog(@"returning day:%d",_day);
		return _day;
	}
	else if ( [source isEqualToString:@"daystartingmonday"] ) {
		return _daystartingmonday;
	}
	else if ( [source isEqualToString:@"date"] ) {
		return _date;
	}	
	else if ( [source isEqualToString:@"month"] ) {
		return _month;
	}	
	else if ( [source isEqualToString:@"hour"] ) {
//		NSLog(@"returning hour:%d",_hour);
		return _hour;
	}	
	else if ( [source isEqualToString:@"twentyfourhour"] ) {
		return _twentyfourhour;
	}	
	else if ( [source isEqualToString:@"minute"] ) {
		return _minute;
	}	
	else if ( [source isEqualToString:@"second"] ) {
		return _second;
	}
//	NSLog(@"returning:%d",[source intValue]);
	return [source intValue];
}

// ____________________________________________________________________________________________________ Operate


-(NSString *)performOperationOnTermOne:(NSString *)aString termTwo:(NSString *)bString operator:(NSString *)operator
{
	//trace("performOperation:"+aString+operator+bString);
	// replace variable names where appropriate
	int a = [self processTerm:aString];
	int b = [self processTerm:bString];
	int result = 0;
	
	if ( [operator isEqualToString:@"*"] ) {
		result = a*b;
	}
	else if ( [operator isEqualToString:@"/"] ) {
		result = a/b;
	}
	else if ( [operator isEqualToString:@"+"] ) {
		result = a+b;
	}
	else if ( [operator isEqualToString:@"-"] ) {
		// FIXME need to fix negative logic (cases with - sign) see above
		NSLog(@"MINUS! a=%d",a);
		if ( [[LogicParserStringUtil trim:aString] length] == 0) { NSLog(@"DSDDASDS"); }
		result = a-b;
	}
	else if ( [operator isEqualToString:@"%"] ) {
		result = a%b;
	}
	else if ( [operator isEqualToString:@"&&"] ) {
		result = ( a && b ) ? TRUE : FALSE;
	}			
	else if ( [operator isEqualToString:@"||"] ) {
		result = ( a || b ) ? TRUE : FALSE;
	}		
	else if ( [operator isEqualToString:@"!="] ) {
		result = ( a != b ) ? TRUE : FALSE;
	}			
	else if ( [operator isEqualToString:@"=="] ) {
		result = ( a == b ) ? TRUE : FALSE;
	}		
	else if ( [operator isEqualToString:@">"] ) {
		result = ( a > b ) ? TRUE : FALSE;
	}			
	else if ( [operator isEqualToString:@"<"] ) {
		result = ( a < b ) ? TRUE : FALSE;
	}		
	else if ( [operator isEqualToString:@">="] ) {
		result = ( a >= b ) ? TRUE : FALSE;
	}			
	else if ( [operator isEqualToString:@"<="] ) {
		result = ( a <= b ) ? TRUE : FALSE;
	}		
		
	return [NSString stringWithFormat:@"%d",result];
}

// ____________________________________________________________________________________________________ Getters / Setters

@synthesize day = _day;
@synthesize daystartingmonday = _daystartingmonday;
@synthesize date = _date;
@synthesize month = _month;
@synthesize hour = _hour;
@synthesize twentyfourhour = _twentyfourhour;
@synthesize minute = _minute;
@synthesize second = _second;	

// 0 for Sunday, 1 for Monday, and so on
-(void)setDay:(int)value
{
//	NSLog(@"SetDay!");
	_day = value;
	_daystartingmonday = value - 1;
	if ( _daystartingmonday < 0 ) {
		_daystartingmonday += 7;	
	}
}
@end

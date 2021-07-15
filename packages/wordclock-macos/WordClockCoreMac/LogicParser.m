//
//  LogicParser.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "LogicParser.h"

#import "LogicParserStringUtil.h"

NSString *LogicParserOperators = @"!%&*()-+=|/<>";

@implementation LogicParser

// ____________________________________________________________________________________________________
// Singleton

+ (LogicParser *)sharedInstance {
    static dispatch_once_t once;
    static LogicParser *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
/*
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
            return shareNSLogicParserInstance;  // assignment and return on
first allocation
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

- (NSUInteger)retainCount
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
*/

// ____________________________________________________________________________________________________
// Init

+ (void)initialize {
    LogicParserEqualityOperators = [@[ @"==", @"!=", @">=", @"<=", @">", @"<" ] retain];
    LogicParserMathOperators = [@[ @"%", @"*", @"/", @"+", @"-" ] retain];
    LogicParserBooleanOperators = [@[ @"&&", @"||" ] retain];
    LogicParserConversionOperators = [@[ @"-", @"!" ] retain];
}

- (NSInteger)parse:(NSString *)source {
    //	DDLogVerbose(@"------------------------");
    //	DDLogVerbose(@"parse:<<<<%@>>>>",source);
    if (![LogicParserStringUtil checkBalancedBraces:source]) {
        DDLogVerbose(@"Syntax Error: mismatching braces: %@", source);
        return 0;
    }
    return [self processTerm:[self term:source]];
}

// ____________________________________________________________________________________________________
// delloc

- (void)dealloc {
    [LogicParserEqualityOperators release];
    [LogicParserMathOperators release];
    [LogicParserBooleanOperators release];
    [LogicParserConversionOperators release];
    [super dealloc];
}

// ____________________________________________________________________________________________________
// Term

- (NSString *)term:(NSString *)source {
    NSArray *terms;
    BOOL parsing;
    NSInteger result;

    //	DDLogVerbose(@"term input:<%@>",source);

    parsing = YES;

    while (parsing) {
        // parse brackets
        if ([LogicParserStringUtil containsBraces:source]) {
            terms = [LogicParserStringUtil extractStringContainedInOutermostBraces:source];
            //			DDLogVerbose(@"extracted braces:%@",terms);
            source = [NSString stringWithFormat:@"%@%@%@", terms[0], [self term:terms[1]], terms[2]];
        } else {
            // parse math operators
            result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserMathOperators];
            if (result != -1) {
                terms = [LogicParserStringUtil extractTermsAroundPivot:source pivot:LogicParserMathOperators[result]];  //  MATH_OPERATORS[result]);
                source = [NSString
					stringWithFormat:@"%@%@%@",
					terms[0], 
					[self 
						performOperationOnTermOne:terms[1]
						termTwo:terms[2]
						operator:LogicParserMathOperators[result]
					],
					terms[3]
				];
                //  terms[0]+performOperation(terms[1],terms[2],MATH_OPERATORS[result])+terms[3];
                // trace(terms);
            } else {
                // parse equality operators
                result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserEqualityOperators];
                if (result != -1) {
                    terms = [LogicParserStringUtil extractTermsAroundPivot:source pivot:LogicParserEqualityOperators[result]];
                    source = [NSString
						stringWithFormat:@"%@%@%@",
						terms[0], 
						[self 
							performOperationOnTermOne:terms[1]
							termTwo:terms[2]
							operator:LogicParserEqualityOperators[result]
						],
						terms[3]
					];
                    // source =
                    // terms[0]+performOperation(terms[1],terms[2],EQUALITY_OPERATORS[result])+terms[3];
                    // trace(terms);
                } else {
                    // parse boolean operators
                    result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserBooleanOperators];
                    if (result != -1) {
                        terms = [LogicParserStringUtil extractTermsAroundPivot:source pivot:LogicParserBooleanOperators[result]];
                        source = [NSString
							stringWithFormat:@"%@%@%@",
							terms[0], 
							[self 
								performOperationOnTermOne:terms[1]
								termTwo:terms[2]
								operator:LogicParserBooleanOperators[result]
							],
							terms[3]
						];
                    } else {
                        parsing = NO;
                    }
                }
            }
        }
    }
    //	DDLogVerbose(@"term output:<%@>",source);
    return source;
}

// ____________________________________________________________________________________________________
// Process

// check for var names, - and !
- (NSInteger)processTerm:(NSString *)source {
    //	DDLogVerbose(@"processTerm:%@",source);
    NSInteger result;
    source = [LogicParserStringUtil trim:source];  // StringUtils.trim(source);

    if ([source length] == 1) {
        //		DDLogVerbose(@"returning:%d",[source intValue]);
        return [source intValue];
    }

    // FIXME a minus sign causes infinite recursion at present
    // because we repeatedly have a term starting "-"
    // and recursively subtract it from 0
    // a hack might just be to have a flag checking for this special case
    if ([source characterAtIndex:0] == '-') {
        return 0 - [self processTerm:[source substringFromIndex:1]];
    }
    if ([source characterAtIndex:1] == '!') {
        result = [self processTerm:[source substringFromIndex:1]];
        // invert result
        return result ? FALSE : TRUE;
    }
    // TODO re-order these in terms of probability; 'seconds' is most frequent,
    // then minutes etc. swap out variable names here
    if ([source isEqualToString:@"else"]) {
        // 'else' is used as a convenient phrase for the xml, logically it's the
        // equivalent of 'true'
        return TRUE;
    } else if ([source isEqualToString:@"false"]) {
        return FALSE;
    } else if ([source isEqualToString:@"true"]) {
        return TRUE;
    } else if ([source isEqualToString:@"day"]) {
        //		DDLogVerbose(@"returning day:%d",_day);
        return _day;
    } else if ([source isEqualToString:@"daystartingmonday"]) {
        return _daystartingmonday;
    } else if ([source isEqualToString:@"date"]) {
        return _date;
    } else if ([source isEqualToString:@"month"]) {
        return _month;
    } else if ([source isEqualToString:@"hour"]) {
        //		DDLogVerbose(@"returning hour:%d",_hour);
        return _hour;
    } else if ([source isEqualToString:@"twentyfourhour"]) {
        return _twentyfourhour;
    } else if ([source isEqualToString:@"minute"]) {
        return _minute;
    } else if ([source isEqualToString:@"second"]) {
        return _second;
    }
    //	DDLogVerbose(@"returning:%d",[source intValue]);
    return [source intValue];
}

// ____________________________________________________________________________________________________
// Operate

- (NSString *)performOperationOnTermOne:(NSString *)aString termTwo:(NSString *)bString operator:(NSString *)operator{
    // trace("performOperation:"+aString+operator+bString);
    // replace variable names where appropriate
    NSInteger a = [self processTerm:aString];
    NSInteger b = [self processTerm:bString];
    NSInteger result = 0;

    if ( [operator isEqualToString:@"*"] ) {
        result = a * b;
    }
	else if ( [operator isEqualToString:@"/"] ) {
        result = a / b;
    }
	else if ( [operator isEqualToString:@"+"] ) {
        result = a + b;
    }
	else if ( [operator isEqualToString:@"-"] ) {
        // FIXME need to fix negative logic (cases with - sign) see above
        DDLogVerbose(@"MINUS! a=%@", @(a));
        if ([[LogicParserStringUtil trim:aString] length] == 0) {
            DDLogVerbose(@"DSDDASDS");
        }
        result = a - b;
    }
	else if ( [operator isEqualToString:@"%"] ) {
        result = a % b;
    }
	else if ( [operator isEqualToString:@"&&"] ) {
        result = (a && b) ? TRUE : FALSE;
    }			
	else if ( [operator isEqualToString:@"||"] ) {
        result = (a || b) ? TRUE : FALSE;
    }		
	else if ( [operator isEqualToString:@"!="] ) {
        result = (a != b) ? TRUE : FALSE;
    }			
	else if ( [operator isEqualToString:@"=="] ) {
        result = (a == b) ? TRUE : FALSE;
    }		
	else if ( [operator isEqualToString:@">"] ) {
        result = (a > b) ? TRUE : FALSE;
    }			
	else if ( [operator isEqualToString:@"<"] ) {
        result = (a < b) ? TRUE : FALSE;
    }		
	else if ( [operator isEqualToString:@">="] ) {
        result = (a >= b) ? TRUE : FALSE;
    }			
	else if ( [operator isEqualToString:@"<="] ) {
        result = (a <= b) ? TRUE : FALSE;
    }

    return [NSString stringWithFormat:@"%@", @(result)];
}

// ____________________________________________________________________________________________________
// Getters / Setters

@synthesize day = _day;
@synthesize daystartingmonday = _daystartingmonday;
@synthesize date = _date;
@synthesize month = _month;
@synthesize hour = _hour;
@synthesize twentyfourhour = _twentyfourhour;
@synthesize minute = _minute;
@synthesize second = _second;

// 0 for Sunday, 1 for Monday, and so on
- (void)setDay:(NSInteger)value {
    //	DDLogVerbose(@"SetDay!");
    _day = value;
    _daystartingmonday = value - 1;
    if (_daystartingmonday < 0) {
        _daystartingmonday += 7;
    }
}
@end

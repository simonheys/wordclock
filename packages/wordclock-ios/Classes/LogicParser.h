//
//  LogicParser.h
//  iphone_word_clock
//
//  Created by Simon on 16/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogicParserStringUtil.h"
//#import "NSLog.h"

NSArray *LogicParserEqualityOperators;
NSArray *LogicParserMathOperators;
NSArray *LogicParserBooleanOperators;
NSArray *LogicParserConversionOperators;

@interface LogicParser : NSObject {
	int _day;
	int _daystartingmonday;
	int _date;
	int _month;
	int _hour;
	int _twentyfourhour;
	int _minute;
	int _second;	
}
+ (LogicParser*)sharedInstance;
-(int)parse:(NSString *)source;
-(int) processTerm:(NSString *)source;
-(NSString *)performOperationOnTermOne:(NSString *)aString termTwo:(NSString *)bString operator:(NSString *)operator;
-(NSString *)term:(NSString *)source;

@property int day;
@property int daystartingmonday;
@property int date;
@property int month;
@property int hour;
@property int twentyfourhour;
@property int minute;
@property int second;

@end

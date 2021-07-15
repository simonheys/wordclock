//
//  LogicParser.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "LogicParserStringUtil.h"
//#import "NSLog.h"

NSArray *LogicParserEqualityOperators;
NSArray *LogicParserMathOperators;
NSArray *LogicParserBooleanOperators;
NSArray *LogicParserConversionOperators;

@interface LogicParser : NSObject {
    NSInteger _day;
    NSInteger _daystartingmonday;
    NSInteger _date;
    NSInteger _month;
    NSInteger _hour;
    NSInteger _twentyfourhour;
    NSInteger _minute;
    NSInteger _second;
}
+ (LogicParser *)sharedInstance;
- (NSInteger)parse:(NSString *)source;
- (NSInteger)processTerm:(NSString *)source;
- (NSString *)performOperationOnTermOne:(NSString *)aString termTwo:(NSString *)bString operator:(NSString *)operator;
- (NSString *)term:(NSString *)source;

@property(nonatomic) NSInteger day;
@property NSInteger daystartingmonday;
@property NSInteger date;
@property NSInteger month;
@property NSInteger hour;
@property NSInteger twentyfourhour;
@property NSInteger minute;
@property NSInteger second;

@end

//
//  LogicParserStringUtil.h
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *LogicParserStringUtilOperators;

@interface LogicParserStringUtil : NSObject {

}

+(NSArray *)extractStringContainedInOutermostBraces:(NSString *)source;
+(int)scanForInstanceOf:(NSString *)source inArray:(NSArray *)arrayOfStrings;
+(NSArray *)extractTermsAroundPivot:(NSString *)source pivot:(NSString *)pivot;
+(NSString *)trim:(NSString *)source;
+(int)countInstancesOf:(NSString *)source instance:(char)instance;
+(BOOL)checkBalancedBraces:(NSString *)source;
+(BOOL)containsBraces:(NSString *)source;
+(BOOL)contains:(NSString *)source instance:(char)instance;
@end

/*
int LogicParserStringUtilCountInstancesOf(char source[], char instance);
bool LogicParserStringUtilCheckBalancedBraces(char source[]);
bool LogicParserStringUtilContainsBraces(char source[]);
*/

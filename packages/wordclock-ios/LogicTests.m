//
//  LogicTests.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "LogicTests.h"


@implementation LogicTests

- (void) testPass {

      STAssertTrue(TRUE, @"");

}

-(void)testParser
{
	//count
	STAssertEquals([LogicParserStringUtil countInstancesOf:@"123456789009000" instance:'0'], 5, @"");
	
	//braces
	STAssertTrue([LogicParserStringUtil checkBalancedBraces:@"(12345)6789009000"],@"");
	STAssertFalse([LogicParserStringUtil checkBalancedBraces:@"((12345)6789009000"],@"");

	NSArray *result;
	result = [LogicParserStringUtil extractStringContainedInOutermostBraces:@"sausages(((spaghetti)))"];
	STAssertEqualObjects([result objectAtIndex:1], @"((spaghetti))", @"");
		
	result = [LogicParserStringUtil extractStringContainedInOutermostBraces:@"(((spaghetti)))sausages"];
	STAssertEqualObjects([result objectAtIndex:1], @"((spaghetti))", @"");	
		
	result = [LogicParserStringUtil extractStringContainedInOutermostBraces:@"sausages(((spaghetti)))sausages"];
	STAssertEqualObjects([result objectAtIndex:1], @"((spaghetti))", @"");	

	// pivot
	result = [LogicParserStringUtil extractTermsAroundPivot:@"23-number*25+6" pivot:@"*"];
	STAssertEqualObjects([result objectAtIndex:0], @"23-", @"");	
	STAssertEqualObjects([result objectAtIndex:1], @"number", @"");	
	STAssertEqualObjects([result objectAtIndex:2], @"25", @"");	
	STAssertEqualObjects([result objectAtIndex:3], @"+6", @"");

	STAssertEqualObjects([[LogicParser sharedInstance] term:@"24/3*2"],@"4",@"");
	STAssertEqualObjects([[LogicParser sharedInstance] term:@"(24/3)*2"],@"16",@"");
	STAssertEqualObjects([[LogicParser sharedInstance] term:@"(27*3+(5+10))%(7*2)"],@"12",@"");
		
	[LogicParser sharedInstance].day = 2;
	[LogicParser sharedInstance].month = 3;
	STAssertEquals([[LogicParser sharedInstance] parse:@"day"],2,@"");
	STAssertEquals([[LogicParser sharedInstance] parse:@"day%2"],0,@"");
	STAssertEquals([[LogicParser sharedInstance] parse:@"day*2"],4,@"");
	
	STAssertTrue([[LogicParser sharedInstance] parse:@"day==2"],@"");
	STAssertTrue([[LogicParser sharedInstance] parse:@"day!=month"],@"");
	STAssertFalse([[LogicParser sharedInstance] parse:@"day==month"],@"");
	STAssertTrue([[LogicParser sharedInstance] parse:@"(day*month)==(1+day+month)"],@"");
}


@end

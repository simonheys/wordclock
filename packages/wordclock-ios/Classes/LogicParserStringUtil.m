//
//  LogicParserStringUtil.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "LogicParserStringUtil.h"

NSString *LogicParserStringUtilOperators = @"!%&*()-+=|/<>";

@implementation LogicParserStringUtil

+(NSArray *)extractStringContainedInOutermostBraces:(NSString *)source
{
	NSString *leftOfBraces;
	NSString *rightOfBraces;
	NSString *insideBraces;
	int count = 1;
	int firstBrace;
	firstBrace = [source rangeOfString:@"("].location;
	
	int i = 1 + firstBrace;
	char c;
	
	leftOfBraces = [source substringToIndex:i-1];
//	NSLog(@"leftOfBraces:%@",leftOfBraces);
	
//	c = [source characterAtIndex:i];
	
	while ( count > 0 && i < [source length]) {
		c = [source characterAtIndex:i];
		if ( c == '(' ) { count++; }
		if ( c == ')' ) { count--; }
		i++;
	}
	if ( i < [source length] ) {
		rightOfBraces = [source substringFromIndex:i];// source.substr(i);
	}
	else {
		rightOfBraces = @"";
	}
//	NSLog(@"rightOfBraces:%@",rightOfBraces);
	insideBraces = [source substringWithRange:NSMakeRange(1+firstBrace, i-1-(1+firstBrace))];
//	NSLog(@"insideBraces:%@",insideBraces);
	return [NSArray arrayWithObjects: leftOfBraces,insideBraces,rightOfBraces,nil ];
}


+(int)scanForInstanceOf:(NSString *)source inArray:(NSArray *)arrayOfStrings
{
//	NSLog(@"scanForInstanceOf:%@",source);
//	NSLog(@"inArray:%@",arrayOfStrings);
	for ( int i = 0; i < [arrayOfStrings count]; i++ ) {
		if ( [source rangeOfString:[arrayOfStrings objectAtIndex:i]].location != NSNotFound ) {
			return i;
		}
	}
	return -1;
}


+(NSArray *)extractTermsAroundPivot:(NSString *)source pivot:(NSString *)pivot
{
	NSString *leftTerm;
	NSString *rightTerm;
	NSString *leftOfPivot;
	NSString *rightOfPivot;
	NSString *beforeLeftTerm;
	NSString *afterRightTerm;
	char c;
	int i;
			
			//trace("---");
			//trace("extractTermsAroundPivot:"+source);
			//trace("pivot:"+pivot);
	//leftOfPivot = source.substr(0,source.indexOf(pivot));	
	leftOfPivot = [source substringToIndex:[source rangeOfString:pivot].location];
	//rightOfPivot = source.substr(source.indexOf(pivot)+pivot.length);
	rightOfPivot = [source substringFromIndex:[source rangeOfString:pivot].location+[pivot length]];
//	NSLog(@"leftOfPivot:%@",leftOfPivot);
//	NSLog(@"rightOfPivot:%@",rightOfPivot);
			
			// left term
	leftTerm = @"";
	i = [leftOfPivot length]-1;
	//c = leftOfPivot.substr(i,1);
	c = [leftOfPivot characterAtIndex:i];
	
	while ( ([LogicParserStringUtilOperators rangeOfString:[NSString stringWithFormat:@"%c",c]]).location == NSNotFound && i > 0 )
	{
		i--;
		c = [leftOfPivot characterAtIndex:i];
	}
	
	if ( [LogicParserStringUtilOperators rangeOfString:[NSString stringWithFormat:@"%c",c]].location != NSNotFound ) {
	//		if ( OPERATORS.indexOf(c) != -1 ) {
		leftTerm = [leftOfPivot substringFromIndex:i+1];// .substr(i+1);
		//beforeLeftTerm = leftOfPivot.substr(0,i+1);
		beforeLeftTerm = [leftOfPivot substringToIndex:i+1];
	}
	else {
		//		leftTerm = leftOfPivot.substr(i);
		leftTerm = [ leftOfPivot substringFromIndex:i];
		//		beforeLeftTerm = leftOfPivot.substr(0,i);
		beforeLeftTerm = [ leftOfPivot substringToIndex:i];
	}
//	NSLog(@"leftTerm:%@",leftTerm);
//	NSLog(@"beforeLeftTerm:%@",beforeLeftTerm);
			
//	NSLog(@"rightOfPivot length:%d",[rightOfPivot length]);
//	NSLog(@"rightOfPivot:%@",rightOfPivot);
			//right term
	rightTerm = @"";
	if ( [rightOfPivot length] > 0 ) {
		i = 0;
		c = [rightOfPivot characterAtIndex:i];//.substr(i,1);
		//		while ( OPERATORS.indexOf(c) == -1 && i < rightOfPivot.length )
		while ( ([LogicParserStringUtilOperators rangeOfString:[NSString stringWithFormat:@"%c",c]]).location == NSNotFound && i < [rightOfPivot length] )
		{
			i++;
			if ( i < [rightOfPivot length] ) {
				c = [rightOfPivot characterAtIndex:i];
			}
		}
		//		rightTerm = rightOfPivot.substr(0,i);
		//		afterRightTerm = rightOfPivot.substr(i);
	}
	
	if ( i < [rightOfPivot length] ) {
		rightTerm = [rightOfPivot substringToIndex:i];
		afterRightTerm = [rightOfPivot substringFromIndex:i];
	}
	else {
		rightTerm = rightOfPivot;
		afterRightTerm = @"";
	}
	
//	NSLog(@"rightTerm:%@",rightTerm);
//	NSLog(@"afterRightTerm:%@",afterRightTerm);
			//return [beforeLeftTerm,leftTerm,rightTerm,afterRightTerm];	
	
	return [NSArray arrayWithObjects:beforeLeftTerm, leftTerm, rightTerm, afterRightTerm, nil];
}



+(NSString *)trim:(NSString *)source
{
	return [source stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(int)countInstancesOf:(NSString *)source instance:(char)instance
{
	int count = 0;
	int i = 0;
	while ( i < [source length] ) {
		if ( [source characterAtIndex:i] == instance ) {
			count++;
		}	
		i++;
	}
//	NSLog(@"countInstancesOf:%@ - %c = %d",source,instance,count);
	return count;
}

+(BOOL)checkBalancedBraces:(NSString *)source
{
	return ([LogicParserStringUtil countInstancesOf:source instance:'(']
		== [LogicParserStringUtil countInstancesOf:source instance:')']);
}

+(BOOL)containsBraces:(NSString *)source
{
	return ([LogicParserStringUtil contains:source instance:'(']
		|| [LogicParserStringUtil contains:source instance:')']);
}

+(BOOL)contains:(NSString *)source instance:(char)instance
{
	return ([LogicParserStringUtil countInstancesOf:source instance:instance] > 0);
}
@end

/*
int LogicParserStringUtilCountInstancesOf(char source[], char instance)
{
	int count = 0;
	int i = 0;
	
	printf("counting:%s\n",source);
	
	while ( source[i] != '\0' ) {
		if ( source[i] == instance ) {
			count++;
		}	
		i++;
	}

	return count;
}


bool LogicParserStringUtilCheckBalancedBraces(char source[])
{
	return LogicParserStringUtilCountInstancesOf(source,'(') == LogicParserStringUtilCountInstancesOf(source,')');
}

bool LogicParserStringUtilContains(char source[], char instance)
{
	return LogicParserStringUtilCountInstancesOf(source, instance) > 0;
}


bool LogicParserStringUtilContainsBraces(char source[])
{
	return LogicParserStringUtilContains(source,'(') || LogicParserStringUtilContains(source,')');
}
	*/
	




/*
void LogicParserStringUtilExtractStringContainedInOutermostBraces(char *source,char *leftOfBraces,char *insideBraces,char *rightOfBraces)
{
	int length;
	int count = 0;
	char *characterPtr;
	characterPtr = strchr(source,'(');
	length = characterPtr - source;
	printf("left length:%d",length);
	strncpy(leftOfBraces, source, length); // not null terminated, so;
//	(char *)(leftOfBraces + length) = '\0';
	while ( *characterPtr != '\0') {
		if ( *characterPtr == '(' )
			count++;
		else if ( *characterPtr == ')' )
			count--;
		characterPtr++;
	}
			return [
				source.substring(0,source.indexOf("(")),
				source.substring(1+source.indexOf("("),source.lastIndexOf(")")),
				source.substring(1+source.lastIndexOf(")"))
			];
			var leftOfBraces:String;
			var rightOfBraces:String;
			var insideBraces:String;
			var count:Number = 1;
			var i:Number = 1+source.indexOf("(");
			var c:String;
			leftOfBraces = source.substring(0,i-1);
			c = source.charAt(i);
			while ( count > 0 && i < source.length) {
				c = source.charAt(i);
				if ( c == "(" ) { count++; }
				if ( c == ")" ) { count--; }			
				i++;
			}
			rightOfBraces = source.substr(i);
			insideBraces = source.substring(1+source.indexOf("("),i-1);
			return [ leftOfBraces,insideBraces,rightOfBraces ];
		}
}
*/

//
//  DLog.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "DLog.h"

static BOOL __DEBUG=NO;

@implementation DLog

+ (void) initialize
{
    char *env = getenv("DEBUG");
    env = (env == NULL ? "" : env);
    if(strcmp(env, "YES") == 0)
        __DEBUG = YES;
}

+ (void) logFile: (char *) sourceFile
    lineNumber: (int) lineNumber
	format: (NSString *) format, ...;
{
    va_list ap;
    NSString *print, *file;
    if(__DEBUG == NO)
        return;
    va_start(ap, format);
    file = [NSString stringWithCString:sourceFile encoding:NSMacOSRomanStringEncoding];
    print = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    NSLog(@"%s:%d %@", [[file lastPathComponent] UTF8String], lineNumber, print);
    
    [print release];
}

+ (void) logFile: (char *) sourceFile
    lineNumber: (int) lineNumber
    function: (char *) functionName
    format: (NSString *) format, ...;
{
    va_list ap;
    NSString *print, *file, *function;
    if(__DEBUG == NO)
        return;
    va_start(ap,format);
    file = [NSString stringWithCString:sourceFile encoding:NSMacOSRomanStringEncoding];
    function = [NSString stringWithCString:functionName encoding:NSMacOSRomanStringEncoding];
    print = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    NSLog(@"%s:%d in %@ %@", [[file lastPathComponent] UTF8String], lineNumber, function, print);
    
    [print release];
}

+ (void) setLogOn: (BOOL) logOn
{
    __DEBUG=logOn;
}

@end

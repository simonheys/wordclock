//
//  DLog.h
//  Screensavr
//
//  Created by Simon on 04/03/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DLog(s,...) [DLog logFile:__FILE__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define DFLog(s,...) [DLog logFile:__FILE__ lineNumber:__LINE__ function:(char*)__FUNCTION__ format:(s),##__VA_ARGS__]

@interface DLog : NSObject {
}

+ (void) logFile: (char *) sourceFile lineNumber: (int) lineNumber format: (NSString *) format, ...;
+ (void) logFile: (char *) sourceFile lineNumber: (int) lineNumber function: (char *) functionName format: (NSString *) format, ...;
+ (void) setLogOn: (BOOL) logOn;

@end
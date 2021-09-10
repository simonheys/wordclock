//
//  NSDictionaryAdditions.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSDictionary (NSDictionaryAdditions)

- (NSString *)stringForKey:(NSString *)defaultName;
- (BOOL)boolForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;

@end

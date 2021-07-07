//
//  NSDictionaryAdditions.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "NSDictionaryAdditions.h"

@implementation NSDictionary (NSDictionaryAdditions)

-(NSString *)stringForKey:(NSString *)defaultName 
{
   NSString *string=[self objectForKey:defaultName];

   return [string isKindOfClass:[NSString class]]?string:(NSString *)nil;
}

-(BOOL)boolForKey:(NSString *)defaultName 
{
   NSString *string=[self objectForKey:defaultName];

   if(![string isKindOfClass:[NSString class]])
    return NO;

   if([string caseInsensitiveCompare:@"YES"]==NSOrderedSame)
    return YES;

   return [string intValue];
}

-(float)floatForKey:(NSString *)defaultName 
{
   NSNumber *number=[self objectForKey:defaultName];

   return [number isKindOfClass:[NSNumber class]]?[number floatValue]:0.0;
}

@end

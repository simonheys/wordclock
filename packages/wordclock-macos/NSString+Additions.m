//
//  NSString+Additions.m
//  WordClock macOS
//
//  Created by Simon Heys on 14/01/2013.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (NSString *)stringByRemovingWhiteSpaceAndNewlines {
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
}

@end

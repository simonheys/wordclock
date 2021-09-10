//
//  NSString+Additions.h
//  WordClock macOS
//
//  Created by Simon Heys on 14/01/2013.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)
@property(NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringByRemovingWhiteSpaceAndNewlines;
@end

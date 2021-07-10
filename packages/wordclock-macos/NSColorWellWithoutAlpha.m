//
//  NSColorWellWithoutAlpha.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "NSColorWellWithoutAlpha.h"

@implementation NSColorWellWithoutAlpha
- (void)activate:(BOOL)exclusive
{
    [super activate: exclusive];
    [[NSColorPanel sharedColorPanel] setShowsAlpha:NO];
}
@end

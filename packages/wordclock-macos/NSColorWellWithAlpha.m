//
//  NSColorWellWithAlpha.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "NSColorWellWithAlpha.h"

@implementation NSColorWellWithAlpha
- (void)activate:(BOOL)exclusive
{
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [super activate: exclusive];
}
@end

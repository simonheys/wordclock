//
//  NSView+Additions.m
//  WordClock macOS
//
//  Created by Simon Heys on 05/12/2012.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "NSView+Additions.h"

@implementation NSView (Additions)

- (void)disableSubViews {
    [self setSubViewsEnabled:NO];
}

- (void)enableSubViews {
    [self setSubViewsEnabled:YES];
}

- (void)setSubViewsEnabled:(BOOL)enabled {
    NSView *currentView = NULL;
    NSEnumerator *viewEnumerator = [[self subviews] objectEnumerator];

    while (currentView = [viewEnumerator nextObject]) {
        if ([currentView respondsToSelector:@selector(setEnabled:)]) {
            [(NSControl *)currentView setEnabled:enabled];
        }
        [currentView setSubViewsEnabled:enabled];

        [currentView display];
    }
}

@end

//
//  NSView+Additions.h
//  WordClock macOS
//
//  Created by Simon Heys on 05/12/2012.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Additions)

- (void)disableSubViews;
- (void)enableSubViews;
- (void)setSubViewsEnabled:(BOOL)enabled;

@end

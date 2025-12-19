//
//  GuidesViewLinear.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GuidesView.h"

@interface GuidesViewLinear : GuidesView {
    CGFloat _draggingOffset;
    CGFloat _draggingOffsetLeft;
    CGFloat _draggingOffsetRight;
    CGFloat _draggingOffsetTop;
    CGFloat _draggingOffsetBottom;
}

@end

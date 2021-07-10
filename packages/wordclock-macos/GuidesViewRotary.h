//
//  GuidesViewRotary.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import "GuidesView.h"

@interface GuidesViewRotary : GuidesView {
    CGFloat _draggingOffset;
    CGFloat _draggingOffsetX;
    CGFloat _draggingOffsetY;
}

@end

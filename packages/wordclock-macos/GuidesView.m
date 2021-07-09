//
//  GuidesView.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "GuidesView.h"
#import "WordClockPreferences.h"

@implementation GuidesView

@synthesize mouseInside;
@synthesize scale = _scale;
@synthesize view = _view;

- (void)drawGlView {}

- (void)mouseMoved:(NSEvent *)theEvent {}

- (void)mouseExited:(NSEvent *)theEvent {}

- (void)updateWithMouseDragEvent:(NSEvent *)theEvent {}

- (void)updateWithMouseUpEvent:(NSEvent *)theEvent {} 

- (void)updateWithMouseDownEvent:(NSEvent *)theEvent {}

- (BOOL)shouldDrawWithLightGuideColor
{
    NSColor *normalizedColor = [[WordClockPreferences sharedInstance].backgroundColour colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    float brightness = [normalizedColor brightnessComponent];
    return brightness < 0.5f;
}

- (NSPoint)localPointForEvent:(NSEvent *)event
{
	NSPoint event_location = [event locationInWindow]; 
	NSPoint local_point = [self.view convertPoint:event_location fromView:nil];
    return NSMakePoint(local_point.x, self.view.bounds.size.height - local_point.y);
}


@end

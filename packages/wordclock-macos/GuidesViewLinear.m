//
//  GuidesViewLinear.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "GuidesViewLinear.h"

#import "WordClockPreferences.h"

@interface GuidesViewLinear ()
@property(NS_NONATOMIC_IOSONLY, readonly) CGFloat leftMarginPosition;
@property(NS_NONATOMIC_IOSONLY, readonly) CGFloat rightMarginPosition;
@property(NS_NONATOMIC_IOSONLY, readonly) CGFloat topMarginPosition;
@property(NS_NONATOMIC_IOSONLY, readonly) CGFloat bottomMarginPosition;
@end

@implementation GuidesViewLinear

// ____________________________________________________________________________________________________
// margins

- (CGFloat)leftMarginPosition {
    CGFloat l = [WordClockPreferences sharedInstance].linearMarginLeft;
    return [self scale] * l;
}

- (CGFloat)rightMarginPosition {
    CGFloat r = [[NSScreen mainScreen] visibleFrame].size.width - [WordClockPreferences sharedInstance].linearMarginRight;
    return [self scale] * r;
}

- (CGFloat)topMarginPosition {
    CGFloat t = [WordClockPreferences sharedInstance].linearMarginTop;
    return [self scale] * t;
}

- (CGFloat)bottomMarginPosition {
    CGFloat b = [[NSScreen mainScreen] visibleFrame].size.height - [WordClockPreferences sharedInstance].linearMarginBottom;
    return [self scale] * b;
}

- (NSRect)marginAll {
    CGFloat l = [self leftMarginPosition];
    CGFloat r = [self rightMarginPosition];
    CGFloat t = [self topMarginPosition];
    CGFloat b = [self bottomMarginPosition];
    return NSMakeRect(l, t, r - l, b - t);
}

// ____________________________________________________________________________________________________
// mouse events

- (void)mouseMoved:(NSEvent *)theEvent {
    //	NSPoint event_location = [theEvent locationInWindow];
    //	NSPoint local_point = [self.view convertPoint:event_location
    // fromView:nil];
    NSPoint local_point = [self localPointForEvent:theEvent];
    //    DDLogVerbose(@"local_point:%@",NSStringFromPoint(local_point));
    self.mouseInside = NSPointInRect(local_point, NSInsetRect([self marginAll], -MINIMUM_DRAG_DISTANCE, -MINIMUM_DRAG_DISTANCE));
    //    DDLogVerbose(@"self.mouseInside:%@",self.mouseInside ? @"YES" :
    //    @"NO");
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.mouseInside = NO;
}

- (void)updateWithMouseDownEvent:(NSEvent *)theEvent {
    if (!self.mouseInside) {
        return;
    }

    //	NSPoint event_location = [theEvent locationInWindow];
    //	NSPoint local_point = [self.view convertPoint:event_location
    // fromView:nil];
    NSPoint local_point = [self localPointForEvent:theEvent];
    CGFloat draggingOffset;

    DDLogVerbose(@"local_point:%@", NSStringFromPoint(local_point));
    DDLogVerbose(@"bound:%@", NSStringFromRect([[self.view window] frame]));

    draggingOffset = [self leftMarginPosition] - local_point.x;
    //    DDLogVerbose(@"draggingOffset:%f",draggingOffset);
    //    DDLogVerbose(@"fabs( draggingOffset ):%f",fabs( draggingOffset ));
    if (fabs(draggingOffset) < MINIMUM_DRAG_DISTANCE) {
        //       DDLogVerbose(@"DRAGGING LEFT");
        _dragging = YES;
        _draggingGuideType = WCGuideTypeMarginLeft;
        _draggingOffset = draggingOffset;
    } else {
        draggingOffset = [self rightMarginPosition] - local_point.x;
        if (fabs(draggingOffset) < MINIMUM_DRAG_DISTANCE) {
            _dragging = YES;
            _draggingGuideType = WCGuideTypeMarginRight;
            _draggingOffset = draggingOffset;
        } else {
            draggingOffset = [self topMarginPosition] - local_point.y;
            if (fabs(draggingOffset) < MINIMUM_DRAG_DISTANCE) {
                _dragging = YES;
                _draggingGuideType = WCGuideTypeMarginTop;
                _draggingOffset = draggingOffset;
            } else {
                draggingOffset = [self bottomMarginPosition] - local_point.y;
                if (fabs(draggingOffset) < MINIMUM_DRAG_DISTANCE) {
                    _dragging = YES;
                    _draggingGuideType = WCGuideTypeMarginBottom;
                    _draggingOffset = draggingOffset;
                } else {
                    // drag the whole thing
                    _draggingOffsetLeft = [self leftMarginPosition] - local_point.x;
                    _draggingOffsetRight = [self rightMarginPosition] - local_point.x;
                    _draggingOffsetTop = [self topMarginPosition] - local_point.y;
                    _draggingOffsetBottom = [self bottomMarginPosition] - local_point.y;
                    _dragging = YES;
                    _draggingGuideType = WCGuideTypeMarginAll;
                }
            }
        }
    }
    if (!_dragging) {
        //       [super mouseDown:theEvent];
    } else {
        while (_dragging) {
            //
            // Lock focus and take all the dragged and mouse up events until we
            // receive a mouse up.
            //
            NSEvent *newEvent = [[self.view window] nextEventMatchingMask:(NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp)];

            if ([newEvent type] == NSEventTypeLeftMouseUp) {
                [self updateWithMouseUpEvent:newEvent];
                break;
            }
            [self updateWithMouseDragEvent:newEvent];
        }
    }
}

- (void)updateWithMouseDragEvent:(NSEvent *)theEvent {
    @synchronized(self) {
        if (!_dragging) {
            return;
        }
        NSPoint local_point = [self localPointForEvent:theEvent];
        CGFloat scale = [self scale];

        if (!NSPointInRect(local_point, [self.view bounds])) {
            return;
        }

        switch (_draggingGuideType) {
            case WCGuideTypeMarginLeft:
                [WordClockPreferences sharedInstance].linearMarginLeft = MAX(0, (local_point.x + _draggingOffset) / scale);
                break;
            case WCGuideTypeMarginRight:
                [WordClockPreferences sharedInstance].linearMarginRight = MAX(0, [[NSScreen mainScreen] visibleFrame].size.width - (local_point.x + _draggingOffset) / scale);
                break;
            case WCGuideTypeMarginTop:
                [WordClockPreferences sharedInstance].linearMarginTop = MAX(0, (local_point.y + _draggingOffset) / scale);
                break;
            case WCGuideTypeMarginBottom:
                [WordClockPreferences sharedInstance].linearMarginBottom = MAX(0, [[NSScreen mainScreen] visibleFrame].size.height - (local_point.y + _draggingOffset) / scale);
                break;
            case WCGuideTypeMarginAll:
                [WordClockPreferences sharedInstance].linearMarginLeft = MAX(0, (local_point.x + _draggingOffsetLeft) / scale);
                [WordClockPreferences sharedInstance].linearMarginRight = MAX(0, [[NSScreen mainScreen] visibleFrame].size.width - (local_point.x + _draggingOffsetRight) / scale);
                [WordClockPreferences sharedInstance].linearMarginTop = MAX(0, (local_point.y + _draggingOffsetTop) / scale);
                [WordClockPreferences sharedInstance].linearMarginBottom = MAX(0, [[NSScreen mainScreen] visibleFrame].size.height - (local_point.y + _draggingOffsetBottom) / scale);
                break;
            default:
                break;
        }
    }
}

- (void)updateWithMouseUpEvent:(NSEvent *)theEvent {
    //	DDLogVerbose(@"mouseUp");
    if (!_dragging) {
        //        [super mouseUp:theEvent];
        return;
    }
    _dragging = NO;
}
@end

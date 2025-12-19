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
    NSPoint localPoint = [self localPointForEvent:theEvent];
    self.mouseInside = NSPointInRect(localPoint, NSInsetRect([self marginAll], -MINIMUM_DRAG_DISTANCE, -MINIMUM_DRAG_DISTANCE));
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.mouseInside = NO;
}

- (void)updateWithMouseDownEvent:(NSEvent *)theEvent {
    if (!self.mouseInside) {
        return;
    }

    NSPoint localPoint = [self localPointForEvent:theEvent];
    CGFloat draggingOffset;

    DDLogVerbose(@"localPoint:%@", NSStringFromPoint(localPoint));
    DDLogVerbose(@"bound:%@", NSStringFromRect([[self.view window] frame]));

    draggingOffset = [self leftMarginPosition] - localPoint.x;
    if (fabs(draggingOffset) < MINIMUM_DRAG_DISTANCE) {
        _dragging = YES;
        _draggingGuideType = WCGuideTypeMarginLeft;
        _draggingOffset = draggingOffset;
    } else {
        draggingOffset = [self rightMarginPosition] - localPoint.x;
        if (fabs(draggingOffset) < MINIMUM_DRAG_DISTANCE) {
            _dragging = YES;
            _draggingGuideType = WCGuideTypeMarginRight;
            _draggingOffset = draggingOffset;
        } else {
            draggingOffset = [self topMarginPosition] - localPoint.y;
            if (fabs(draggingOffset) < MINIMUM_DRAG_DISTANCE) {
                _dragging = YES;
                _draggingGuideType = WCGuideTypeMarginTop;
                _draggingOffset = draggingOffset;
            } else {
                draggingOffset = [self bottomMarginPosition] - localPoint.y;
                if (fabs(draggingOffset) < MINIMUM_DRAG_DISTANCE) {
                    _dragging = YES;
                    _draggingGuideType = WCGuideTypeMarginBottom;
                    _draggingOffset = draggingOffset;
                } else {
                    // drag the whole thing
                    _draggingOffsetLeft = [self leftMarginPosition] - localPoint.x;
                    _draggingOffsetRight = [self rightMarginPosition] - localPoint.x;
                    _draggingOffsetTop = [self topMarginPosition] - localPoint.y;
                    _draggingOffsetBottom = [self bottomMarginPosition] - localPoint.y;
                    _dragging = YES;
                    _draggingGuideType = WCGuideTypeMarginAll;
                }
            }
        }
    }
    if (_dragging) {
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
    if (!_dragging) {
        return;
    }
    NSPoint localPoint = [self localPointForEvent:theEvent];
    CGFloat scale = [self scale];

    if (!NSPointInRect(localPoint, [self.view bounds])) {
        return;
    }

    switch (_draggingGuideType) {
        case WCGuideTypeMarginLeft:
            [WordClockPreferences sharedInstance].linearMarginLeft = MAX(0, (localPoint.x + _draggingOffset) / scale);
            break;
        case WCGuideTypeMarginRight:
            [WordClockPreferences sharedInstance].linearMarginRight = MAX(0, [[NSScreen mainScreen] visibleFrame].size.width - (localPoint.x + _draggingOffset) / scale);
            break;
        case WCGuideTypeMarginTop:
            [WordClockPreferences sharedInstance].linearMarginTop = MAX(0, (localPoint.y + _draggingOffset) / scale);
            break;
        case WCGuideTypeMarginBottom:
            [WordClockPreferences sharedInstance].linearMarginBottom = MAX(0, [[NSScreen mainScreen] visibleFrame].size.height - (localPoint.y + _draggingOffset) / scale);
            break;
        case WCGuideTypeMarginAll:
            [WordClockPreferences sharedInstance].linearMarginLeft = MAX(0, (localPoint.x + _draggingOffsetLeft) / scale);
            [WordClockPreferences sharedInstance].linearMarginRight = MAX(0, [[NSScreen mainScreen] visibleFrame].size.width - (localPoint.x + _draggingOffsetRight) / scale);
            [WordClockPreferences sharedInstance].linearMarginTop = MAX(0, (localPoint.y + _draggingOffsetTop) / scale);
            [WordClockPreferences sharedInstance].linearMarginBottom = MAX(0, [[NSScreen mainScreen] visibleFrame].size.height - (localPoint.y + _draggingOffsetBottom) / scale);
            break;
        default:
            break;
    }
}

- (void)updateWithMouseUpEvent:(NSEvent *)theEvent {
    if (!_dragging) {
        return;
    }
    _dragging = NO;
}
@end

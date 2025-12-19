//
//  GuidesViewRotary.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "GuidesViewRotary.h"

#import "WordClockPreferences.h"

@interface GuidesViewRotary ()
@property(NS_NONATOMIC_IOSONLY, readonly) CGFloat translateXPosition;
@property(NS_NONATOMIC_IOSONLY, readonly) CGFloat translateYPosition;
@property(NS_NONATOMIC_IOSONLY, readonly) CGFloat radius;
@end

@implementation GuidesViewRotary

- (void)mouseExited:(NSEvent *)theEvent {
    self.mouseInside = NO;
}

- (CGFloat)translateXPosition {
    CGFloat a = [[NSScreen mainScreen] visibleFrame].size.width * 0.5f + [WordClockPreferences sharedInstance].rotaryTranslateX;
    return [self scale] * a;
}

- (CGFloat)translateYPosition {
    CGFloat a = [[NSScreen mainScreen] visibleFrame].size.height * 0.5f + [WordClockPreferences sharedInstance].rotaryTranslateY;
    return [self scale] * a;
}

- (CGFloat)radius {
    CGFloat a = 100.0f * [WordClockPreferences sharedInstance].rotaryScale;
    return [self scale] * a;
}

- (CGFloat)radiusForEvent:(NSEvent *)theEvent {
    NSPoint localPoint = [self localPointForEvent:theEvent];
    CGFloat vx = [self translateXPosition] - localPoint.x;
    CGFloat vy = [self translateYPosition] - localPoint.y;
    CGFloat length = sqrtf(vx * vx + vy * vy);
    return length;
}

- (void)mouseMoved:(NSEvent *)theEvent {
    CGFloat length = [self radiusForEvent:theEvent];
    self.mouseInside = length < ([self radius] + MINIMUM_DRAG_DISTANCE);
}

- (void)updateWithMouseDownEvent:(NSEvent *)theEvent {
    if (!self.mouseInside) {
        return;
    }

    NSPoint localPoint = [self localPointForEvent:theEvent];

    CGFloat length = [self radiusForEvent:theEvent];
    CGFloat draggingOffset;
    CGFloat scale = [self scale];

    draggingOffset = [self radius] - length;
    if (fabs(draggingOffset) < MINIMUM_DRAG_DISTANCE) {
        _dragging = YES;
        _draggingGuideType = WCGuideTypeRadius;
        _draggingOffset = draggingOffset;
    } else {
        // drag the whole thing
        _draggingOffsetX = scale * [WordClockPreferences sharedInstance].rotaryTranslateX - localPoint.x;
        _draggingOffsetY = scale * [WordClockPreferences sharedInstance].rotaryTranslateY - localPoint.y;
        _dragging = YES;
        _draggingGuideType = WCGuideTypeMarginAll;
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
    CGFloat length = [self radiusForEvent:theEvent];

    if (!NSPointInRect(localPoint, [self.view bounds])) {
        return;
    }

    switch (_draggingGuideType) {
        case WCGuideTypeRadius:
            [WordClockPreferences sharedInstance].rotaryScale = ((length + _draggingOffset) / scale) / 100.0f;
            break;
        case WCGuideTypeMarginAll:
            [WordClockPreferences sharedInstance].rotaryTranslateX = (localPoint.x + _draggingOffsetX) / scale;
            [WordClockPreferences sharedInstance].rotaryTranslateY = (localPoint.y + _draggingOffsetY) / scale;
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

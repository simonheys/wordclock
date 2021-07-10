//
//  GuidesViewRotary.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "GuidesViewRotary.h"
#import "WordClockPreferences.h"
#import <OpenGL/gl.h>

@interface GuidesViewRotary ()
@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat translateXPosition;
@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat translateYPosition;
@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat radius;
@end


@implementation GuidesViewRotary

- (void)drawGlView {
    if ( ! (self.mouseInside || _dragging )) {
        return;
    }
    NSSize size = [[NSScreen mainScreen] visibleFrame].size;
    BOOL shouldDrawWithLightGuideColor = [self shouldDrawWithLightGuideColor];
        
    glPushMatrix();
    
    CGFloat h = [WordClockPreferences sharedInstance].rotaryTranslateX;
    CGFloat v = [WordClockPreferences sharedInstance].rotaryTranslateY;
    
	
    glDisable(GL_MULTISAMPLE);

    if ( shouldDrawWithLightGuideColor ) {
        glColor4f(0.8f, 0.8f, 0.8f, 0.3f);
    }
    else {
        glColor4f(0.2f, 0.2f, 0.2f, 0.3f);
    }

    glBegin(GL_LINES);
    glVertex2f(h,-0.5f*size.height);
    glVertex2f(h,0.5f*size.height);
    
    glVertex2f(-0.5f*size.width, v);
    glVertex2f(0.5f*size.width, v);

    glEnd();
    
    if ( shouldDrawWithLightGuideColor ) {
        glColor4f(0.8f, 0.8f, 0.8f, 0.7f);
    }
    else {
        glColor4f(0.2f, 0.2f, 0.2f, 0.7f);
    }
    
    CGFloat r = 100.0f * [WordClockPreferences sharedInstance].rotaryScale;
    
    glEnable(GL_MULTISAMPLE);
    glTranslatef(h, v, 0);
    glBegin(GL_LINE_STRIP);
    for ( int i=0; i <= 360; i++ ) {
        glVertex3f(sin(i*M_PI/180)*r, cos(i*M_PI/180)*r, 0);
    }
    glEnd();

    glPopMatrix();
    
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.mouseInside = NO;
}

- (CGFloat)translateXPosition {
    CGFloat a = [[NSScreen mainScreen] visibleFrame].size.width*0.5f + [WordClockPreferences sharedInstance].rotaryTranslateX;// * [WordClockPreferences sharedInstance].rotaryScale;
    return [self scale]*a;
}

- (CGFloat)translateYPosition {
    CGFloat a = [[NSScreen mainScreen] visibleFrame].size.height*0.5f + [WordClockPreferences sharedInstance].rotaryTranslateY;// * [WordClockPreferences sharedInstance].rotaryScale;
    return [self scale]*a;
}

- (CGFloat)radius {
    CGFloat a = 100.0f * [WordClockPreferences sharedInstance].rotaryScale;
    return [self scale]*a;    
}

- (CGFloat)radiusForEvent:(NSEvent *)theEvent {
//	NSPoint event_location = [theEvent locationInWindow]; 
//	NSPoint local_point = [self.view convertPoint:event_location fromView:nil];
    NSPoint local_point = [self localPointForEvent:theEvent];
    CGFloat vx = [self translateXPosition] - local_point.x;
    CGFloat vy = [self translateYPosition] - local_point.y;
    CGFloat length = sqrtf(vx*vx+vy*vy);
    return length;
}

- (void)mouseMoved:(NSEvent *)theEvent {
//    DDLogVerbose(@"mouseMoved");
//	NSPoint event_location = [theEvent locationInWindow]; 
//	NSPoint local_point = [self convertPoint:event_location fromView:nil];
    //    DDLogVerbose(@"local_point:%@",NSStringFromPoint(local_point));
//    self.mouseInside = NSPointInRect(local_point, NSInsetRect([self marginAll],-MINIMUM_DRAG_DISTANCE,-MINIMUM_DRAG_DISTANCE));
    
//    CGFloat vx = [self translateXPosition] - local_point.x;
//    CGFloat vy = [self translateYPosition] - local_point.y;
    CGFloat length = [self radiusForEvent:theEvent];
    self.mouseInside = length < ([self radius] + MINIMUM_DRAG_DISTANCE);
}

- (void)updateWithMouseDownEvent:(NSEvent *)theEvent {
    if ( !self.mouseInside ) {
        return;
    }
    
//	NSPoint event_location = [theEvent locationInWindow]; 
//	NSPoint local_point = [self.view convertPoint:event_location fromView:nil];
    NSPoint local_point = [self localPointForEvent:theEvent];

    CGFloat length = [self radiusForEvent:theEvent];
	CGFloat draggingOffset;
    CGFloat scale = [self scale];
   
    //   DDLogVerbose(@"local_point:%@",NSStringFromPoint(local_point));
    
    draggingOffset = [self radius] - length;
    //    DDLogVerbose(@"draggingOffset:%f",draggingOffset);
    //    DDLogVerbose(@"fabs( draggingOffset ):%f",fabs( draggingOffset ));
    if ( fabs( draggingOffset ) < MINIMUM_DRAG_DISTANCE ) {
        //       DDLogVerbose(@"DRAGGING LEFT");
        _dragging = YES;
        _draggingGuideType = WCGuideTypeRadius;
        _draggingOffset = draggingOffset;
    }
    else {
        // drag the whole thing
        _draggingOffsetX = scale*[WordClockPreferences sharedInstance].rotaryTranslateX - local_point.x;
        _draggingOffsetY = scale*[WordClockPreferences sharedInstance].rotaryTranslateY - local_point.y;
        _dragging = YES;
        _draggingGuideType = WCGuideTypeMarginAll;
    }
    if ( !_dragging ) {
        //       [super mouseDown:theEvent];
    }
    else {
        while (_dragging)
        {
            //
            // Lock focus and take all the dragged and mouse up events until we
            // receive a mouse up.
            //
            NSEvent *newEvent = [[self.view window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
            
            if ([newEvent type] == NSLeftMouseUp)
            {
                [self updateWithMouseUpEvent:newEvent];
                break;
            }
            [self updateWithMouseDragEvent:newEvent];
        }
    }
}

- (void)updateWithMouseDragEvent:(NSEvent *)theEvent {
    @synchronized(self) {
        if ( !_dragging ) {
            return;
        }
        NSPoint local_point = [self localPointForEvent:theEvent];
        CGFloat scale = [self scale];
        CGFloat length = [self radiusForEvent:theEvent];
                
        if ( !NSPointInRect(local_point, [self.view bounds]) ) {
            return;
        }
                
        switch (_draggingGuideType) {
            case WCGuideTypeRadius:
                [WordClockPreferences sharedInstance].rotaryScale = ((length + _draggingOffset) / scale)/100.0f;
                break;
            case WCGuideTypeMarginAll:
                [WordClockPreferences sharedInstance].rotaryTranslateX = (local_point.x + _draggingOffsetX) / scale;
                [WordClockPreferences sharedInstance].rotaryTranslateY = (local_point.y + _draggingOffsetY) / scale;
                break;
            default:
                break;
        }
    }
}

- (void)updateWithMouseUpEvent:(NSEvent *)theEvent
{
    if ( !_dragging ) {
        //        [super mouseUp:theEvent];
        return;
    }
	_dragging = NO;
}
@end

//
//  GuidesView.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MINIMUM_DRAG_DISTANCE 5.0f

typedef NS_ENUM(NSInteger, WCGuideType) {
    WCGuideTypeMarginLeft,
    WCGuideTypeMarginRight,
    WCGuideTypeMarginTop,
	WCGuideTypeMarginBottom,
    WCGuideTypeMarginAll,
    WCGuideTypeRadius
} ;

@interface GuidesView : NSObject {
    WCGuideType _draggingGuideType;
    BOOL mouseInside;
    BOOL _dragging;
    CGFloat _scale;
    NSView *_view;
}
- (void)updateWithMouseDragEvent:(NSEvent *)theEvent;
- (void)updateWithMouseUpEvent:(NSEvent *)theEvent;
- (void)updateWithMouseDownEvent:(NSEvent *)theEvent;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL shouldDrawWithLightGuideColor;
- (void)drawGlView;
- (void)mouseMoved:(NSEvent *)theEvent;
- (void)mouseExited:(NSEvent *)theEvent;
- (NSPoint)localPointForEvent:(NSEvent *)event;

@property (nonatomic) BOOL mouseInside;
@property (nonatomic) CGFloat scale;
@property (nonatomic, assign) NSView *view;

@end

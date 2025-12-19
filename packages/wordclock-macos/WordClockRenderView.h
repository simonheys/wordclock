//
//  WordClockRenderView.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreVideo/CoreVideo.h>

#import "culling.h"

#define kWordClockWordTextureMaximumPixelsCombined 14 * 1024 * 1024 / 2

@class WordClockViewController;
@class WordClockWordLayout;
@class WordClockMetalView;
@class GuidesView;
@class WordClockWordManager;
@class TweenManager;

@interface WordClockRenderView : NSView {
   @private
    WordClockViewController *controller;

    CVDisplayLinkRef displayLink;
    BOOL isAnimating;

    WordClockRectsForCulling *_rectsForCulling;
    NSInteger _numberOfWords;
    short *_coordinates;
    float *_vertices;
    float *_colours;
    BOOL *_highlighted;

    GuidesView *guidesView;
    NSTrackingArea *trackingArea;

    TweenManager *_tweenManager;
    WordClockWordLayout *_layout;
    WordClockWordManager *_wordClockWordManager;
    NSView *_focusView;
    WordClockMetalView *_metalView;

    WordClockViewController *_controller;
    NSTrackingArea *_trackingArea;
    GuidesView *_guidesView;

    BOOL _tracksMouseEvents;
}
@property(nonatomic, assign) WordClockViewController *controller;
@property(nonatomic, assign) WordClockMetalView *metalView;
@property(nonatomic, retain) NSView *focusView;
@property(nonatomic, retain) GuidesView *guidesView;
@property(nonatomic, retain, readonly) WordClockWordManager *wordClockWordManager;
@property(nonatomic) BOOL tracksMouseEvents;

- (instancetype)initWithFrame:(NSRect)frameRect;

- (void)updateFromPreferences;

- (void)drawView;
- (void)reshape;

- (void)startAnimation;
- (void)stopAnimation;

- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray;
@end

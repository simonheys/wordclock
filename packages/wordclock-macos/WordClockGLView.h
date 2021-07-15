//
//  WordClockGLView.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "culling.h"

#define kWordClockWordTextureMaximumPixelsCombined 14 * 1024 * 1024 / 2

@class WordClockGLViewController;
@class WordClockWordLayout;
@class GuidesView;
@class WordClockWordManager;
@class TweenManager;

@interface WordClockGLView : NSView {
   @private
    NSOpenGLPixelFormat *pixelFormat;

    WordClockGLViewController *controller;

    CVDisplayLinkRef displayLink;
    BOOL isAnimating;
    BOOL hasRenderedTextures;

    NSTrackingRectTag _trackingRectTag;

    WordClockRectsForCulling *_rectsForCulling;
    int *_visibleWordIndices;
    NSInteger _numberOfWords;
    GLuint *_spriteTexture;
    GLshort *_coordinates;
    GLfloat *_vertices;
    GLfloat *_colours;
    BOOL *_highlighted;
    int _textureRenderRotaIndex;

    GuidesView *guidesView;
    NSTrackingArea *trackingArea;

    TweenManager *_tweenManager;
    WordClockWordLayout *_layout;
    WordClockWordManager *_wordClockWordManager;
    NSOpenGLContext *_openGLContext;
    NSView *_focusView;

    WordClockGLViewController *_controller;
    NSTrackingArea *_trackingArea;
    GuidesView *_guidesView;

    BOOL _tracksMouseEvents;
}
@property(nonatomic, assign) WordClockGLViewController *controller;
@property(nonatomic, retain) NSView *focusView;
@property(nonatomic, retain) GuidesView *guidesView;
@property(nonatomic, retain) NSOpenGLContext *openGLContext;
@property(nonatomic, retain, readonly) WordClockWordManager *wordClockWordManager;
@property(nonatomic) BOOL tracksMouseEvents;

- (instancetype)initWithFrame:(NSRect)frameRect;
- (instancetype)initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext *)context;

- (NSOpenGLContext *)openGLContext;

- (void)updateFromPreferences;

- (void)drawView;
- (void)reshape;

- (void)startAnimation;
- (void)stopAnimation;

- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray;
@end

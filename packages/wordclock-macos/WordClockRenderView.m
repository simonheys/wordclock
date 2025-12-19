//
//  WordClockRenderView.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockRenderView.h"

#import <CoreGraphics/CoreGraphics.h>
#import <Metal/Metal.h>
#include <math.h>

#import "GuidesView.h"
#import "GuidesViewLinear.h"
#import "GuidesViewRotary.h"
#import "Scene.h"
#import "TweenManager.h"
#import "WordClockMetalView.h"
#import "WordClockPreferences.h"
#import "WordClockViewController.h"
#import "WordClockWord.h"
#import "WordClockWordLayout.h"
#import "WordClockWordManager.h"

@interface WordClockRenderView ()
@property(nonatomic, retain) TweenManager *tweenManager;
@property(nonatomic, retain) WordClockWordLayout *layout;
@property(nonatomic, retain) WordClockWordManager *wordClockWordManager;
@property(nonatomic, retain) NSTrackingArea *trackingArea;
- (void)updateBackgroundColor;
- (void)deleteTextures;
- (void)renderTextures;
- (void)updateSceneAndMetal;
- (void)updateMetalGuideVerticesWithScale:(float)scale;
- (void)updateMetalTexturesWithScale:(float)scale;
- (void)clearWordPointers;
@end

static void WordClockAppendGuideVertex(float *positions, float *colors, NSUInteger *vertexIndex, float x, float y, const float *color, float scale) {
    const NSUInteger positionIndex = (*vertexIndex) * 2;
    positions[positionIndex] = x * scale;
    positions[positionIndex + 1] = y * scale;
    const NSUInteger colorIndex = (*vertexIndex) * 4;
    colors[colorIndex] = color[0];
    colors[colorIndex + 1] = color[1];
    colors[colorIndex + 2] = color[2];
    colors[colorIndex + 3] = color[3];
    (*vertexIndex)++;
}

static void WordClockAppendGuideLine(float *positions, float *colors, NSUInteger *vertexIndex, float x0, float y0, float x1, float y1, const float *color, float scale) {
    WordClockAppendGuideVertex(positions, colors, vertexIndex, x0, y0, color, scale);
    WordClockAppendGuideVertex(positions, colors, vertexIndex, x1, y1, color, scale);
}

@implementation WordClockRenderView

@synthesize controller = _controller;
@synthesize metalView = _metalView;
@synthesize guidesView = _guidesView;
@synthesize trackingArea = _trackingArea;
@synthesize tweenManager = _tweenManager;
@synthesize layout = _layout;
@synthesize wordClockWordManager = _wordClockWordManager;
@synthesize focusView = _focusView;
@synthesize tracksMouseEvents = _tracksMouseEvents;

- (void)dealloc {
    @try {
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCStyleKey];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCBackgroundColourKey];
    } @catch (NSException *exception) {
    }
    [self stopAnimation];
    [_tweenManager release];
    [_guidesView release];
    [self deleteTextures];
    [self clearWordPointers];

    free(_coordinates);
    free(_vertices);
    free(_rectsForCulling);
    free(_colours);
    free(_highlighted);

#ifndef SCREENSAVER
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:_focusView];
#endif
    [self.focusView removeTrackingArea:self.trackingArea];
    [_trackingArea release];
    [_focusView release];
    [_layout release];
    [_wordClockWordManager release];
    [super dealloc];
}

- (TweenManager *)tweenManager {
    if (nil == _tweenManager) {
        _tweenManager = [TweenManager new];
    }
    return _tweenManager;
}

- (WordClockWordManager *)wordClockWordManager {
    if (nil == _wordClockWordManager) {
        _wordClockWordManager = [WordClockWordManager new];
    }
    return _wordClockWordManager;
}

- (CVReturn)getFrameForTime:(const CVTimeStamp *)outputTime {
    // There is no autorelease pool when this method is called because it will
    // be called from a background thread It's important to create one or you
    // will leak objects
    @autoreleasepool {
        // Update the animation
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        [[self.controller scene] advanceTimeBy:(currentTime - [controller renderTime])];
        [self.controller setRenderTime:currentTime];

        [self.tweenManager update];
        [self drawView];
    }
    return kCVReturnSuccess;
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext) {
    CVReturn result = [(WordClockRenderView *)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void)setupDisplayLink {
    DDLogVerbose(@"setupDisplayLink");
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);

    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
    CVDisplayLinkSetCurrentCGDisplay(displayLink, CGMainDisplayID());
}

- (void)setTracksMouseEvents:(BOOL)tracksMouseEvents {
    _tracksMouseEvents = tracksMouseEvents;
    if (_tracksMouseEvents) {
        DDLogVerbose(@"adding tracking area:%@", NSStringFromRect([self.focusView visibleRect]));
        self.trackingArea = [[[NSTrackingArea alloc] initWithRect:[self.focusView visibleRect] options:NSTrackingInVisibleRect | NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingAssumeInside owner:self userInfo:nil] autorelease];
        [self.focusView addTrackingArea:self.trackingArea];
        if (self != _focusView) {
            [_focusView setNextResponder:self];
        }
    } else {
        DDLogVerbose(@"removing tracking area:%@", NSStringFromRect([self.focusView visibleRect]));
        [self.focusView removeTrackingArea:self.trackingArea];
        self.trackingArea = nil;
    }
    [self updateGuidesView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:WCStyleKey]) {
        switch ([WordClockPreferences sharedInstance].style) {
            case WCStyleLinear:
                [self.layout linearSelected:self];
                break;
            case WCStyleRotary:
                [self.layout rotarySelected:self];
                break;
        }
        [self updateGuidesView];
    } else if ([keyPath isEqual:WCBackgroundColourKey]) {
        [self updateBackgroundColor];
    }
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    DDLogVerbose(@"initWithFrame:%@", NSStringFromRect(frameRect));

    self = [super initWithFrame:frameRect];
    if (self) {
        self.focusView = self;

        self.layout = [[[WordClockWordLayout alloc] initWithWordClockWordManager:self.wordClockWordManager tweenManager:self.tweenManager] autorelease];

        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCStyleKey options:NSKeyValueObservingOptionNew context:NULL];
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCBackgroundColourKey options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)setFocusView:(NSView *)focusView {
#ifndef SCREENSAVER
    if (_focusView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:_focusView];
    }
#endif
    [focusView retain];
    [_focusView release];
    _focusView = focusView;
#ifndef SCREENSAVER
    if (_focusView) {
        [_focusView setPostsFrameChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reshape) name:NSViewFrameDidChangeNotification object:_focusView];
    }
#endif
    if (self != _focusView && self.tracksMouseEvents) {
        [_focusView setNextResponder:self];
    }
}

// This method will be called on the main thread when resizing, but we may be
// drawing on a secondary thread through the display link Add a mutex around to
// avoid the threads accessing the context simultaneously
- (void)reshape {
    [[self.controller scene] setViewportRect:[self.focusView bounds]];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Ignore if the display link is still running
    if (!CVDisplayLinkIsRunning(displayLink)) {
        [self drawView];
    }
}

// This method will be called on both the main thread (through -drawRect:) and a
// secondary thread (through the display link rendering loop) Also, when
// resizing the view, -reshape is called on the main thread, but we may be
// drawing on a secondary thread Add a mutex around to avoid the threads
// accessing the context simultaneously
- (void)drawView {
    [self updateSceneAndMetal];
}

- (void)startAnimation {
    if (!displayLink) {
        [self setupDisplayLink];
    }
    DDLogVerbose(@"startAnimation");
    if (displayLink && !CVDisplayLinkIsRunning(displayLink)) {
        CVDisplayLinkStart(displayLink);
    }
}

- (void)stopAnimation {
    DDLogVerbose(@"stopAnimation");
    [self.tweenManager removeAllTweens];
    // reset highlights
    for (WordClockWord *word in self.wordClockWordManager.word) {
        [word setHighlighted:word.highlighted animated:NO];
    }
    if (displayLink && CVDisplayLinkIsRunning(displayLink)) {
        CVDisplayLinkStop(displayLink);
        CVDisplayLinkRelease(displayLink);
        displayLink = NULL;
    }
}

// ____________________________________________________________________________________________________
// preferences

// TODO not sure this realy belongs here

- (void)updateFromPreferences {
    DDLogVerbose(@"updateFromPreferences");
    WordClockWord *w;

    // check what's changed and act accrodingly
    // just kerning? just leading?
    // typeface changes? etc.

    // update base size calulcations for all the words
    NSString *fontName = [WordClockPreferences sharedInstance].fontName;

    float tracking = [WordClockPreferences sharedInstance].tracking;
    WCCaseAdjustment caseAdjustment = [WordClockPreferences sharedInstance].caseAdjustment;
    for (w in self.wordClockWordManager.word) {
        [w setFontWithName:fontName tracking:tracking caseAdjustment:caseAdjustment];
    }

    [self deleteTextures];
    // TODO check if new logic is needed...
    [self renderTextures];

    [self updateBackgroundColor];
    [self updateGuidesView];

    [self.layout texturesDidChange];
}

- (void)updateBackgroundColor {
    NSColor *color = [WordClockPreferences sharedInstance].backgroundColour;

    CGFloat red, green, blue, alpha;
    NSColor *normalizedColor = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    if (!normalizedColor) {
        normalizedColor = color;
    }
    [normalizedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    if (self.metalView) {
        self.metalView.clearColor = MTLClearColorMake(red, green, blue, alpha);
    }
}

// ____________________________________________________________________________________________________
// textures

- (void)renderTextures {
    WordClockWord *w;
    uint i;

    i = 0;
    for (w in self.wordClockWordManager.word) {
        [w setColourPointer:&_colours[i * 4 * 4]];
        [w setHighlightedPointer:&_highlighted[i]];
        i++;
    }

    [self updateMetalTexturesWithScale:4.0f];
}

- (void)deleteTextures {
    if (self.metalView) {
        [self.metalView updateWordTextures:@[]];
    }
}

- (void)clearWordPointers {
    if (!_wordClockWordManager) {
        return;
    }
    for (WordClockWord *word in _wordClockWordManager.word) {
        [word setColourPointer:NULL];
        [word setHighlightedPointer:NULL];
    }
}

- (void)updateMetalTexturesWithScale:(float)scale {
    if (!self.metalView || !self.metalView.device) {
        return;
    }

    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:_numberOfWords];
    id<MTLDevice> device = self.metalView.device;
    size_t width = 0;
    size_t height = 0;
    NSUInteger wordIndex = 0;

    for (WordClockWord *word in self.wordClockWordManager.word) {
        NSData *bitmap = [word bitmapDataForScale:scale width:&width height:&height];
        if (!bitmap || width == 0 || height == 0) {
            [textures addObject:[NSNull null]];
            wordIndex++;
            continue;
        }

        MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:width height:height mipmapped:NO];
        descriptor.usage = MTLTextureUsageShaderRead;

        id<MTLTexture> texture = [device newTextureWithDescriptor:descriptor];
        if (!texture) {
            [textures addObject:[NSNull null]];
            wordIndex++;
            continue;
        }

        MTLRegion region = MTLRegionMake2D(0, 0, width, height);
        [texture replaceRegion:region mipmapLevel:0 withBytes:[bitmap bytes] bytesPerRow:width * 4];

        [textures addObject:texture];
        [texture release];
        wordIndex++;
    }

    [self.metalView updateWordTextures:textures];
}

// ____________________________________________________________________________________________________
// update

// prefs have changed; need to re-render all the textures
- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray {
    // ditch all the old textures
    [self deleteTextures];
    [self clearWordPointers];

    // need to update logic in WordClockWordManager
    [self.wordClockWordManager setLogic:logicArray label:labelArray tweenManager:self.tweenManager];

    _numberOfWords = self.wordClockWordManager.numberOfWords;

    // because logic has changed, number of words has probably changed
    // so need a new set of coordinates and vertices
    free(_coordinates);

    _coordinates = malloc(_numberOfWords * 8 * sizeof(short));
    uint offset = 0;
    for (uint i = 0; i < _numberOfWords; i++) {
        _coordinates[offset++] = 0;
        _coordinates[offset++] = 1;
        _coordinates[offset++] = 1;
        _coordinates[offset++] = 1;
        _coordinates[offset++] = 0;
        _coordinates[offset++] = 0;
        _coordinates[offset++] = 1;
        _coordinates[offset++] = 0;
    }

    free(_vertices);
    _vertices = malloc(_numberOfWords * 8 * sizeof(float));

    free(_rectsForCulling);
    _rectsForCulling = malloc(_numberOfWords * sizeof(WordClockRectsForCulling));

    // layout should calculate all the vertices directly into this array
    self.layout.vertices = _vertices;
    self.layout.rectsForCulling = _rectsForCulling;

    free(_colours);
    _colours = malloc(_numberOfWords * 4 * 4 * sizeof(float));

    free(_highlighted);
    _highlighted = malloc(_numberOfWords * sizeof(BOOL));

    [self renderTextures];
}

// ____________________________________________________________________________________________________
// guides

#pragma mark - guides

- (void)updateGuidesView {
    @synchronized(self) {
        if (nil != self.guidesView || !self.tracksMouseEvents) {
            self.guidesView = nil;
        }

        switch ([WordClockPreferences sharedInstance].style) {
            case WCStyleLinear:
                self.guidesView = [[[GuidesViewLinear alloc] init] autorelease];
                break;
            case WCStyleRotary:
                self.guidesView = [[[GuidesViewRotary alloc] init] autorelease];
                break;
        }
        self.guidesView.scale = [[self controller] scene].scale;
        self.guidesView.view = self.focusView;
    }
}

- (void)updateSceneAndMetal {
    if (!(_numberOfWords > 0)) {
        return;
    }
    [self.layout update];
    if (self.metalView && _vertices && _colours && _coordinates) {
        float sceneScale = 1.0f;
        if (self.controller.scene) {
            sceneScale = self.controller.scene.scale;
        }
        [self.metalView updateWordVertices:_vertices colors:_colours texCoords:_coordinates wordCount:_numberOfWords scale:sceneScale];
        [self updateMetalGuideVerticesWithScale:sceneScale];
    }
}

- (void)updateMetalGuideVerticesWithScale:(float)scale {
    if (!self.metalView) {
        return;
    }
    if (!self.guidesView || !(self.guidesView.mouseInside || self.guidesView.dragging)) {
        [self.metalView updateGuideVertices:NULL colors:NULL count:0];
        return;
    }

    const float clampedScale = (scale > 0.0f) ? scale : 1.0f;
    const BOOL lightGuides = [self.guidesView shouldDrawWithLightGuideColor];
    const float base = lightGuides ? 0.8f : 0.2f;
    const float dimColor[4] = {base, base, base, 0.3f};
    const float strongColor[4] = {base, base, base, 0.7f};

    switch ([WordClockPreferences sharedInstance].style) {
        case WCStyleLinear: {
            const NSSize size = [[NSScreen mainScreen] visibleFrame].size;
            const float offsetX = 0.5f + roundf(size.width * 0.5f);
            const float offsetY = 0.5f + roundf(size.height * 0.5f);
            const float l = [WordClockPreferences sharedInstance].linearMarginLeft - offsetX;
            const float r = (size.width - [WordClockPreferences sharedInstance].linearMarginRight) - offsetX;
            const float t = [WordClockPreferences sharedInstance].linearMarginTop - offsetY;
            const float b = (size.height - [WordClockPreferences sharedInstance].linearMarginBottom) - offsetY;
            const float leftEdge = -offsetX;
            const float rightEdge = size.width - offsetX;
            const float topEdge = -offsetY;
            const float bottomEdge = size.height - offsetY;

            enum { kLinearGuideMaxVertices = 16 };
            float positions[kLinearGuideMaxVertices * 2];
            float colors[kLinearGuideMaxVertices * 4];
            NSUInteger vertexIndex = 0;

            WordClockAppendGuideLine(positions, colors, &vertexIndex, l, topEdge, l, bottomEdge, dimColor, clampedScale);
            WordClockAppendGuideLine(positions, colors, &vertexIndex, r, topEdge, r, bottomEdge, dimColor, clampedScale);
            WordClockAppendGuideLine(positions, colors, &vertexIndex, leftEdge, t, rightEdge, t, dimColor, clampedScale);
            WordClockAppendGuideLine(positions, colors, &vertexIndex, leftEdge, b, rightEdge, b, dimColor, clampedScale);

            WordClockAppendGuideLine(positions, colors, &vertexIndex, l, t, l, b, strongColor, clampedScale);
            WordClockAppendGuideLine(positions, colors, &vertexIndex, r, t, r, b, strongColor, clampedScale);
            WordClockAppendGuideLine(positions, colors, &vertexIndex, l, t, r, t, strongColor, clampedScale);
            WordClockAppendGuideLine(positions, colors, &vertexIndex, l, b, r, b, strongColor, clampedScale);

            [self.metalView updateGuideVertices:positions colors:colors count:vertexIndex];
            break;
        }
        case WCStyleRotary: {
            const NSSize size = [[NSScreen mainScreen] visibleFrame].size;
            const float h = [WordClockPreferences sharedInstance].rotaryTranslateX;
            const float v = [WordClockPreferences sharedInstance].rotaryTranslateY;
            const float leftEdge = -0.5f * size.width;
            const float rightEdge = 0.5f * size.width;
            const float topEdge = -0.5f * size.height;
            const float bottomEdge = 0.5f * size.height;
            const float radius = 100.0f * [WordClockPreferences sharedInstance].rotaryScale;

            enum { kRotaryGuideSegments = 360, kRotaryGuideMaxVertices = 4 + kRotaryGuideSegments * 2 };
            float positions[kRotaryGuideMaxVertices * 2];
            float colors[kRotaryGuideMaxVertices * 4];
            NSUInteger vertexIndex = 0;

            WordClockAppendGuideLine(positions, colors, &vertexIndex, h, topEdge, h, bottomEdge, dimColor, clampedScale);
            WordClockAppendGuideLine(positions, colors, &vertexIndex, leftEdge, v, rightEdge, v, dimColor, clampedScale);

            const float step = (float)(2.0 * M_PI) / (float)kRotaryGuideSegments;
            for (NSUInteger i = 0; i < kRotaryGuideSegments; i++) {
                const float angle0 = (float)i * step;
                const float angle1 = (float)(i + 1) * step;
                const float x0 = h + sinf(angle0) * radius;
                const float y0 = v + cosf(angle0) * radius;
                const float x1 = h + sinf(angle1) * radius;
                const float y1 = v + cosf(angle1) * radius;
                WordClockAppendGuideLine(positions, colors, &vertexIndex, x0, y0, x1, y1, strongColor, clampedScale);
            }

            [self.metalView updateGuideVertices:positions colors:colors count:vertexIndex];
            break;
        }
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    if (!self.tracksMouseEvents) {
        [super mouseExited:theEvent];
    } else {
        [self.guidesView mouseExited:theEvent];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent {
    if (!self.tracksMouseEvents) {
        [super mouseMoved:theEvent];
    } else {
        [self.guidesView mouseMoved:theEvent];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (!self.tracksMouseEvents) {
        [super mouseDown:theEvent];
    } else {
        [self.guidesView updateWithMouseDownEvent:theEvent];
    }
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)isOpaque {
    return YES;
}
@end

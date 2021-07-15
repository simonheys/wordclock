//
//  WordClockGLView.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//
//
//  WordClockGLView.m
//  TESTWORDCLOCK
//
//  Created by Simon on 26/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WordClockGLView.h"

#import <OpenGL/gl.h>

#import "GuidesView.h"
#import "GuidesViewLinear.h"
#import "GuidesViewRotary.h"
#import "Scene.h"
#import "TweenManager.h"
#import "WordClockGLViewController.h"
#import "WordClockPreferences.h"
#import "WordClockWord.h"
#import "WordClockWordLayout.h"
#import "WordClockWordManager.h"

@interface WordClockGLView ()
@property(nonatomic, retain) TweenManager *tweenManager;
@property(nonatomic, retain) WordClockWordLayout *layout;
@property(nonatomic, retain) WordClockWordManager *wordClockWordManager;
@property(nonatomic, retain) NSTrackingArea *trackingArea;
- (void)updateBackgroundColor;
- (void)deleteTextures;
- (void)renderTextures;
- (void)drawSceneTemp;
- (int)indexOfWordWithOriginalLabel:(NSString *)label;
@end

@implementation WordClockGLView

@synthesize controller = _controller;
@synthesize guidesView = _guidesView;
@synthesize trackingArea = _trackingArea;
@synthesize tweenManager = _tweenManager;
@synthesize layout = _layout;
@synthesize wordClockWordManager = _wordClockWordManager;
@synthesize focusView = _focusView;
@synthesize openGLContext = _openGLContext;
@synthesize tracksMouseEvents = _tracksMouseEvents;

- (void)dealloc {
    @try {
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:@"style"];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:@"backgroundColour"];
    } @catch (NSException *exception) {
    }
    [self stopAnimation];
    [_tweenManager release];
    // Destroy the context
    [_openGLContext release];
    [pixelFormat release];
    [_guidesView release];
    [self deleteTextures];

    free(_coordinates);
    free(_vertices);
    free(_rectsForCulling);
    free(_colours);
    free(_highlighted);
    free(_visibleWordIndices);

    [self.focusView removeTrackingArea:self.trackingArea];
    [_trackingArea release];
    [_focusView release];
    [_layout release];
    [_wordClockWordManager release];

#ifndef SCREENSAVER
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewGlobalFrameDidChangeNotification object:self];
#endif
    [super dealloc];
}

- (NSOpenGLPixelFormat *)pixelFormat {
    return pixelFormat;
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
    //	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @autoreleasepool {
        // Update the animation
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        [[self.controller scene] advanceTimeBy:(currentTime - [controller renderTime])];
        [self.controller setRenderTime:currentTime];

        [self.tweenManager update];
        [self drawView];

        //	[pool release];
    }
    return kCVReturnSuccess;
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext) {
    CVReturn result = [(WordClockGLView *)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void)setupDisplayLink {
    DDLogVerbose(@"setupDisplayLink");
    // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);

    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);

    // Set the display link for the current renderer
    CGLContextObj cglContext = [self.openGLContext CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
}

- (instancetype)initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext *)context {
    DDLogVerbose(@"initWithFrame:%@ shareContext:%@", NSStringFromRect(frameRect), context);

    NSOpenGLPixelFormatAttribute attribs[] = {kCGLPFAAccelerated, kCGLPFADoubleBuffer, NSOpenGLPFAAllRenderers, kCGLPFAColorSize, 32, NSOpenGLPFAAlphaSize, 8, NSOpenGLPFAMultisample, NSOpenGLPFASampleBuffers, 1, NSOpenGLPFASamples, 4, NSOpenGLPFAMinimumPolicy, NSOpenGLPFAClosestPolicy, 0};

    NSOpenGLPixelFormatAttribute attribsAlt[] = {kCGLPFAAccelerated, kCGLPFADoubleBuffer, NSOpenGLPFAAllRenderers, kCGLPFAColorSize, 32, NSOpenGLPFAAlphaSize, 8, NSOpenGLPFAMinimumPolicy, NSOpenGLPFAClosestPolicy, 0};

    self = [super initWithFrame:frameRect];
    if (self) {
        self.focusView = self;

        DDLogVerbose(@"creating…");
        pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];

        if (!pixelFormat) {
            pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribsAlt];
        }
        if (!pixelFormat) {
            DDLogVerbose(@"No OpenGL pixel format");
        }
        // NSOpenGLView does not handle context sharing, so we draw to a custom
        // NSView instead
        self.openGLContext = [[[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:context] autorelease];

        DDLogVerbose(@"openGLContext:%@", self.openGLContext);
        [self.openGLContext makeCurrentContext];

        // Look for changes in view size
        // Note, -reshape will not be called automatically on size changes
        // because NSView does not export it to override
#ifndef SCREENSAVER
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reshape) name:NSViewGlobalFrameDidChangeNotification object:self];
#endif

        self.layout = [[[WordClockWordLayout alloc] initWithWordClockWordManager:self.wordClockWordManager tweenManager:self.tweenManager] autorelease];

        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:@"style" options:NSKeyValueObservingOptionNew context:NULL];
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:@"backgroundColour" options:NSKeyValueObservingOptionNew context:NULL];
    }

    return self;
}

- (void)setOpenGLContext:(NSOpenGLContext *)openGLContext {
    [openGLContext retain];
    [_openGLContext release];
    _openGLContext = openGLContext;

    [_openGLContext makeCurrentContext];

    // Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [_openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
}

- (void)setTracksMouseEvents:(BOOL)tracksMouseEvents {
    _tracksMouseEvents = tracksMouseEvents;
    if (_tracksMouseEvents) {
        // NSTrackingAssumeInside because we're full screen at this point
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
    DDLogVerbose(@"thred main?:%@", [NSThread isMainThread] ? @"YES" : @"NO");
    if ([keyPath isEqual:@"style"]) {
        switch ([WordClockPreferences sharedInstance].style) {
            case WCStyleLinear:
                [self.layout linearSelected:self];
                break;
            case WCStyleRotary:
                [self.layout rotarySelected:self];
                break;
        }
        [self updateGuidesView];
    } else if ([keyPath isEqual:@"backgroundColour"]) {
        [self updateBackgroundColor];
    }
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [self initWithFrame:frameRect shareContext:nil];
    return self;
}

- (void)setFocusView:(NSView *)focusView {
    [focusView retain];
    [_focusView release];
    _focusView = focusView;
    if ([_focusView respondsToSelector:@selector(setWantsBestResolutionOpenGLSurface:)]) {
        [_focusView setWantsBestResolutionOpenGLSurface:YES];
    }
    if (self != _focusView && self.tracksMouseEvents) {
        [_focusView setNextResponder:self];
    }
    [self.openGLContext setView:_focusView];
}

- (void)lockFocus {
    [super lockFocus];
    if ([self.openGLContext view] != self.focusView) {
        [self.openGLContext setView:self.focusView];
    }
}

// This method will be called on the main thread when resizing, but we may be
// drawing on a secondary thread through the display link Add a mutex around to
// avoid the threads accessing the context simultaneously
- (void)reshape {
    CGLLockContext([self.openGLContext CGLContextObj]);
    [self.openGLContext makeCurrentContext];

    // Delegate to the scene object to update for a change in the view size
    [[self.controller scene] setViewportRect:[self.focusView bounds]];
    [self.openGLContext update];

    [NSOpenGLContext clearCurrentContext];
    CGLUnlockContext([self.openGLContext CGLContextObj]);
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
    CGLLockContext([self.openGLContext CGLContextObj]);
    [self.openGLContext makeCurrentContext];

    [self drawSceneTemp];

    // draw the guides
    glDisable(GL_TEXTURE_2D);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);

    [self.guidesView drawGlView];

    /*
    glColor4f(0.5,0.5,0.5,0.5);
    NSRect r = [self bounds];
    glRectf(-0.5f*r.size.width,-0.5f*r.size.height,r.size.width,-0.5f*r.size.height+44);
    */
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_TEXTURE_2D);
    //}
    [self.openGLContext flushBuffer];
    [NSOpenGLContext clearCurrentContext];

    CGLUnlockContext([self.openGLContext CGLContextObj]);
}

//#ifndef SCREENSAVER
//- (BOOL)acceptsFirstResponder {
//    // We want this view to be able to receive key events
//    return YES;
//}
//
//- (void)keyDown:(NSEvent *)theEvent {
//    // Delegate to the controller object for handling key events
//    [self.controller keyDown:theEvent];
//}
//#endif

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

// TODO not sure thsi realy belongs here

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

    // set background colour
    /*
    CGColorRef color = [[WordClockPreferences sharedInstance]
    backgroundColour].CGColor; const CGFloat *components =
    CGColorGetComponents(color); CGFloat red = components[0]; CGFloat green =
    components[1]; CGFloat blue = components[2];
  */
    [self updateBackgroundColor];
    [self updateGuidesView];

    //	[[NSNotificationCenter defaultCenter]
    //		postNotificationName:@"kWordClockGLViewTexturesDidChangeNotification"
    //		object:self
    //	];

    [self.layout texturesDidChange];
    //	[self drawView];
}

- (void)updateBackgroundColor {
    NSColor *color = [WordClockPreferences sharedInstance].backgroundColour;

    CGFloat red, green, blue, alpha;
    @try {
        NSColor *normalizedColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        [normalizedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    } @catch (id theException) {
        red = 0.0f;
        green = 0.0f;
        blue = 0.0f;
        alpha = 1.0f;
    }
    if (nil != self.openGLContext) {
        CGLLockContext([self.openGLContext CGLContextObj]);
        [self.openGLContext makeCurrentContext];
        glClearColor(red, green, blue, alpha);
        [NSOpenGLContext clearCurrentContext];
        CGLUnlockContext([self.openGLContext CGLContextObj]);
    }
}

// ____________________________________________________________________________________________________
// textures

- (void)renderTextures {
    WordClockWord *w;
    uint i;
    int indexOfWord;

    // realloc spriteTextures[] to new length
    _spriteTexture = malloc(_numberOfWords * sizeof(GLuint));

    // render all the new ones by calling renderToOpenGlTexture: on every word
    i = 0;

    for (w in self.wordClockWordManager.word) {
        [w setColourPointer:&_colours[i * 4 * 4]];
        [w setHighlightedPointer:&_highlighted[i]];
        [w renderToOpenGlTexture:&_spriteTexture[i] withScale:4.0f];
        i++;
    }

    for (i = 0; i < [self.wordClockWordManager.word count]; i++) {
        //        _spriteTexture[i] = _spriteTexture[0];
        w = (self.wordClockWordManager.word)[i];
        indexOfWord = [self indexOfWordWithOriginalLabel:w.originalLabel];
        //        DDLogVerbose(@"%@
        //        indexOfWord:%d",w.originalLabel,indexOfWord);
        if (-1 != indexOfWord && i != indexOfWord) {
            _spriteTexture[i] = _spriteTexture[indexOfWord];
        }
    }

    hasRenderedTextures = YES;
}

- (int)indexOfWordWithOriginalLabel:(NSString *)label {
    WordClockWord *w;
    int i = 0;
    for (w in self.wordClockWordManager.word) {
        if ([w.originalLabel isEqualToString:label]) {
            return i;
        }
        i++;
    }
    return -1;
}

- (void)deleteTextures {
    if (!hasRenderedTextures) {
        return;
    }
    // free memory spriteTextures[]
    // http://www.khronos.org/opengles/documentation/opengles1_0/html/glDeleteTextures.html

    glDeleteTextures(_numberOfWords, _spriteTexture);
    free(_spriteTexture);
    hasRenderedTextures = NO;
}

// ____________________________________________________________________________________________________
// update

// prefs have changed; need to re-render all the textures
- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray {
    // ditch all the old textures
    [self deleteTextures];

    // need to update logic in WordClockWordManager
    [self.wordClockWordManager setLogic:logicArray label:labelArray tweenManager:self.tweenManager];

    _numberOfWords = self.wordClockWordManager.numberOfWords;

    // because logic has changed, number of words has probably changed
    // so need a new set of coordinates and vertices
    free(_coordinates);

    _coordinates = malloc(_numberOfWords * 8 * sizeof(GLshort));
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
    _vertices = malloc(_numberOfWords * 8 * sizeof(GLfloat));

    free(_rectsForCulling);
    _rectsForCulling = malloc(_numberOfWords * sizeof(WordClockRectsForCulling));

    // layout should calculate all the vertices directly into this array
    //	DDLogVerbose(@"&_vertices[0]:%d",&_vertices[0]);
    self.layout.vertices = _vertices;
    self.layout.rectsForCulling = _rectsForCulling;

    free(_colours);
    _colours = malloc(_numberOfWords * 4 * 4 * sizeof(GLfloat));

    free(_highlighted);
    _highlighted = malloc(_numberOfWords * sizeof(BOOL));

    free(_visibleWordIndices);
    _visibleWordIndices = malloc(_numberOfWords * sizeof(int));

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

// ____________________________________________________________________________________________________
// draw

#pragma mark - draw

- (void)drawSceneTemp {
    //	double startTimeInSeconds = getUpTime();
    glClear(GL_COLOR_BUFFER_BIT);

    if (!_numberOfWords > 0) {
        return;
    }

    NSMutableArray *highlightedIndices;
    highlightedIndices = [[NSMutableArray alloc] init];

    [self.layout update];

    //	[EAGLContext setCurrentContext:context];

    //    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    //	glClear(GL_COLOR_BUFFER_BIT);

    glPushMatrix();

#ifdef ENABLE_CULL
    NSSize size = [[NSScreen mainScreen] visibleFrame].size;
    float minX = -160;
    float maxX = 160;
    float minY = -240;
    float maxY = 240;

    minX = 0.5f * -size.width;
    maxX = 0.5f * size.width;
    minY = 0.5f * -size.height;
    maxY = 0.5f * size.height;

    //    minX = -640;
    //  maxX = 640;
    // minY = -400;
    // maxY = 400;

    // DDLogVerbose(@"bounds:%@",NSStringFromRect(self.bounds));

#endif

    // render all the vertices based on the coordinates in layout
    glVertexPointer(2, GL_FLOAT, 0, _vertices);
    glTexCoordPointer(2, GL_SHORT, 0, _coordinates);
    glColorPointer(4, GL_FLOAT, 0, _colours);
    //	-(int)cullRects:(WordClockRectsForCulling *)rects
    // length:(int)numberOfRects inRect:(CGRect)rect resultArrayPointer:(void
    //*)resultPointer;

#ifdef ENABLE_CULL
    int numberOfVisibleWords = cull_rects(_rectsForCulling, _numberOfWords, CGRectMake(minX, minY, maxX - minX, maxY - minY), _visibleWordIndices);
    int visibleWordIndex;

    for (uint i = 0; i < numberOfVisibleWords; i++) {
        visibleWordIndex = _visibleWordIndices[i];

        if (_highlighted[visibleWordIndex]) {
            [highlightedIndices addObject:[NSNumber numberWithInt:visibleWordIndex]];
        } else {
            glBindTexture(GL_TEXTURE_2D, _spriteTexture[visibleWordIndex]);
            glDrawArrays(GL_TRIANGLE_STRIP, visibleWordIndex << 2, 4);
        }
    }
#else
    for (uint i = 0; i < _numberOfWords; i++) {
        if (_highlighted[i]) {
            [highlightedIndices addObject:[NSNumber numberWithInt:i]];
        } else {
            glBindTexture(GL_TEXTURE_2D, _spriteTexture[i]);
            glDrawArrays(GL_TRIANGLE_STRIP, i << 2, 4);
            //			DDLogVerbose(@"%f %f %f
            //%f",_colours[i*4],_colours[1+i*4],_colours[2+i*4],_colours[3+i*4]);
        }
    }
#endif

    /*
    for ( uint i=0; i < _numberOfWords; i++ ) {
        visibleWordIndex = i;
        if ( _highlighted[visibleWordIndex] ) {
            [highlightedIndices addObject:[NSNumber
    numberWithInt:visibleWordIndex]];
        }
        else {
        //	if ( i == 0 ) {
        //		DDLogVerbose(@"f:%f minX:%f",_vertices[i<<2],minX);
        //	}
        //	if ( _vertices[i<<2] >= minX && _vertices[i<<2] <= maxX &&
    _vertices[1+i<<2] >= minY && _vertices[1+i<<2] <= maxY) {
            glBindTexture(GL_TEXTURE_2D, _spriteTexture[visibleWordIndex]);
            glDrawArrays(GL_TRIANGLE_STRIP, visibleWordIndex<<2, 4);
        //	}
        }
    }
  */

    // now draw the highlighted ones
    for (NSNumber *index in highlightedIndices) {
        uint i = [index intValue];
        glBindTexture(GL_TEXTURE_2D, _spriteTexture[i]);
        glDrawArrays(GL_TRIANGLE_STRIP, i << 2, 4);
    }

    //	glEnable(GL_DEPTH_TEST);
    glPopMatrix();

    //	glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    //    [context presentRenderbuffer:GL_RENDERBUFFER_OES];

    [highlightedIndices release];

    // redraw one textrue with current scale
    // re-render visible words only

#ifdef ENABLE_TEXTURE_SCALING
#ifdef ENABLE_CULL
    if (!_layout.isTweening) {
        _textureRenderRotaIndex = (_textureRenderRotaIndex + 1) % numberOfVisibleWords;
        visibleWordIndex = _visibleWordIndices[_textureRenderRotaIndex];
        [[self.wordClockWordManager.word objectAtIndex:visibleWordIndex] rerenderToOpenGlTexture:&_spriteTexture[visibleWordIndex] withScale:_layout.scale * [_layout getLayoutWordScale]];
    }
#else
    if (!_layout.isTweening) {
        _textureRenderRotaIndex = (_textureRenderRotaIndex + 1) % _numberOfWords;
        [[self.wordClockWordManager.word objectAtIndex:_textureRenderRotaIndex] rerenderToOpenGlTexture:&_spriteTexture[_textureRenderRotaIndex] withScale:_layout.scale * [_layout getLayoutWordScale]];
    }
#endif
#else
    if (!_layout.isTweening) {
        _textureRenderRotaIndex = (_textureRenderRotaIndex + 1) % _numberOfWords;
        //		[[self.wordClockWordManager.word
        // objectAtIndex:_textureRenderRotaIndex] renderMipMap];
    }
#endif
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

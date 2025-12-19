//
//  WordClockViewController.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockViewController.h"

#import "GuidesView.h"
#import "Scene.h"
#import "TweenManager.h"
#import "WordClockMetalView.h"
#import "WordClockPreferences.h"
#import "WordClockRenderView.h"
#import "WordClockWordManager.h"

@interface WordClockViewController ()
@property(nonatomic, retain) WordClockRenderView *renderView;
@property(nonatomic, retain) WordClockMetalView *metalView;
@property(nonatomic, retain) WordClockWordManager *wordClockWordManager;
- (void)updateFromPreferences;
@property(NS_NONATOMIC_IOSONLY, readonly) NSRect resizeRect;
@end

@implementation WordClockViewController

@synthesize renderView = _renderView;
@synthesize wordClockWordManager = _wordClockWordManager;
@synthesize parser = _parser;
@synthesize scene = _scene;
@synthesize isResizing = _isResizing;
@synthesize renderTime = _renderTime;
@synthesize userInteracitionEnabled = _userInteracitionEnabled;
@synthesize hudViewController = _hudViewController;
@synthesize tracksMouseEvents = _tracksMouseEvents;

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [self stopAnimation];
    @try {
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCWordsFileKey];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCFontNameKey];
    } @catch (NSException *exception) {
    }
    [_parser release];
    [_scene release];
    if (_metalView) {
        [_metalView removeFromSuperview];
    }
    [_renderView release];
    [_metalView release];
    [super dealloc];
}

//- (void)loadView
//{
//    DDLogVerbose(@"loadView");
//    [super loadView];
//}

- (void)setView:(NSView *)view {
    [super setView:view];
    [self updateFromPreferences];
    [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCWordsFileKey options:NSKeyValueObservingOptionNew context:NULL];
    [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCFontNameKey options:NSKeyValueObservingOptionNew context:NULL];
}

// ____________________________________________________________________________________________________
// kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:WCWordsFileKey]) {
        //		[self stopAnimation];
        [self updateFromPreferences];
    } else if ([keyPath isEqual:WCFontNameKey]) {
        //		[self stopAnimation];
        [self updateFromPreferences];
    }
}

// ____________________________________________________________________________________________________
// animation

- (void)startAnimation {
    DDLogVerbose(@"startAnimation");
#ifdef SCREENSAVER
    if (!_isAnimating) {
        if (nil != self.renderView) {
            [[self renderView] reshape];
            [[self renderView] startAnimation];
        }
        _isAnimating = YES;
    }
#else
    if (!_isAnimating && ![NSApp isHidden]) {
        if (nil != self.renderView) {
            DDLogVerbose(@"doing it");
            [[self renderView] startAnimation];
        }
        _isAnimating = YES;
    } else {
        DDLogVerbose(@"not doing it");
    }
#endif
}

- (void)stopAnimation {
    DDLogVerbose(@"stopAnimation");
    if (_isAnimating) {
        if (nil != self.renderView) {
            [self.renderView stopAnimation];
        }
        _isAnimating = NO;
    }
}

// ____________________________________________________________________________________________________
// preferences

- (void)updateFromPreferences {
    DDLogVerbose(@"updateFromPreferences");
    if (nil != _renderView) {
        [self.renderView stopAnimation];
    }
    if (nil != _metalView) {
        self.renderView.metalView = nil;
        [_metalView removeFromSuperview];
        [_metalView release];
        _metalView = nil;
    }
    self.scene = nil;
    self.renderView = nil;
    self.parser = [[[WordClockWordsFileParser alloc] init] autorelease];
    [self.parser setDelegate:self];

    NSString *xmlFile = [WordClockPreferences sharedInstance].wordsFile;
#ifdef SCREENSAVER
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
#else
    NSBundle *bundle = [NSBundle mainBundle];
#endif
    _currentXmlFile = xmlFile;
    NSString *fileName = [bundle pathForResource:_currentXmlFile ofType:nil inDirectory:@"json"];
    [self.parser parseFile:fileName];
}

// ____________________________________________________________________________________________________
// startup

- (void)wordClockWordsFileParserDidCompleteParsing:(WordClockWordsFileParser *)logicParser {
    DDLogVerbose(@"wordClockWordsFileParserDidCompleteParsing");
    self.renderView = [[[WordClockRenderView alloc] initWithFrame:self.view.bounds] autorelease];
    self.metalView = [[[WordClockMetalView alloc] initWithFrame:self.view.bounds] autorelease];
    self.renderView.metalView = self.metalView;
    self.scene = [[Scene new] autorelease];
    self.scene.wordClockWordManager = self.renderView.wordClockWordManager;
    self.renderView.controller = self;
    self.renderView.focusView = self.view;
    [self.renderView setLogic:logicParser.logic label:logicParser.label];
    [self.renderView updateFromPreferences];
    [self.renderView reshape];
    self.renderView.tracksMouseEvents = self.tracksMouseEvents;

    if (self.metalView && self.view) {
        self.metalView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        self.metalView.hidden = NO;
        [self.view addSubview:self.metalView positioned:NSWindowAbove relativeTo:nil];
    }
    if (_isAnimating) {
        [self.renderView startAnimation];
    }
    self.parser = nil;
    //	[self startAnimation];
}

- (void)setTracksMouseEvents:(BOOL)tracksMouseEvents {
    _tracksMouseEvents = tracksMouseEvents;
    self.renderView.tracksMouseEvents = _tracksMouseEvents;
    self.metalView.tracksMouseEvents = _tracksMouseEvents;
}

- (NSRect)resizeRect {
    const CGFloat resizeBoxSize = 16.0;

    NSRect contentViewRect = [[self.view window] contentRectForFrameRect:[[self.view window] frame]];
    NSRect resizeRect = NSMakeRect(NSMaxX(contentViewRect) - resizeBoxSize, NSMinY(contentViewRect), resizeBoxSize, resizeBoxSize);

    return resizeRect;
}

@end

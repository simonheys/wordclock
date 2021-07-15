//
//  WordClockGLViewController.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockGLViewController.h"
#import "WordClockGLView.h"
#import "Scene.h"
#import "WordClockPreferences.h"
#import "TweenManager.h"
#import "GuidesView.h"
#import "WordClockWordManager.h"

@interface WordClockGLViewController ()
@property (nonatomic, retain) WordClockGLView *glView;
@property (nonatomic, retain) WordClockWordManager *wordClockWordManager;
- (void)updateFromPreferences;
@property (NS_NONATOMIC_IOSONLY, readonly) NSRect resizeRect;
@end

@implementation WordClockGLViewController

@synthesize glView = _glView;
@synthesize wordClockWordManager = _wordClockWordManager;
@synthesize parser = _parser;
@synthesize scene = _scene;
@synthesize isResizing = _isResizing;
@synthesize renderTime = _renderTime;
@synthesize userInteracitionEnabled = _userInteracitionEnabled;
@synthesize hudViewController = _hudViewController;
@synthesize tracksMouseEvents = _tracksMouseEvents;

- (void)dealloc
{
    DDLogVerbose(@"dealloc");
    [self stopAnimation];
    @try {
    	[[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:@"xmlFile"];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:@"fontName"];
    }
    @catch (NSException *exception) {
    }
	[_parser release];
	[_scene release];
    [_glView release];
	[super dealloc];
}

//- (void)loadView
//{
//    DDLogVerbose(@"loadView");
//    [super loadView];
//}

- (void)setView:(NSView *)view
{
    [super setView:view];
	[self updateFromPreferences];
	[[WordClockPreferences sharedInstance] addObserver:self forKeyPath:@"xmlFile" options:NSKeyValueObservingOptionNew context:NULL];
	[[WordClockPreferences sharedInstance] addObserver:self forKeyPath:@"fontName" options:NSKeyValueObservingOptionNew context:NULL];
}

// ____________________________________________________________________________________________________ kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ( [keyPath isEqual:@"xmlFile"] ) {
//		[self stopAnimation];
		[self updateFromPreferences];
	}
	else if ( [keyPath isEqual:@"fontName"] ) {
//		[self stopAnimation];
		[self updateFromPreferences];
	}
}

// ____________________________________________________________________________________________________ animation

- (void)startAnimation {
    DDLogVerbose(@"startAnimation");
#ifdef SCREENSAVER
	if (!_isAnimating ) {
        if ( nil != self.glView ) {
            [[self glView] reshape];
            [[self glView] startAnimation];
        }
		_isAnimating = YES;
	}    
#else
	if (!_isAnimating && ![NSApp isHidden]) {
        if ( nil != self.glView ) {
            DDLogVerbose(@"doing it");
            [[self glView] startAnimation];
        }
		_isAnimating = YES;
	}
    else {
    
         DDLogVerbose(@"not doing it");
   }
#endif
}

- (void)stopAnimation {
    DDLogVerbose(@"stopAnimation");
	if (_isAnimating) {
        if ( nil != self.glView ) {
            [self.glView stopAnimation];
        }
		_isAnimating = NO;
	}
}

// ____________________________________________________________________________________________________ preferences

- (void)updateFromPreferences
{
    DDLogVerbose(@"updateFromPreferences");
    if ( nil != _glView ) {
        [self.glView stopAnimation];
    }
    self.scene = nil;
    self.glView = nil;
	self.parser = [[[LogicXmlFileParser alloc] init] autorelease];
	[self.parser setDelegate:self];

	NSString *xmlFile = [WordClockPreferences sharedInstance].xmlFile;
#ifdef SCREENSAVER
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
#else
	NSBundle *bundle = [NSBundle mainBundle];
#endif
    _currentXmlFile = xmlFile;
	NSString *fileName = [bundle pathForResource:_currentXmlFile ofType:nil inDirectory:@"json"];
	[self.parser parseFile:fileName];
}

// ____________________________________________________________________________________________________ startup

- (void)logicXmlFileParserDidCompleteParsing:(LogicXmlFileParser*)logicParser
{
    DDLogVerbose(@"logicXmlFileParserDidCompleteParsing");
	self.glView = [[[WordClockGLView alloc] initWithFrame:self.view.bounds] autorelease];
	self.scene = [[Scene new] autorelease];
    self.scene.wordClockWordManager = self.glView.wordClockWordManager;
	self.glView.controller = self;
    self.glView.focusView = self.view;
	[self.glView setLogic:logicParser.logic label:logicParser.label];
	[self.glView updateFromPreferences];
    [self.glView reshape];
    self.glView.tracksMouseEvents = self.tracksMouseEvents;
    if ( _isAnimating ) {
        [self.glView startAnimation];
    }
    self.parser = nil;
//	[self startAnimation];
}

- (void)setTracksMouseEvents:(BOOL)tracksMouseEvents
{
    _tracksMouseEvents = tracksMouseEvents;
    self.glView.tracksMouseEvents = _tracksMouseEvents;
}

- (NSRect)resizeRect {
	const CGFloat resizeBoxSize = 16.0;
	
	NSRect contentViewRect = [[self.view window] contentRectForFrameRect:[[self.view window] frame]];
	NSRect resizeRect = NSMakeRect(
		NSMaxX(contentViewRect) - resizeBoxSize,
		NSMinY(contentViewRect),
		resizeBoxSize,
		resizeBoxSize);
	
	return resizeRect;
}

@end

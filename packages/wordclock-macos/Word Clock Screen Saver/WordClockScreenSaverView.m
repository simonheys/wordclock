//
//  WordClockScreenSaverView.m
//  WordClock macOS
//
//  Created by Simon Heys on 25/11/2012.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockScreenSaverView.h"

#import <OpenGL/OpenGL.h>
#import <QuartzCore/QuartzCore.h>

#import "WCFileFunctionLevelFormatter.h"
#import "WordClockGLView.h"
#import "WordClockGLViewController.h"
#import "WordClockOptionsWindowController.h"
#import "WordClockPreferences.h"

@interface WordClockScreenSaverView ()
@property(nonatomic, retain) WordClockGLViewController *rootViewController;
@property(nonatomic, retain) NSOpenGLContext *mGLContext;
@property(nonatomic, retain) WordClockOptionsWindowController *optionsWindowController;
@property(nonatomic, retain) NSTimer *transitionTimer;
@property(nonatomic, retain) NSDate *dateOfLastTransition;
@end

@implementation WordClockScreenSaverView

@synthesize rootViewController = _rootViewController;
@synthesize mGLContext = _mGLContext;
@synthesize optionsWindowController = _optionsWindowController;
@synthesize transitionTimer = _transitionTimer;
@synthesize dateOfLastTransition = _dateOfLastTransition;

- (void)dealloc {
    @try {
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCStyleKey];
    } @catch (NSException *exception) {
    }
    [self stopTransitionTimer];
    [_rootViewController release];
    [_optionsWindowController release];
    [_dateOfLastTransition release];
    [super dealloc];
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        WCFileFunctionLevelFormatter *fileFunctionLevelFormatter = [WCFileFunctionLevelFormatter new];
        [[DDTTYLogger sharedInstance] setLogFormatter:fileFunctionLevelFormatter];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];

        self.optionsWindowController = [[WordClockOptionsWindowController new] autorelease];
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCStyleKey options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (BOOL)isOpaque {
    return YES;
}

- (void)startAnimation {
    DDLogVerbose(@"startAnimation");
    if (!self.rootViewController) {
        self.rootViewController = [[WordClockGLViewController new] autorelease];
        self.rootViewController.tracksMouseEvents = NO;
        self.rootViewController.view = self;
    }
    [self.rootViewController startAnimation];
    if (![self isPreview]) {
        if ([WordClockPreferences sharedInstance].transitionTime != 0) {
            [self startTransitionTimer];
        }
    }

    [super startAnimation];
}

- (void)stopAnimation {
    DDLogVerbose(@"stopAnimation");
    [self.rootViewController stopAnimation];
    [self stopTransitionTimer];
    [super stopAnimation];
}

- (BOOL)hasConfigureSheet {
    return YES;
}

- (NSWindow *)configureSheet {
    DDLogVerbose(@"self.optionsWindowController.window:%@", self.optionsWindowController.window);
    return self.optionsWindowController.window;
}

- (void)startTransitionTimer {
    if ([self.transitionTimer isValid]) {
        [self stopTransitionTimer];
    }
    NSTimeInterval ti = [WordClockPreferences sharedInstance].transitionTime;
    self.transitionTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(transitionTimerFired:) userInfo:nil repeats:YES];
}

- (void)stopTransitionTimer {
    if ([self.transitionTimer isValid]) {
        [self.transitionTimer invalidate];
        self.transitionTimer = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:WCStyleKey]) {
        self.dateOfLastTransition = [NSDate date];
    }
}

- (void)transitionTimerFired:(id)sender {
    NSTimeInterval timeIntervalSinceLastTransition = [[NSDate date] timeIntervalSinceDate:self.dateOfLastTransition];
    DDLogVerbose(@"timeIntervalSinceLastTransition:%f", timeIntervalSinceLastTransition);
    if (timeIntervalSinceLastTransition < 1) {
        return;
    }
    [self toggleStyle];
}

- (void)toggleStyle {
    [self.rootViewController stopAnimation];
    switch ([WordClockPreferences sharedInstance].style) {
        case WCStyleLinear:
            [WordClockPreferences sharedInstance].style = WCStyleRotary;
            break;
        case WCStyleRotary:
            [WordClockPreferences sharedInstance].style = WCStyleLinear;
            break;
    }
    [self.rootViewController startAnimation];
}

// ____________________________________________________________________________________________________
// crash logs

#pragma mark - crash logs

@end

//
//  AppDelegate.m
//  WordClock macOS
//
//  Created by Simon Heys on 25/11/2012.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "WordClockGLViewController.h"
#import "WordClockGLView.h"
#import "WordClockOptionsWindowController.h"
#import "WCFileFunctionLevelFormatter.h"

@interface AppDelegate ()
@property (nonatomic, retain) WordClockGLViewController *rootViewController;
@property (nonatomic, retain) WordClockOptionsWindowController *optionsWindowController;
@end

@implementation AppDelegate

@synthesize rootViewController = _rootViewController;
@synthesize optionsWindowController = _optionsWindowController;
@synthesize window = _window;
@synthesize customView = _customView;
@synthesize createButton = _createButton;
@synthesize destroyButton = _destroyButton;
@synthesize optionsButton = _optionsButton;

- (void)dealloc
{
    [_optionsWindowController release];
    [_rootViewController release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    WCFileFunctionLevelFormatter *fileFunctionLevelFormatter = [[WCFileFunctionLevelFormatter new] autorelease];
    [[DDTTYLogger sharedInstance] setLogFormatter:fileFunctionLevelFormatter];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (IBAction)destroyButtonPressed:(id)sender
{
    DDLogVerbose(@"destroyButtonPressed");
    if ( nil == self.rootViewController ) {
        return;
    }
    DDLogVerbose(@"destroying");
    self.rootViewController = nil;
}

- (IBAction)createButtonPressed:(id)sender
{
    DDLogVerbose(@"createButtonPressed");
    if ( nil != self.rootViewController ) {
        return;
    }
    DDLogVerbose(@"creating");
    self.rootViewController = [[WordClockGLViewController new] autorelease];
    self.rootViewController.view = self.customView;
    self.rootViewController.userInteracitionEnabled = NO;
   
    [self.rootViewController startAnimation];
}

- (WordClockOptionsWindowController *)optionsWindowController
{
    if ( nil == _optionsWindowController ) {
        _optionsWindowController = [WordClockOptionsWindowController new];
    }
    return _optionsWindowController;
}

- (IBAction)optionsButtonPressed:(id)sender {
    DDLogVerbose(@"optionsButtonPressed");
    [self.optionsWindowController.window makeKeyAndOrderFront:self];
    DDLogVerbose(@"self.optionsWindowController:%@",self.optionsWindowController);
    DDLogVerbose(@"self.optionsWindowController.window:%@",self.optionsWindowController.window);
}

@end

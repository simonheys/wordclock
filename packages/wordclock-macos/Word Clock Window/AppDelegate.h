//
//  AppDelegate.h
//  WordClock macOS
//
//  Created by Simon Heys on 25/11/2012.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WordClockGLViewController;
@class WordClockOptionsWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
    WordClockGLViewController *_rootViewController;
    WordClockOptionsWindowController *_optionsWindowController;
    NSWindow *_window;
    NSView *_customView;
    NSButton *_createButton;
    NSButton *_destroyButton;
    NSButton *_optionsButton;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *customView;
@property (assign) IBOutlet NSButton *createButton;
@property (assign) IBOutlet NSButton *destroyButton;
@property (assign) IBOutlet NSButton *optionsButton;

@end

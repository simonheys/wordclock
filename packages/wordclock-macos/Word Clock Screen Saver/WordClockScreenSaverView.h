//
//  WordClockScreenSaverView.h
//  WordClock macOS
//
//  Created by Simon Heys on 25/11/2012.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@class WordClockGLViewController;
@class WordClockOptionsWindowController;

@interface WordClockScreenSaverView : ScreenSaverView {
@private
    WordClockGLViewController *_rootViewController;
    NSOpenGLContext *_mGLContext;
    WordClockOptionsWindowController *_optionsWindowController;
    NSTimer *_transitionTimer;
    NSDate *_dateOfLastTransition;
}
@end

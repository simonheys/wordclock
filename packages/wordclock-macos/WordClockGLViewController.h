//
//  WordClockGLViewController.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WordClockWordsFileParser.h"

@class WordClockGLView;
@class HudViewController;
@class Scene;
@class WordClockWordManager;

@interface WordClockGLViewController : NSViewController <WordClockWordsFileParserDelegate> {
   @private
    WordClockGLView *_glView;
    WordClockWordManager *_wordClockWordManager;
    HudViewController *_hudViewController;
    WordClockWordsFileParser *_parser;
    //	NSWindow *fullScreenWindow;
    //	WordClockGLView *fullScreenView;
    Scene *_scene;
    CFAbsoluteTime _renderTime;

    NSString *_currentXmlFile;
    BOOL _isAnimating;
    BOOL _isResizing;
    BOOL _userInteracitionEnabled;
    BOOL _tracksMouseEvents;
}

@property(nonatomic, retain) WordClockWordsFileParser *parser;
@property(nonatomic, retain) Scene *scene;
@property(nonatomic, assign) HudViewController *hudViewController;
@property(nonatomic, retain, readonly) WordClockGLView *glView;
@property CFAbsoluteTime renderTime;
@property BOOL isResizing;
@property BOOL userInteracitionEnabled;
@property(nonatomic) BOOL tracksMouseEvents;

- (void)startAnimation;
- (void)stopAnimation;

@end

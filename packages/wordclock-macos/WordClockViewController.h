//
//  WordClockViewController.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WordClockWordsFileParser.h"

@class WordClockRenderView;
@class HudViewController;
@class Scene;
@class WordClockWordManager;

@interface WordClockViewController : NSViewController <WordClockWordsFileParserDelegate> {
   @private
    WordClockRenderView *_renderView;
    WordClockWordManager *_wordClockWordManager;
    HudViewController *_hudViewController;
    WordClockWordsFileParser *_parser;
    //	NSWindow *fullScreenWindow;
    //	WordClockRenderView *fullScreenView;
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
@property(nonatomic, retain, readonly) WordClockRenderView *renderView;
@property CFAbsoluteTime renderTime;
@property BOOL isResizing;
@property BOOL userInteracitionEnabled;
@property(nonatomic) BOOL tracksMouseEvents;

- (void)startAnimation;
- (void)stopAnimation;

@end

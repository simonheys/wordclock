//
//  WordClockViewController.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "DLog.h"
#import "DisplayLinkManager.h"
#import "LogicParser.h"
#import "LogicParserStringUtil.h"
#import "WordClockGLView.h"
#import "WordClockPreferences.h"
#import "WordClockViewControls.h"
#import "WordClockWordsFileParser.h"

@class LogicXmlFileParser;
@class WordClockGLView;

@interface WordClockViewController : GLKViewController <WordClockWordsFileParserDelegate> {
   @private
    NSInteger _previousSecond;
    WordClockWordsFileParser *_parser;
    NSString *_currentXmlFile;
    id delegate;
    BOOL _running;
    WordClockViewControls *_controls;
}
- (void)start;
- (void)stop;
- (void)begin;
- (void)appear;
- (void)runLoop;
- (void)updateFromPreferences;
- (void)predrawView;

@property(nonatomic, retain) id delegate;
@end

@interface WordClockViewController (WordClockViewControllerDelegate)
- (void)wordClockDidCompleteParsing:(WordClockViewController *)controller;
@end

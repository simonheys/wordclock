//
//  WordClockViewController.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LogicXmlFileParser.h"
#import "LogicParserStringUtil.h"
#import "LogicParser.h"
#import "WordClockGLView.h"
#import "WordClockPreferences.h"
#import "WordClockViewControls.h"
#import "DLog.h"
#import "DisplayLinkManager.h"

@class LogicXmlFileParser;
@class WordClockGLView;

@interface WordClockViewController : GLKViewController
{
@private
	NSInteger _previousSecond;
	LogicXmlFileParser *_parser;
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

@property (nonatomic, retain) id delegate;
@end

@interface WordClockViewController(WordClockViewControllerDelegate)
- (void)wordClockDidCompleteParsing:(WordClockViewController*)controller;
@end

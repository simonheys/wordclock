//
//  WordClockPreview.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 11/03/2009.
//  Copyright 2009 Simon Heys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordClockWordManager.h"
#import "WordClockPreferences.h"
#import "Tween.h"

#import "DLog.h"

@interface WordClockPreview : UIView 
{
@private
	NSMutableArray *_word;
	float _tracking;
	float _leading;
	UIColor *_foregroundColour;
	UIColor *_backgroundColour;
	UIColor *_highlightColour;
}

-(void)updateFromPreferences;

@property float tracking;
@property float leading;
@property (nonatomic, retain) UIColor *foregroundColour;
@property (nonatomic, retain) UIColor *backgroundColour;
@property (nonatomic, retain) UIColor *highlightColour;

@end

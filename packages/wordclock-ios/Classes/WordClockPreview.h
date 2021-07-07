//
//  WordClockPreview.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
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

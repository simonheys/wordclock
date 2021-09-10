//
//  WordClockPreview.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DLog.h"
#import "Tween.h"
#import "WordClockPreferences.h"
#import "WordClockWordManager.h"

@interface WordClockPreview : UIView {
   @private
    NSMutableArray *_word;
    float _tracking;
    float _leading;
    UIColor *_foregroundColour;
    UIColor *_backgroundColour;
    UIColor *_highlightColour;
}

- (void)updateFromPreferences;

@property float tracking;
@property float leading;
@property(nonatomic, retain) UIColor *foregroundColour;
@property(nonatomic, retain) UIColor *backgroundColour;
@property(nonatomic, retain) UIColor *highlightColour;

@end

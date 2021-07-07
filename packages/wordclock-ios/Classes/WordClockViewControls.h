//
//  WordClockViewControls.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 21/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Dlog.h"

#import <UIKit/UIKit.h>
#import "TouchableView.h"
#import "WordClockWordLayout.h"
#import "WordClockPreview.h"
#import "WordClockPreferences.h"
#import "NSDictionaryAdditions.h"

extern NSString *const kWordClockViewControlsConfigSelected;
extern NSString *const kWordClockViewControlsLinearSelected;
extern NSString *const kWordClockViewControlsRotarySelected;

typedef enum _WordClockViewControlsState {
    kWordClockViewControlsHiddenState,
    kWordClockViewControlsVisibleState,
	kWordClockViewControlsPreparingToFlipState,
    kWordClockViewControlsWaitingToBecomeVisibleState,
    kWordClockViewControlsWaitingToBecomeHiddenState
} WordClockViewControlsState;

@interface WordClockViewControls : TouchableView 
{
@private
	UIBarButtonItem *_lockButton;
	UIBarButtonItem *_resetButton;
	UIBarButtonItem *_linearOrRotaryButton;
	
	WordClockViewControlsState _state;
	BOOL _isCurrentTouchAcceptable;
	UIToolbar *_toolbar;
//	UISegmentedControl *_segmentedControl;
	NSTimer *_statusTimer;
	
//	UIDeviceOrientation _currentOrientation;
//	float _toolbarAngle;
	
//	BOOL _isRunningOnPad;
}

@end

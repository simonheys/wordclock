//
//  WordClockViewControls.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
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

//
//  WordClockViewControls.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Dlog.h"
#import "NSDictionaryAdditions.h"
#import "TouchableView.h"
#import "WordClockPreferences.h"
#import "WordClockPreview.h"
#import "WordClockWordLayout.h"

extern NSString *const kWordClockViewControlsConfigSelected;
extern NSString *const kWordClockViewControlsLinearSelected;
extern NSString *const kWordClockViewControlsRotarySelected;

typedef enum _WordClockViewControlsState { kWordClockViewControlsHiddenState, kWordClockViewControlsVisibleState, kWordClockViewControlsPreparingToFlipState, kWordClockViewControlsWaitingToBecomeVisibleState, kWordClockViewControlsWaitingToBecomeHiddenState } WordClockViewControlsState;

@interface WordClockViewControls : TouchableView {
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

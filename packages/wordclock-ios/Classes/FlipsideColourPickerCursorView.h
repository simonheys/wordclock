//
//  FlipsideColourPickerCursorView.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
//#import "NSLog.h"

@interface FlipsideColourPickerCursorView : UIView {
    UIColor *_colour;
}

@property(nonatomic, retain) UIColor *colour;

@end

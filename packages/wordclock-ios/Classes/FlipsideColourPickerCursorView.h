//
//  FlipsideColourPickerCursorView.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
//#import "NSLog.h"

@interface FlipsideColourPickerCursorView : UIView 
{
	UIColor *_colour;
}

@property (nonatomic, retain) UIColor *colour;

@end

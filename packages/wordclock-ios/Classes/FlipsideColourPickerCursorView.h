//
//  FlipsideColourPickerCursorView.h
//  iphone_word_clock
//
//  Created by Simon on 24/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
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

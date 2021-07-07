//
//  WordClockPreferences.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLog.h"
#import "TouchableView.h"

extern NSString *const WCLinearTranslateXKey;
extern NSString *const WCLinearTranslateYKey;
extern NSString *const WCLinearScaleKey;

extern NSString *const WCRotaryTranslateXKey;
extern NSString *const WCRotaryTranslateYKey;
extern NSString *const WCRotaryScaleKey;

typedef enum {
    WCJustificationLeft,
    WCJustificationCentre,
    WCJustificationRight,
	WCJustificationFull
} WCJustification;

typedef enum {
    WCCaseAdjustmentNone,
	WCCaseAdjustmentUpper,
    WCCaseAdjustmentLower
} WCCaseAdjustment;

typedef enum {
    WCStyleLinear,
	WCStyleRotary
} WCStyle;

@interface WordClockPreferences : NSObject {
	//NSString *xmlFile;
	UIColor *_backgroundColour;
	UIColor *_foregroundColour;
	UIColor *_highlightColour;
	NSString *_fontName;
	float _tracking;
	float _leading;
	WCCaseAdjustment _caseAdjustment;
	
	float _linearTranslateX;
	float _linearTranslateY;
	float _linearScale;

	float _rotaryTranslateX;
	float _rotaryTranslateY;
	float _rotaryScale;
	
	BOOL _locked;
	
	/* shouldn't have to declare these here, but getting compiler erros if not */
	NSString *xmlFile;
	NSString *fontName;
	UIColor *highlightColour;
	UIColor *foregroundColour;
	UIColor *backgroundColour;
	float leading;
	float tracking;
	WCJustification justification;
	WCCaseAdjustment caseAdjustment;
	WCStyle style;
	float linearTranslateX;
	float linearTranslateY;
	float linearScale;
	float rotaryTranslateX;
	float rotaryTranslateY;
	float rotaryScale;
	BOOL locked;
}
+ (WordClockPreferences*)sharedInstance;
+ (NSDictionary *)factoryDefaults;

@property (assign) NSString *xmlFile;
@property (assign) NSString *fontName;
@property (assign) UIColor *highlightColour;
@property (assign) UIColor *foregroundColour;
@property (assign) UIColor *backgroundColour;
@property float leading;
@property float tracking;
@property WCJustification justification;
@property WCCaseAdjustment caseAdjustment;
@property WCStyle style;

@property float linearTranslateX;
@property float linearTranslateY;
@property float linearScale;

@property float rotaryTranslateX;
@property float rotaryTranslateY;
@property float rotaryScale;

@property BOOL locked;


@end

//
//  WordClockPreferences.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

extern NSString *const WCLinearTranslateXKey;
extern NSString *const WCLinearTranslateYKey;
extern NSString *const WCLinearScaleKey;

extern NSString *const WCRotaryTranslateXKey;
extern NSString *const WCRotaryTranslateYKey;
extern NSString *const WCRotaryScaleKey;

typedef NS_ENUM(NSInteger, WCJustification) { WCJustificationLeft, WCJustificationCentre, WCJustificationRight, WCJustificationFull };

typedef NS_ENUM(NSInteger, WCCaseAdjustment) { WCCaseAdjustmentNone, WCCaseAdjustmentUpper, WCCaseAdjustmentLower };

typedef NS_ENUM(NSInteger, WCStyle) { WCStyleLinear, WCStyleRotary };

typedef NS_ENUM(NSInteger, WCTransitionStyle) {
    WCTransitionStyleSlow,
    WCTransitionStyleMedium,
    WCTransitionStyleFast,
};

@interface WordClockPreferences : NSObject {
   @private
    NSString *_xmlFile;
    NSString *_fontName;
    NSColor *_highlightColour;
    NSColor *_foregroundColour;
    NSColor *_backgroundColour;

    float _leading;
    float _tracking;
    WCJustification _justification;
    WCCaseAdjustment _caseAdjustment;
    WCStyle _style;

    float _linearTranslateX;
    float _linearTranslateY;
    float _linearScale;

    float _rotaryTranslateX;
    float _rotaryTranslateY;
    float _rotaryScale;

    float _linearMarginLeft;
    float _linearMarginRight;
    float _linearMarginTop;
    float _linearMarginBottom;

    NSInteger _transitionTime;
    WCTransitionStyle _transitionStyle;
}
+ (WordClockPreferences *)sharedInstance;
+ (NSDictionary *)factoryDefaults;
- (void)reset;

@property(nonatomic, retain) NSString *xmlFile;
@property(nonatomic, retain) NSString *fontName;
@property(nonatomic, retain) NSColor *highlightColour;
@property(nonatomic, retain) NSColor *foregroundColour;
@property(nonatomic, retain) NSColor *backgroundColour;

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

@property float linearMarginLeft;
@property float linearMarginRight;
@property float linearMarginTop;
@property float linearMarginBottom;

@property NSInteger transitionTime;
@property WCTransitionStyle transitionStyle;

@end

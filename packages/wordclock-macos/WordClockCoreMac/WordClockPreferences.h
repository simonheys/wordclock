//
//  WordClockPreferences.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

extern NSString *const WCWordsFileKey;
extern NSString *const WCFontNameKey;
extern NSString *const WCHighlightColourKey;
extern NSString *const WCForegroundColourKey;
extern NSString *const WCBackgroundColourKey;
extern NSString *const WCLeadingKey;
extern NSString *const WCTrackingKey;
extern NSString *const WCJustificationKey;
extern NSString *const WCCaseAdjustmentKey;
extern NSString *const WCStyleKey;

extern NSString *const WCLinearTranslateXKey;
extern NSString *const WCLinearTranslateYKey;
extern NSString *const WCLinearScaleKey;

extern NSString *const WCRotaryTranslateXKey;
extern NSString *const WCRotaryTranslateYKey;
extern NSString *const WCRotaryScaleKey;

extern NSString *const WCLinearMarginLeftKey;
extern NSString *const WCLinearMarginRightKey;
extern NSString *const WCLinearMarginTopKey;
extern NSString *const WCLinearMarginBottomKey;

extern NSString *const WCTransitionTimeKey;
extern NSString *const WCTransitionStyleKey;

typedef NS_ENUM(NSInteger, WCJustification) { WCJustificationLeft, WCJustificationCentre, WCJustificationRight, WCJustificationFull };

typedef NS_ENUM(NSInteger, WCCaseAdjustment) { WCCaseAdjustmentNone, WCCaseAdjustmentUpper, WCCaseAdjustmentLower };

typedef NS_ENUM(NSInteger, WCStyle) { WCStyleLinear, WCStyleRotary };

typedef NS_ENUM(NSInteger, WCTransitionStyle) {
    WCTransitionStyleSlow,
    WCTransitionStyleMedium,
    WCTransitionStyleFast,
};

@interface WordClockPreferences : NSObject {
}
+ (WordClockPreferences *)sharedInstance;
+ (NSDictionary *)factoryDefaults;
- (void)reset;

@property(nonatomic, retain) NSString *wordsFile;
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

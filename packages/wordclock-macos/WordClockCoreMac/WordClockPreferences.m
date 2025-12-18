//
//  WordClockPreferences.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#ifdef SCREENSAVER
#import <ScreenSaver/ScreenSaver.h>
#endif
#import "WordClockPreferences.h"

NSString *const WCWordsFileKey = @"wordsFile";
NSString *const WCFontNameKey = @"fontName";
NSString *const WCHighlightColourKey = @"highlightColour";
NSString *const WCForegroundColourKey = @"foregroundColour";
NSString *const WCBackgroundColourKey = @"backgroundColour";
NSString *const WCLeadingKey = @"leading";
NSString *const WCTrackingKey = @"tracking";
NSString *const WCJustificationKey = @"justification";
NSString *const WCCaseAdjustmentKey = @"caseAdjustment";
NSString *const WCStyleKey = @"style";

NSString *const WCLinearTranslateXKey = @"linearTranslateX";
NSString *const WCLinearTranslateYKey = @"linearTranslateY";
NSString *const WCLinearScaleKey = @"linearScale";

NSString *const WCRotaryTranslateXKey = @"rotaryTranslateX";
NSString *const WCRotaryTranslateYKey = @"rotaryTranslateY";
NSString *const WCRotaryScaleKey = @"rotaryScale";

NSString *const WCLinearMarginLeftKey = @"linearMarginLeft";
NSString *const WCLinearMarginRightKey = @"linearMarginRight";
NSString *const WCLinearMarginTopKey = @"linearMarginTop";
NSString *const WCLinearMarginBottomKey = @"linearMarginBottom";

NSString *const WCTransitionTimeKey = @"transitionTime";
NSString *const WCTransitionStyleKey = @"transitionStyle";

@implementation WordClockPreferences

@synthesize wordsFile = _wordsFile;
@synthesize fontName = _fontName;
@synthesize highlightColour = _highlightColour;
@synthesize foregroundColour = _foregroundColour;
@synthesize backgroundColour = _backgroundColour;
@synthesize leading = _leading;
@synthesize tracking = _tracking;
@synthesize justification = _justification;
@synthesize caseAdjustment = _caseAdjustment;
@synthesize style = _style;

@synthesize linearTranslateX = _linearTranslateX;
@synthesize linearTranslateY = _linearTranslateY;
@synthesize linearScale = _linearScale;

@synthesize rotaryTranslateX = _rotaryTranslateX;
@synthesize rotaryTranslateY = _rotaryTranslateY;
@synthesize rotaryScale = _rotaryScale;

@synthesize linearMarginLeft = _linearMarginLeft;
@synthesize linearMarginRight = _linearMarginRight;
@synthesize linearMarginTop = _linearMarginTop;
@synthesize linearMarginBottom = _linearMarginBottom;

@synthesize transitionTime = _transitionTime;
@synthesize transitionStyle = _transitionStyle;

// ____________________________________________________________________________________________________
// defaults

+ (void)initialize {
    [[WordClockPreferences defaults] registerDefaults:[self factoryDefaults]];
}

// Preferences are located in ~/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver/Data/Library/Preferences

+ (NSUserDefaults *)defaults {
#ifdef SCREENSAVER
    static NSUserDefaults *sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(macOS 10.15, *)) {
            DDLogVerbose(@"Using new defaults");
            sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.simonheys.wordclock"];
        } else {
            DDLogVerbose(@"Using old defaults");
            sharedDefaults = [ScreenSaverDefaults defaultsForModuleWithName:@"com.simonheys.wordclock"];
        }
    });
    return sharedDefaults;
#else
    return [NSUserDefaults standardUserDefaults];
#endif
}

+ (NSDictionary *)factoryDefaults {
    NSDictionary *factoryDefaults = @{WCWordsFileKey : @"English.json", WCFontNameKey : @"Helvetica-Bold", WCHighlightColourKey : [NSKeyedArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0]], WCForegroundColourKey : [NSKeyedArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.25f green:0.25f blue:0.25f alpha:1.0]], WCBackgroundColourKey : [NSKeyedArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0]], WCLeadingKey : @0.0f, WCTrackingKey : @0.0f, WCJustificationKey : @(WCJustificationLeft), WCStyleKey : @(WCStyleLinear), WCLinearTranslateXKey : @0.0f, WCLinearTranslateYKey : @0.0f, WCLinearScaleKey : @1.0f, WCRotaryTranslateXKey : @0.0f, WCRotaryTranslateYKey : @0.0f, WCRotaryScaleKey : @0.8f, WCLinearMarginLeftKey : @50.0f, WCLinearMarginRightKey : @50.0f, WCLinearMarginTopKey : @50.0f, WCLinearMarginBottomKey : @50.0f, WCTransitionTimeKey : @60, WCTransitionStyleKey : @(WCTransitionStyleSlow)};
    return factoryDefaults;
}

- (void)dealloc {
    [_backgroundColour release];
    [_foregroundColour release];
    [_highlightColour release];
    [_fontName release];
    [_wordsFile release];
    [super dealloc];
}

- (void)reset {
    self.wordsFile = @"English.json";
    self.fontName = @"Helvetica-Bold";
    self.highlightColour = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0];
    self.foregroundColour = [NSColor colorWithCalibratedRed:0.25f green:0.25f blue:0.25f alpha:1.0];
    self.backgroundColour = [NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0];
    self.leading = 0.0f;
    self.tracking = 0.0f;
    self.justification = WCJustificationLeft;
    self.style = WCStyleLinear;
    self.linearTranslateX = 0.0f;
    self.linearTranslateY = 0.0f;
    self.linearScale = 1.0f;
    self.rotaryTranslateX = 0.0f;
    self.rotaryTranslateY = 0.0f;
    self.rotaryScale = 0.8f;
    self.linearMarginLeft = 50.0f;
    self.linearMarginRight = 50.0f;
    self.linearMarginTop = 50.0f;
    self.linearMarginBottom = 50.0f;
    self.transitionTime = 60;
    self.transitionStyle = WCTransitionStyleSlow;
}

// ____________________________________________________________________________________________________
// xml file

- (void)setWordsFile:(NSString *)value {
    [[WordClockPreferences defaults] setObject:value forKey:WCWordsFileKey];
    [[WordClockPreferences defaults] synchronize];
}

- (NSString *)wordsFile {
    return [[WordClockPreferences defaults] stringForKey:WCWordsFileKey];
}

// ____________________________________________________________________________________________________
// font name

- (void)setFontName:(NSString *)value {
    if ([value isEqual:_fontName]) {
        return;
    }
    [[WordClockPreferences defaults] setObject:value forKey:WCFontNameKey];
    [[WordClockPreferences defaults] synchronize];
    [_fontName release];
    _fontName = [value retain];
}

- (NSString *)fontName {
    if (!_fontName) {
        _fontName = [[WordClockPreferences defaults] stringForKey:WCFontNameKey];
        [_fontName retain];
    }
    return _fontName;
}

- (void)setLeading:(float)value {
    if (_leading == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCLeadingKey];
    [[WordClockPreferences defaults] synchronize];
    _leading = value;
}

- (float)leading {
    if (!_leading) {
        _leading = [[WordClockPreferences defaults] floatForKey:WCLeadingKey];
    }
    return _leading;
}

- (void)setTracking:(float)value {
    if (_tracking == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCTrackingKey];
    [[WordClockPreferences defaults] synchronize];
    _tracking = value;
}

- (float)tracking {
    if (!_tracking) {
        _tracking = [[WordClockPreferences defaults] floatForKey:WCTrackingKey];
    }
    return _tracking;
}

- (void)setCaseAdjustment:(WCCaseAdjustment)value {
    if (_caseAdjustment == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCCaseAdjustmentKey];
    [[WordClockPreferences defaults] synchronize];
    _caseAdjustment = value;
}

- (WCCaseAdjustment)caseAdjustment {
    if (!_caseAdjustment) {
        _caseAdjustment = (WCCaseAdjustment)[[WordClockPreferences defaults] integerForKey:WCCaseAdjustmentKey];
    }
    return _caseAdjustment;
}

- (void)setJustification:(WCJustification)value {
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCJustificationKey];
    [[WordClockPreferences defaults] synchronize];
}

- (WCJustification)justification {
    return (WCJustification)[[WordClockPreferences defaults] integerForKey:WCJustificationKey];
}

- (void)setStyle:(WCStyle)value {
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCStyleKey];
    [[WordClockPreferences defaults] synchronize];
}

- (WCStyle)style {
    return (WCStyle)[[WordClockPreferences defaults] integerForKey:WCStyleKey];
}

// ____________________________________________________________________________________________________
// colour

- (void)setBackgroundColour:(NSColor *)colour {
    if ([colour isEqual:_backgroundColour]) {
        return;
    }
    NSData *theData;
    theData = [NSKeyedArchiver archivedDataWithRootObject:colour];
    [[WordClockPreferences defaults] setObject:theData forKey:WCBackgroundColourKey];
    [[WordClockPreferences defaults] synchronize];
    [_backgroundColour release];
    _backgroundColour = [colour retain];
}

- (void)setForegroundColour:(NSColor *)colour {
    if ([colour isEqual:_foregroundColour]) {
        return;
    }
    [colour retain];
    NSData *theData;
    theData = [NSKeyedArchiver archivedDataWithRootObject:colour];
    [[WordClockPreferences defaults] setObject:theData forKey:WCForegroundColourKey];
    [[WordClockPreferences defaults] synchronize];
    [_foregroundColour release];
    _foregroundColour = colour;
}

- (void)setHighlightColour:(NSColor *)colour {
    if ([colour isEqual:_highlightColour]) {
        return;
    }
    NSData *theData;
    theData = [NSKeyedArchiver archivedDataWithRootObject:colour];
    [[WordClockPreferences defaults] setObject:theData forKey:WCHighlightColourKey];
    [[WordClockPreferences defaults] synchronize];
    [_highlightColour release];
    _highlightColour = [colour retain];
}

- (NSColor *)backgroundColour {
    if (!_backgroundColour) {
        _backgroundColour = [NSKeyedUnarchiver unarchiveObjectWithData:[[WordClockPreferences defaults] objectForKey:WCBackgroundColourKey]];
        [_backgroundColour retain];
    }
    return _backgroundColour;
}

- (NSColor *)foregroundColour {
    if (!_foregroundColour) {
        _foregroundColour = [NSKeyedUnarchiver unarchiveObjectWithData:[[WordClockPreferences defaults] objectForKey:WCForegroundColourKey]];
        [_foregroundColour retain];
    }
    return _foregroundColour;
}

- (NSColor *)highlightColour {
    if (!_highlightColour) {
        _highlightColour = [NSKeyedUnarchiver unarchiveObjectWithData:[[WordClockPreferences defaults] objectForKey:WCHighlightColourKey]];
        [_highlightColour retain];
    }
    return _highlightColour;
}

// ____________________________________________________________________________________________________
// Translate & Scale

- (void)setLinearTranslateX:(float)value {
    if (_linearTranslateX == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCLinearTranslateXKey];
    [[WordClockPreferences defaults] synchronize];
    _linearTranslateX = value;
}

- (float)linearTranslateX {
    if (!_linearTranslateX) {
        _linearTranslateX = [[WordClockPreferences defaults] floatForKey:WCLinearTranslateXKey];
    }
    return _linearTranslateX;
}

- (void)setLinearTranslateY:(float)value {
    if (_linearTranslateY == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCLinearTranslateYKey];
    [[WordClockPreferences defaults] synchronize];
    _linearTranslateY = value;
}

- (float)linearTranslateY {
    if (!_linearTranslateY) {
        _linearTranslateY = [[WordClockPreferences defaults] floatForKey:WCLinearTranslateYKey];
    }
    return _linearTranslateY;
}

- (void)setLinearScale:(float)value {
    if (_linearScale == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCLinearScaleKey];
    [[WordClockPreferences defaults] synchronize];
    _linearScale = value;
}

- (float)linearScale {
    if (!_linearScale) {
        _linearScale = [[WordClockPreferences defaults] floatForKey:WCLinearScaleKey];
        if (_linearScale > kTouchableViewMaximumScale) {
            _linearScale = kTouchableViewMaximumScale;
        }
        if (_linearScale < kTouchableViewMinimumScale) {
            _linearScale = kTouchableViewMinimumScale;
        }
    }
    return _linearScale;
}

- (void)setRotaryTranslateX:(float)value {
    if (_rotaryTranslateX == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCRotaryTranslateXKey];
    [[WordClockPreferences defaults] synchronize];
    _rotaryTranslateX = value;
}

- (float)rotaryTranslateX {
    if (!_rotaryTranslateX) {
        _rotaryTranslateX = [[WordClockPreferences defaults] floatForKey:WCRotaryTranslateXKey];
    }
    return _rotaryTranslateX;
}

- (void)setRotaryTranslateY:(float)value {
    if (_rotaryTranslateY == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCRotaryTranslateYKey];
    [[WordClockPreferences defaults] synchronize];
    _rotaryTranslateY = value;
}

- (float)rotaryTranslateY {
    if (!_rotaryTranslateY) {
        _rotaryTranslateY = [[WordClockPreferences defaults] floatForKey:WCRotaryTranslateYKey];
    }
    return _rotaryTranslateY;
}

- (void)setRotaryScale:(float)value {
    if (_rotaryScale == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCRotaryScaleKey];
    [[WordClockPreferences defaults] synchronize];
    _rotaryScale = value;
}

- (float)rotaryScale {
    if (!_rotaryScale) {
        _rotaryScale = [[WordClockPreferences defaults] floatForKey:WCRotaryScaleKey];
        if (_rotaryScale > kTouchableViewMaximumScale) {
            _rotaryScale = kTouchableViewMaximumScale;
        }
        if (_rotaryScale < kTouchableViewMinimumScale) {
            _rotaryScale = kTouchableViewMinimumScale;
        }
    }
    return _rotaryScale;
}

// ____________________________________________________________________________________________________
// Margins

- (void)setLinearMarginLeft:(float)value {
    if (_linearMarginLeft == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCLinearMarginLeftKey];
    [[WordClockPreferences defaults] synchronize];
    _linearMarginLeft = value;
}

- (float)linearMarginLeft {
    if (!_linearMarginLeft) {
        _linearMarginLeft = [[WordClockPreferences defaults] floatForKey:WCLinearMarginLeftKey];
    }
    return _linearMarginLeft;
}

- (void)setLinearMarginRight:(float)value {
    if (_linearMarginRight == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCLinearMarginRightKey];
    [[WordClockPreferences defaults] synchronize];
    _linearMarginRight = value;
}

- (float)linearMarginRight {
    if (!_linearMarginRight) {
        _linearMarginRight = [[WordClockPreferences defaults] floatForKey:WCLinearMarginRightKey];
    }
    return _linearMarginRight;
}

- (void)setLinearMarginTop:(float)value {
    if (_linearMarginTop == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCLinearMarginTopKey];
    [[WordClockPreferences defaults] synchronize];
    _linearMarginTop = value;
}

- (float)linearMarginTop {
    if (!_linearMarginTop) {
        _linearMarginTop = [[WordClockPreferences defaults] floatForKey:WCLinearMarginTopKey];
    }
    return _linearMarginTop;
}

- (void)setLinearMarginBottom:(float)value {
    if (_linearMarginBottom == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCLinearMarginBottomKey];
    [[WordClockPreferences defaults] synchronize];
    _linearMarginBottom = value;
}

- (float)linearMarginBottom {
    if (!_linearMarginBottom) {
        _linearMarginBottom = [[WordClockPreferences defaults] floatForKey:WCLinearMarginBottomKey];
    }
    return _linearMarginBottom;
}

// ____________________________________________________________________________________________________
// transition time

- (void)setTransitionTime:(NSInteger)value {
    if (_transitionTime == value) {
        return;
    }
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCTransitionTimeKey];
    [[WordClockPreferences defaults] synchronize];
    _transitionTime = value;
}

- (NSInteger)transitionTime {
    if (!_transitionTime) {
        _transitionTime = [[WordClockPreferences defaults] integerForKey:WCTransitionTimeKey];
    }
    return _transitionTime;
}

// ____________________________________________________________________________________________________
// transition style

- (void)setTransitionStyle:(WCTransitionStyle)value {
    [[WordClockPreferences defaults] setObject:@(value) forKey:WCTransitionStyleKey];
    [[WordClockPreferences defaults] synchronize];
}

- (WCTransitionStyle)transitionStyle {
    return (WCTransitionStyle)[[WordClockPreferences defaults] integerForKey:WCTransitionStyleKey];
}

// ____________________________________________________________________________________________________
// Singleton

+ (WordClockPreferences *)sharedInstance {
    static dispatch_once_t once;
    static WordClockPreferences *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// ____________________________________________________________________________________________________
// Getters / Setters

@end

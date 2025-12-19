//
//  WordClockWord.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "Tween.h"
#import "WordClockPreferences.h"

#define kWordClockWordUnscaledFontSize 24.0f
#define kWordClockWordScaleMaximum 20.0f

@class TweenManager;

// #define kWordClockWordTextureWidthMaximum 512
// #define kWordClockWordTextureHeightMaximum 512

// 256 x 128 = 3833856
// 512 x 256 = 10223616 = more than 24Mb
// 512 x 512 = 10223616

@interface WordClockWord : NSObject {
   @private
    TweenManager *_tweenManager;
    NSString *_label;
    NSString *_originalLabel;
    BOOL _highlighted;
    NSColor *_foregroundColour;
    NSColor *_highlightColour;
    NSMutableArray *_labelCharacterStringArray;
    float _tracking;
    BOOL _isSpace;

    NSFont *_font;
    NSSize _unscaledSize;
    NSSize _size;
    NSSize _spaceSize;

    size_t _textureWidth;
    size_t _textureHeight;
    float _unscaledTextureWidth;
    float _unscaledTextureHeight;

    float *_colours;
    BOOL *_highlightedPointer;
    float _scale;

    float _colourComponentRed;
    float _colourComponentGreen;
    float _colourComponentBlue;
    float _colourComponentAlpha;

    float tweenValue;
}

- (instancetype)initWithLabel:(NSString *)label tweenManager:(TweenManager *)tweenManager;
- (void)setFontWithName:(NSString *)fontName tracking:(float)tracking caseAdjustment:(WCCaseAdjustment)caseAdjustment;
- (NSData *)bitmapDataForScale:(float)scale width:(size_t *)width height:(size_t *)height;
- (void)setColourPointer:(float *)colourPointer;
- (void)setHighlightedPointer:(BOOL *)highlightedPointer;
- (void)setHighlighted:(BOOL)value animated:(BOOL)animated;
- (void)setRGBA:(uint)rgba;

@property(readonly) NSString *label;
@property(readonly) NSString *originalLabel;
@property(nonatomic, retain) NSColor *foregroundColour;
@property(assign) NSColor *highlightColour;
@property(nonatomic) BOOL highlighted;

@property(readonly) size_t textureWidth;
@property(readonly) size_t textureHeight;
@property(readonly) float unscaledTextureWidth;
@property(readonly) float unscaledTextureHeight;
@property(readonly) BOOL isSpace;
@property(readonly) NSSize size;
@property(readonly) NSSize unscaledSize;
@property(readonly) NSSize spaceSize;
@property(nonatomic) float colourComponentRed;
@property(nonatomic) float colourComponentGreen;
@property(nonatomic) float colourComponentBlue;
@property(nonatomic) float colourComponentAlpha;

@property float tweenValue;

@end

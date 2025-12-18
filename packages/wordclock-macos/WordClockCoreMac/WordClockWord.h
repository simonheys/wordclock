//
//  WordClockWord.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <OpenGL/OpenGL.h>

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

    BOOL _isMipmapRendered;

    NSFont *_font;
    //	CGSize _baseFontSizeForCalculation;
    NSSize _unscaledSize;
    NSSize _size;
    NSSize _spaceSize;

    size_t _textureWidth;
    size_t _textureHeight;
    float _unscaledTextureWidth;
    float _unscaledTextureHeight;

    GLuint *_targetTexturePointer;
    GLfloat *_colours;
    BOOL *_highlightedPointer;
    float _scale;

    GLfloat _colourComponentRed;
    GLfloat _colourComponentGreen;
    GLfloat _colourComponentBlue;
    GLfloat _colourComponentAlpha;

    float tweenValue;
}

- (instancetype)initWithLabel:(NSString *)label tweenManager:(TweenManager *)tweenManager;
- (void)setFontWithName:(NSString *)fontName tracking:(float)tracking caseAdjustment:(WCCaseAdjustment)caseAdjustment;
- (void)renderToOpenGlTexture:(GLuint *)targetTexturePointer withScale:(float)scale;
- (void)setColourPointer:(GLfloat *)colourPointer;
- (void)setHighlightedPointer:(BOOL *)highlightedPointer;
- (void)setHighlighted:(BOOL)value animated:(BOOL)animated;
- (void)setRGBA:(uint)rgba;
//- (void)renderInCurrentGraphicsContentAtPoint:(NSPoint)point;
- (void)rerenderToOpenGlTexture:(GLuint *)targetTexturePointer withScale:(float)scale;

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
@property GLuint *targetTexturePointer;
@property(nonatomic) GLfloat colourComponentRed;
@property(nonatomic) GLfloat colourComponentGreen;
@property(nonatomic) GLfloat colourComponentBlue;
@property(nonatomic) GLfloat colourComponentAlpha;

@property float tweenValue;

@end

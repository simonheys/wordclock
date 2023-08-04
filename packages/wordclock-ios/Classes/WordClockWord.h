//
//  WordClockWord.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Tween.h"
#import "WordClockPreferences.h"

#define kWordClockWordUnscaledFontSize 24.0f
#define kWordClockWordScaleMaximum 20.0f
// #define kWordClockWordTextureWidthMaximum 512
// #define kWordClockWordTextureHeightMaximum 512

// 256 x 128 = 3833856
// 512 x 256 = 10223616 = more than 24Mb
// 512 x 512 = 10223616

@interface WordClockWord : NSObject {
   @private
    NSString *_label;
    NSString *_originalLabel;
    BOOL _highlighted;
    UIColor *_foregroundColour;
    UIColor *_highlightColour;
    NSMutableArray *_labelCharacterStringArray;
    float _tracking;
    BOOL _isSpace;

    BOOL _isMipmapRendered;

    UIFont *_font;
    //	CGSize _baseFontSizeForCalculation;
    CGSize _unscaledSize;
    CGSize _size;
    CGSize _spaceSize;

    size_t _textureWidth;
    size_t _textureHeight;
    size_t _texturePixelsMaximum;
    float _unscaledTextureWidth;
    float _unscaledTextureHeight;

    GLuint *_targetTexturePointer;
    GLfloat *_colours;
    BOOL *_highlightedPointer;
    float _scale;

    float _colourComponentRed;
    float _colourComponentGreen;
    float _colourComponentBlue;
    float _colourComponentAlpha;
}

- (id)initWithLabel:(NSString *)label;
- (void)setFontWithName:(NSString *)fontName tracking:(float)tracking caseAdjustment:(WCCaseAdjustment)caseAdjustment;
- (void)renderToOpenGlTexture:(GLuint *)targetTexturePointer withScale:(float)scale;
- (void)renderInCurrentGraphicsContentAtPoint:(CGPoint)point;
- (void)setColourPointer:(GLfloat *)colourPointer;
- (void)setHighlightedPointer:(BOOL *)highlightedPointer;
- (void)setRGBA:(uint)rgba;
- (void)renderInCurrentGraphicsContentAtPoint:(CGPoint)point;
- (void)rerenderToOpenGlTexture:(GLuint *)targetTexturePointer withScale:(float)scale;

@property(readonly) NSString *label;
@property(nonatomic, retain) UIColor *foregroundColour;
@property(assign) UIColor *highlightColour;
@property BOOL highlighted;

@property(readonly) size_t textureWidth;
@property(readonly) size_t textureHeight;
@property size_t texturePixelsMaximum;
@property(readonly) float unscaledTextureWidth;
@property(readonly) float unscaledTextureHeight;
@property(readonly) BOOL isSpace;
@property(readonly) CGSize size;
@property(readonly) CGSize unscaledSize;
@property(readonly) CGSize spaceSize;
@property GLuint *targetTexturePointer;
@property float colourComponentRed;
@property float colourComponentGreen;
@property float colourComponentBlue;
@property float colourComponentAlpha;

@property float tweenValue;

@end

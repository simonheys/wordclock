//
//  WordClockWord.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockWord.h"

#include <stdint.h>

#import "TweenManager.h"

@interface WordClockWord ()
@property(nonatomic, retain) TweenManager *tweenManager;
@end

@implementation WordClockWord

// ____________________________________________________________________________________________________
// dealloc

@synthesize tweenValue;

- (void)dealloc {
    [self.tweenManager removeTweensWithTarget:self];
    [_tweenManager release];
    @try {
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCForegroundColourKey];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCHighlightColourKey];
    } @catch (NSException *exception) {
    }

    if (_font) {
        [_font release];
    }
    [_labelCharacterStringArray release];
    [_label release];
    [_originalLabel release];
    [super dealloc];
}

- (instancetype)initWithLabel:(NSString *)label tweenManager:(TweenManager *)tweenManager {
    self = [super init];
    if (self) {
        self.tweenManager = tweenManager;
        if ([label length] < 1) {
            _isSpace = YES;
        } else {
            _originalLabel = [label retain];
            _label = [_originalLabel retain];
        }
        self.highlighted = NO;
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCForegroundColourKey options:NSKeyValueObservingOptionNew context:NULL];
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCHighlightColourKey options:NSKeyValueObservingOptionNew context:NULL];
    }

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:WCForegroundColourKey]) {
        [self updateColour];
    } else if ([keyPath isEqual:WCHighlightColourKey]) {
        [self updateColour];
    }
}

// ____________________________________________________________________________________________________
// typography

// set all these at once
// calculate the unscaled size based on these
- (void)setFontWithName:(NSString *)fontName tracking:(float)tracking caseAdjustment:(WCCaseAdjustment)caseAdjustment {
    if (_isSpace) {
        return;
    }

    if (_font) {
        [_font release];
    }

    _font = [[NSFont fontWithName:fontName size:kWordClockWordUnscaledFontSize] retain];
    if (nil == _font) {
        _font = [[NSFont fontWithName:@"Helvetica-Bold" size:kWordClockWordUnscaledFontSize] retain];
    }

    _tracking = tracking;

    if (_label) {
        [_label release];
    }

    if (_labelCharacterStringArray) {
        [_labelCharacterStringArray release];
    }

    // create the character array
    // we need this for tracking
    switch (caseAdjustment) {
        case WCCaseAdjustmentNone:
            _label = [_originalLabel retain];
            break;
        case WCCaseAdjustmentUpper:
            _label = [_originalLabel uppercaseString];
            [_label retain];
            break;
        case WCCaseAdjustmentLower:
            _label = [_originalLabel lowercaseString];
            [_label retain];
            break;
    }

    _labelCharacterStringArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_label length]; i++) {
        [_labelCharacterStringArray addObject:[_label substringWithRange:NSMakeRange(i, 1)]];
    }

    NSSize result;

    // this will set the correct height
    NSDictionary *fontAttributes = @{NSFontAttributeName : _font};
    result = [_originalLabel sizeWithAttributes:fontAttributes];

    result.width = 0;

    NSString *c;

    for (c in _labelCharacterStringArray) {
        result.width += ([c sizeWithAttributes:fontAttributes]).width;
    }

    // add the result fo tracking inbetween letters
    result.width += _tracking * kWordClockWordUnscaledFontSize * ([_label length] - 1);

    _unscaledSize = result;
    _size = result;
}

// ____________________________________________________________________________________________________
// highlighting

- (void)setHighlightedPointer:(BOOL *)highlightedPointer {
    _highlightedPointer = highlightedPointer;
    if (_highlightedPointer) {
        _highlightedPointer[0] = _highlighted;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:YES];
}

- (void)setHighlighted:(BOOL)value animated:(BOOL)animated {
    if (_isSpace) {
        return;
    }

    if (value != _highlighted || !animated) {
        _highlighted = value;
        if (_highlightedPointer) {
            _highlightedPointer[0] = _highlighted;
        }
        if (_highlighted) {
            if (animated) {
                NSColor *color = [[WordClockPreferences sharedInstance] highlightColour];
                CGFloat red, green, blue, alpha;
                NSColor *normalizedColor = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
                if (!normalizedColor) {
                    normalizedColor = color;
                }
                [normalizedColor getRed:&red green:&green blue:&blue alpha:&alpha];

                [self.tweenManager tweenWithTarget:self keyPath:@"colourComponentRed" toFloatValue:red delay:0.0f duration:0.15f ease:kTweenQuadEaseIn];
                [self.tweenManager tweenWithTarget:self keyPath:@"colourComponentGreen" toFloatValue:green delay:0.0f duration:0.15f ease:kTweenQuadEaseIn];
                [self.tweenManager tweenWithTarget:self keyPath:@"colourComponentBlue" toFloatValue:blue delay:0.0f duration:0.15f ease:kTweenQuadEaseIn];
                [self.tweenManager tweenWithTarget:self keyPath:@"colourComponentAlpha" toFloatValue:alpha delay:0.0f duration:0.15f ease:kTweenQuadEaseOut];
            } else {
                [self updateColour];
            }
        } else {
            if (animated) {
                NSColor *color = [[WordClockPreferences sharedInstance] foregroundColour];
                CGFloat red, green, blue, alpha;
                NSColor *normalizedColor = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
                if (!normalizedColor) {
                    normalizedColor = color;
                }
                [normalizedColor getRed:&red green:&green blue:&blue alpha:&alpha];

                [self.tweenManager tweenWithTarget:self keyPath:@"colourComponentRed" toFloatValue:red delay:0.0f duration:0.15f ease:kTweenQuadEaseOut];
                [self.tweenManager tweenWithTarget:self keyPath:@"colourComponentGreen" toFloatValue:green delay:0.0f duration:0.15f ease:kTweenQuadEaseOut];
                [self.tweenManager tweenWithTarget:self keyPath:@"colourComponentBlue" toFloatValue:blue delay:0.0f duration:0.15f ease:kTweenQuadEaseOut];
                [self.tweenManager tweenWithTarget:self keyPath:@"colourComponentAlpha" toFloatValue:alpha delay:0.0f duration:0.15f ease:kTweenQuadEaseOut];
            } else {
                [self updateColour];
            }
        }
    }
}

// ____________________________________________________________________________________________________
// gl texture

- (NSData *)bitmapDataForScale:(float)scale width:(size_t *)width height:(size_t *)height {
    size_t texWidth, texHeight;
    CGContextRef spriteContext;
    uint8_t *spriteData;

    if (_isSpace) {
        return nil;
    }

    _scale = ceilf(scale);
    if (_scale > kWordClockWordScaleMaximum) {
        _scale = kWordClockWordScaleMaximum;
    }

    _size = NSSizeFromCGSize(CGSizeMake(_scale * _unscaledSize.width, _scale * _unscaledSize.height));
    if (_tracking > 0) {
        _spaceSize.width = _tracking * kWordClockWordUnscaledFontSize * 5;
    } else {
        _spaceSize.width = kWordClockWordUnscaledFontSize * 0.25;
    }
    _spaceSize.height = _unscaledSize.height;

    NSRect fontBounds = [_font boundingRectForFont];

    texWidth = _size.width - fontBounds.origin.x * _scale;
    texHeight = _size.height;

    while (texWidth > 1024 || texHeight > 1024) {
        texWidth /= 2;
        texHeight /= 2;
        _size.width /= 2;
        _size.height /= 2;
        _scale /= 2;
    }

    if (texWidth <= 1 || texHeight <= 1) {
        return nil;
    }

    _textureWidth = texWidth;
    _textureHeight = texHeight;
    _unscaledTextureWidth = (float)texWidth / _scale;
    _unscaledTextureHeight = (float)texHeight / _scale;

    spriteData = (uint8_t *)malloc(texWidth * texHeight * 4);
    if (!spriteData) {
        return nil;
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(CFSTR("kCGColorSpaceUserRGB"));
    spriteContext = CGBitmapContextCreate(spriteData, texWidth, texHeight, 8, texWidth * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);

    if (NULL == spriteContext) {
        free(spriteData);
        return nil;
    }

    NSGraphicsContext *gc = [NSGraphicsContext graphicsContextWithCGContext:spriteContext flipped:YES];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:gc];

    CGContextClearRect(spriteContext, CGRectMake(0, 0, texWidth, texHeight));

    CGContextSaveGState(spriteContext);
    CGContextScaleCTM(spriteContext, _scale, _scale);

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle new] autorelease];
    [style setAlignment:NSTextAlignmentCenter];
    (void)style;

    NSDictionary *fontAttributesNew = @{NSFontAttributeName : _font, NSForegroundColorAttributeName : [NSColor whiteColor]};

    [_originalLabel drawWithRect:NSMakeRect(-fontBounds.origin.x, 0, 100000, texHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributesNew];

    CGContextRestoreGState(spriteContext);
    [NSGraphicsContext restoreGraphicsState];

    CGContextRelease(spriteContext);

    if (width) {
        *width = texWidth;
    }
    if (height) {
        *height = texHeight;
    }

    return [NSData dataWithBytesNoCopy:spriteData length:texWidth * texHeight * 4 freeWhenDone:YES];
}

// ____________________________________________________________________________________________________
// colour

- (void)setColourPointer:(float *)colourPointer {
    _colours = colourPointer;
    [self updateColour];
}

- (void)updateColour {
    if (_colours == 0) {
        return;
    }
    // TODO should set these properly here
    NSColor *color;
    if (_highlighted) {
        color = [WordClockPreferences sharedInstance].highlightColour;
    } else {
        color = [WordClockPreferences sharedInstance].foregroundColour;
    }
    CGFloat red, green, blue, alpha;
    NSColor *normalizedColor = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    if (!normalizedColor) {
        normalizedColor = color;
    }
    [normalizedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    /*
    const CGFloat *components = CGColorGetComponents(color);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    */

    self.colourComponentRed = red;
    self.colourComponentGreen = green;
    self.colourComponentBlue = blue;
    self.colourComponentAlpha = alpha;
}

- (void)setColourComponentRed:(float)value {
    if (_colours) {
        _colours[0] = value;
        _colours[4] = value;
        _colours[8] = value;
        _colours[12] = value;
    }
    _colourComponentRed = value;
}

- (void)setColourComponentGreen:(float)value {
    if (_colours) {
        _colours[1] = value;
        _colours[5] = value;
        _colours[9] = value;
        _colours[13] = value;
    }
    _colourComponentGreen = value;
}

- (void)setColourComponentBlue:(float)value {
    if (_colours) {
        _colours[2] = value;
        _colours[6] = value;
        _colours[10] = value;
        _colours[14] = value;
    }
    _colourComponentBlue = value;
}

- (void)setColourComponentAlpha:(float)value {
    if (_colours) {
        _colours[3] = value;
        _colours[7] = value;
        _colours[11] = value;
        _colours[15] = value;
    }
    _colourComponentAlpha = value;
}

- (void)setRGBA:(uint)rgba {
    if (!_colours) {
        return;
    }
    uint rInt = (rgba & 0xff000000) >> 24;
    uint gInt = (rgba & 0xff0000) >> 16;
    uint bInt = (rgba & 0xff00) >> 8;
    uint aInt = (rgba & 0xff);

    float r = (float)rInt / 255;
    float g = (float)gInt / 255;
    float b = (float)bInt / 255;
    float a = (float)aInt / 255;

    uint offset = 0;
    _colours[offset++] = r;
    _colours[offset++] = g;
    _colours[offset++] = b;
    _colours[offset++] = a;
    _colours[offset++] = r;
    _colours[offset++] = g;
    _colours[offset++] = b;
    _colours[offset++] = a;
    _colours[offset++] = r;
    _colours[offset++] = g;
    _colours[offset++] = b;
    _colours[offset++] = a;
    _colours[offset++] = r;
    _colours[offset++] = g;
    _colours[offset++] = b;
    _colours[offset] = a;
}

// ____________________________________________________________________________________________________
// accessors

@synthesize tweenManager = _tweenManager;
@synthesize label = _label;
@synthesize originalLabel = _originalLabel;
@synthesize foregroundColour = _foregroundColour;
@synthesize highlightColour = _highlightColour;
@synthesize highlighted = _highlighted;
@synthesize textureWidth = _textureWidth;
@synthesize textureHeight = _textureHeight;
@synthesize unscaledTextureWidth = _unscaledTextureWidth;
@synthesize unscaledTextureHeight = _unscaledTextureHeight;
@synthesize isSpace = _isSpace;
@synthesize size = _size;
@synthesize unscaledSize = _unscaledSize;
@synthesize spaceSize = _spaceSize;
@synthesize colourComponentRed = _colourComponentRed;
@synthesize colourComponentGreen = _colourComponentGreen;
@synthesize colourComponentBlue = _colourComponentBlue;
@synthesize colourComponentAlpha = _colourComponentAlpha;

@end

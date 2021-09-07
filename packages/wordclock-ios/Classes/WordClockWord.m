//
//  WordClockWord.m
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockWord.h"

static inline size_t nextHighestPowerOfTwo(float value) {
    return 1 << (uint)ceilf(log2f(value));
}

@interface WordClockWord (WordClockWordPrivate)
- (void)renderToOpenGlTexture;
@end

@implementation WordClockWord

- (id)initWithLabel:(NSString *)label {
    if (self = [super init]) {
        //		DLog(@"initWithLabel:%@ length:%d",label,[label length]);
        if ([label length] < 1) {
            _isSpace = YES;
        } else {
            _originalLabel = [label retain];
            _label = [_originalLabel retain];
        }
        self.highlighted = NO;
        self.texturePixelsMaximum = 256 * 128;
    }

    return self;
}

// ____________________________________________________________________________________________________ typography

// set all these at once
// calculate the unscaled size based on these
- (void)setFontWithName:(NSString *)fontName tracking:(float)tracking caseAdjustment:(WCCaseAdjustment)caseAdjustment {
    NSLog(@"setFontWithName:%@ tracking:%@", fontName, @(tracking));
    if (_isSpace) {
        return;
    }

    if (_font) {
        [_font release];
    }

    _font = [[UIFont fontWithName:fontName size:kWordClockWordUnscaledFontSize] retain];

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

    CGSize result;

    // this will set the correct height
    result = [_originalLabel sizeWithFont:_font];

    result.width = 0;

    NSString *c;

    for (c in _labelCharacterStringArray) {
        result.width += ([c sizeWithFont:_font]).width;
    }

    // add the result fo tracking inbetween letters
    result.width += _tracking * kWordClockWordUnscaledFontSize * ([_label length] - 1);

    _unscaledSize = result;
    _size = result;
}

// ____________________________________________________________________________________________________ highlighting

- (void)setHighlightedPointer:(BOOL *)highlightedPointer {
    _highlightedPointer = highlightedPointer;
    _highlightedPointer[0] = _highlighted;
}

- (void)setHighlighted:(BOOL)value {
    if (_isSpace) {
        return;
    }

    // return;

    if (value != _highlighted) {
        _highlighted = value;
        _highlightedPointer[0] = _highlighted;
        if (_highlighted) {
            CGColorRef color = [[WordClockPreferences sharedInstance] highlightColour].CGColor;
            const CGFloat *components = CGColorGetComponents(color);
            CGFloat red = components[0];
            CGFloat green = components[1];
            CGFloat blue = components[2];

            // TODO implement using dictionaryWithValuesForKeys:
            [Tween tweenWithTarget:self keyPath:@"colourComponentRed" toFloatValue:red delay:0.0f duration:0.15f ease:kTweenQuadEaseIn];
            [Tween tweenWithTarget:self keyPath:@"colourComponentGreen" toFloatValue:green delay:0.0f duration:0.15f ease:kTweenQuadEaseIn];
            [Tween tweenWithTarget:self keyPath:@"colourComponentBlue" toFloatValue:blue delay:0.0f duration:0.15f ease:kTweenQuadEaseIn];

        } else {
            CGColorRef color = [[WordClockPreferences sharedInstance] foregroundColour].CGColor;
            const CGFloat *components = CGColorGetComponents(color);
            CGFloat red = components[0];
            CGFloat green = components[1];
            CGFloat blue = components[2];

            [Tween tweenWithTarget:self keyPath:@"colourComponentRed" toFloatValue:red delay:0.0f duration:0.15f ease:kTweenQuadEaseOut];
            [Tween tweenWithTarget:self keyPath:@"colourComponentGreen" toFloatValue:green delay:0.0f duration:0.15f ease:kTweenQuadEaseOut];
            [Tween tweenWithTarget:self keyPath:@"colourComponentBlue" toFloatValue:blue delay:0.0f duration:0.15f ease:kTweenQuadEaseOut];
        }
    }
}

// ____________________________________________________________________________________________________ preview

// this shoudl be exactly the same as the routine below
- (void)renderInCurrentGraphicsContentAtPoint:(CGPoint)point {
    NSString *c;
    float t = _tracking * kWordClockWordUnscaledFontSize;

    for (c in _labelCharacterStringArray) {
        [c drawAtPoint:point withFont:_font];
        point.x += [c sizeWithFont:_font].width;
        point.x += t;
    }
}

// ____________________________________________________________________________________________________ gl texture

- (void)renderToOpenGlTexture:(GLuint *)targetTexturePointer withScale:(float)scale {
    _targetTexturePointer = targetTexturePointer;
    _scale = ceilf(scale);
    //_scale = scale;
    if (_scale > kWordClockWordScaleMaximum) {
        _scale = kWordClockWordScaleMaximum;
    }

    _size = CGSizeMake(_scale * _unscaledSize.width, _scale * _unscaledSize.height);
    if (_tracking > 0) {
        _spaceSize.width = _tracking * kWordClockWordUnscaledFontSize * 5;
    } else {
        _spaceSize.width = kWordClockWordUnscaledFontSize * 0.25;
    }

    _spaceSize.height = _unscaledSize.height;

    [self renderToOpenGlTexture];
}

- (void)rerenderToOpenGlTexture:(GLuint *)targetTexturePointer withScale:(float)scale {
    float newScale;
    newScale = ceilf(scale);
    // newScale = scale;
    if (newScale > kWordClockWordScaleMaximum) {
        newScale = kWordClockWordScaleMaximum;
    }
    //	DLog(@"newScale:%f _scale:%f",newScale,_scale);
    if (_scale == newScale) {
        return;
    }

    glDeleteTextures(1, targetTexturePointer);

    [self renderToOpenGlTexture:targetTexturePointer withScale:newScale];
}

- (void)renderToOpenGlTexture {
    size_t width, height;
    CGContextRef spriteContext;
    GLubyte *spriteData;
    void *tempData;
    unsigned int *inPixel32;
    unsigned short *outPixel16;
    NSUInteger i;

    if (_isSpace) {
        return;
    }

    width = nextHighestPowerOfTwo(_size.width);
    height = nextHighestPowerOfTwo(_size.height);

    while (width * height > _texturePixelsMaximum || (width > 512 || height > 512)) {
        width /= 2;
        height /= 2;
        _size.width /= 2;
        _size.height /= 2;
        _scale /= 2;
    }

    if (width <= 1 || height <= 1) {
        return;
    }

    DLog(@"Rendering with dimensions %dx%d scale:%f word:%@ length:%d", width, height, _scale, _label, [_label length]);

    _textureWidth = width;
    _textureHeight = height;
    _unscaledTextureWidth = (float)width / _scale;
    _unscaledTextureHeight = (float)height / _scale;

    // int nLevels = 3;
    int mipmapLevel = 0;

    // Use OpenGL ES to generate a name for the texture.
    glGenTextures(1, _targetTexturePointer);

    glBindTexture(GL_TEXTURE_2D, *_targetTexturePointer);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

#ifdef ENABLE_MIPMAPPING
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);

#else
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
#endif

    // Allocated memory needed for the bitmap context
    spriteData = (GLubyte *)malloc(width * height * 4);
    // Uses the bitmatp creation function provided by the Core Graphics framework.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    // After you create the context, you can draw the sprite image to the context.
    // CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);

    CGColorSpaceRelease(colorSpace);
    // need to clear the spriteCOntetx and fill with alpha

    CGContextClearRect(spriteContext, CGRectMake(0, 0, width, height));

    /*
    CGContextSetRGBStrokeColor(spriteContext, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextStrokeRect(spriteContext, CGRectMake(0, 0, width, height));
    CGContextMoveToPoint(spriteContext, 0, 0);
    CGContextAddLineToPoint(spriteContext, width, height);
    CGContextStrokePath(spriteContext);
    CGContextMoveToPoint(spriteContext, width, 0);
    CGContextAddLineToPoint(spriteContext, 0, height);
    CGContextStrokePath(spriteContext);
    */
    UIGraphicsPushContext(spriteContext);

    // scale up the unscaled font accordingly
    CGContextSaveGState(spriteContext);
    CGContextScaleCTM(spriteContext, _scale, _scale);

    // fill with white so we can use open gl to change the colour
    [[UIColor whiteColor] set];

    //		[c setStr
    //[c drawRect:CGrectMake(0,0,width,height)];

    CGPoint point = CGPointZero;
    NSString *c;
    float t = _tracking * kWordClockWordUnscaledFontSize;

    for (c in _labelCharacterStringArray) {
        //	[[NSString stringWithFormat:@"%d",mipmapLevel] drawAtPoint:point withFont:_font];
        [c drawAtPoint:point withFont:_font];
        point.x += [c sizeWithFont:_font].width;
        point.x += t;
    }

    CGContextRestoreGState(spriteContext);

    UIGraphicsPopContext();

#ifdef ENABLE_16_BIT_TEXTURES
    // Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
    tempData = malloc(height * width * 2);
    inPixel32 = (unsigned int *)spriteData;
    outPixel16 = (unsigned short *)tempData;
    for (i = 0; i < width * height; ++i, ++inPixel32)
        *outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) |  // R
                        ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) |   // G
                        ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) |  // B
                        ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);   // A

    free(spriteData);
    spriteData = tempData;

#endif
    // You don't need the context at this point, so you need to release it to avoid memory leaks.
    CGContextRelease(spriteContext);

#ifdef ENABLE_16_BIT_TEXTURES
    glTexImage2D(GL_TEXTURE_2D, mipmapLevel, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, spriteData);
#else
    glTexImage2D(GL_TEXTURE_2D, mipmapLevel, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
#endif

    // Release the image data
    free(spriteData);

#ifdef ENABLE_MIPMAPPING
    glGenerateMipmapOES(GL_TEXTURE_2D);
#endif
}

// ____________________________________________________________________________________________________ colour

- (void)setColourPointer:(GLfloat *)colourPointer {
    //	DLog(@"setColourPointer");
    _colours = colourPointer;
    // TODO should set these properly here
    CGColorRef color;
    if (_highlighted) {
        color = [[WordClockPreferences sharedInstance] highlightColour].CGColor;
    } else {
        color = [[WordClockPreferences sharedInstance] foregroundColour].CGColor;
    }
    const CGFloat *components = CGColorGetComponents(color);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    self.colourComponentRed = red;
    self.colourComponentGreen = green;
    self.colourComponentBlue = blue;
    self.colourComponentAlpha = 1.0f;
}

- (void)setColourComponentRed:(float)value {
    _colours[0] = value;
    _colours[4] = value;
    _colours[8] = value;
    _colours[12] = value;
    _colourComponentRed = value;
}

- (void)setColourComponentGreen:(float)value {
    _colours[1] = value;
    _colours[5] = value;
    _colours[9] = value;
    _colours[13] = value;
    _colourComponentGreen = value;
}

- (void)setColourComponentBlue:(float)value {
    _colours[2] = value;
    _colours[6] = value;
    _colours[10] = value;
    _colours[14] = value;
    _colourComponentBlue = value;
}

- (void)setColourComponentAlpha:(float)value {
    _colours[3] = value;
    _colours[7] = value;
    _colours[11] = value;
    _colours[15] = value;
    _colourComponentAlpha = value;
}

- (void)setRGBA:(uint)rgba {
    uint r_int = (rgba & 0xff000000) >> 24;
    uint g_int = (rgba & 0xff0000) >> 16;
    uint b_int = (rgba & 0xff00) >> 8;
    uint a_int = (rgba & 0xff);

    float r = (float)r_int / 255;
    float g = (float)g_int / 255;
    float b = (float)b_int / 255;
    float a = (float)a_int / 255;

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

// ____________________________________________________________________________________________________ dealloc

- (void)dealloc {
    //	DLog(@"dealloc");
    [[TweenManager sharedInstance] removeTweensWithTarget:self];
    if (_font) {
        [_font release];
    }
    [_labelCharacterStringArray release];
    [_label release];
    [_originalLabel release];
    [super dealloc];
}

// ____________________________________________________________________________________________________ accessors

@synthesize label = _label;
@synthesize foregroundColour = _foregroundColour;
@synthesize highlightColour = _highlightColour;
@synthesize highlighted = _highlighted;
@synthesize textureWidth = _textureWidth;
@synthesize textureHeight = _textureHeight;
@synthesize texturePixelsMaximum = _texturePixelsMaximum;
@synthesize unscaledTextureWidth = _unscaledTextureWidth;
@synthesize unscaledTextureHeight = _unscaledTextureHeight;
@synthesize isSpace = _isSpace;
@synthesize size = _size;
@synthesize unscaledSize = _unscaledSize;
@synthesize spaceSize = _spaceSize;
@synthesize targetTexturePointer = _targetTexturePointer;
@synthesize colourComponentRed = _colourComponentRed;
@synthesize colourComponentGreen = _colourComponentGreen;
@synthesize colourComponentBlue = _colourComponentBlue;
@synthesize colourComponentAlpha = _colourComponentAlpha;

@end

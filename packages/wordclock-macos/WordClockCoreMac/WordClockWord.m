//
//  WordClockWord.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockWord.h"

#import <OpenGL/gl.h>

#import "TweenManager.h"

static inline GLsizei nextHighestPowerOfTwo(float value) {
    return 1 << (uint)ceilf(log2f(value));
}

@interface WordClockWord ()
@property(nonatomic, retain) TweenManager *tweenManager;
@end

@implementation WordClockWord

// ____________________________________________________________________________________________________
// dealloc

@synthesize tweenValue;

- (void)dealloc {
    //	DDLogVerbose(@"dealloc");
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
        //		DDLogVerbose(@"initWithLabel:%@ length:%d",label,[label
        // length]);
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

    // NSKernAttributeName

    NSSize result;

    // this will set the correct height
    NSDictionary *fontAttributes = @{NSFontAttributeName : _font};
    result = [_originalLabel sizeWithAttributes:fontAttributes];
    //	result = [_originalLabel sizeWithFont:_font];

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
    _highlightedPointer[0] = _highlighted;
}

- (void)setHighlighted:(BOOL)highlighted {
    [self setHighlighted:highlighted animated:YES];
}

- (void)setHighlighted:(BOOL)value animated:(BOOL)animated {
    if (_isSpace) {
        return;
    }

    // return;

    if (value != _highlighted || !animated) {
        _highlighted = value;
        _highlightedPointer[0] = _highlighted;
        if (_highlighted) {
            if (animated) {
                NSColor *color = [[WordClockPreferences sharedInstance] highlightColour];
                CGFloat red, green, blue, alpha;
                NSColor *normalizedColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
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
                NSColor *normalizedColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
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
// preview

// this shoudl be exactly the same as the routine below
/*
- (void)renderInCurrentGraphicsContentAtPoint:(NSPoint)point
{
    NSString *c;
    float t = _tracking * kWordClockWordUnscaledFontSize;
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObject:_font
forKey:NSFontAttributeName];

    for ( c in _labelCharacterStringArray ) {
//		[c drawAtPoint:point withFont:_font];
//		point.x += [c sizeWithFont:_font].width;
        [c drawAtPoint:point withAttributes:fontAttributes];
        point.x += [c sizeWithAttributes:fontAttributes].width;
        point.x += t;
    }
}
*/

// ____________________________________________________________________________________________________
// gl texture

- (void)renderToOpenGlTexture:(GLuint *)targetTexturePointer withScale:(float)scale {
    _targetTexturePointer = targetTexturePointer;
    _scale = ceilf(scale);
    //_scale = scale;
    if (_scale > kWordClockWordScaleMaximum) {
        _scale = kWordClockWordScaleMaximum;
    }

    //	_size = NSSizeFromCGSize(CGSizeMake(_scale *
    //(_unscaledSize.width-fontBounds.origin.x), _scale *
    //_unscaledSize.height));
    _size = NSSizeFromCGSize(CGSizeMake(_scale * _unscaledSize.width, _scale * _unscaledSize.height));
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
    //	DDLogVerbose(@"newScale:%f _scale:%f",newScale,_scale);
    if (_scale == newScale) {
        return;
    }

    glDeleteTextures(1, targetTexturePointer);

    [self renderToOpenGlTexture:targetTexturePointer withScale:newScale];
}

- (void)renderToOpenGlTexture {
    GLsizei width, height;
    CGContextRef spriteContext;
    GLubyte *spriteData;

    if (_isSpace) {
        return;
    }

    NSRect fontBounds = [_font boundingRectForFont];

    width = nextHighestPowerOfTwo(_size.width - fontBounds.origin.x * _scale);
    height = nextHighestPowerOfTwo(_size.height);

    width = _size.width - fontBounds.origin.x * _scale;
    height = _size.height;

    //	while ( width*height > _texturePixelsMaximum || ( width > 1024 || height
    //> 1024 ) ) {
    while (width > 1024 || height > 1024) {
        width /= 2;
        height /= 2;
        _size.width /= 2;
        _size.height /= 2;
        _scale /= 2;
    }

    if (width <= 1 || height <= 1) {
        return;
    }

    //	DDLogVerbose(@"Rendering with dimensions %dx%d scale:%f word:%@
    // length:%d",width,height,_scale,_label,[_label length]);

    _textureWidth = width;
    _textureHeight = height;
    _unscaledTextureWidth = (float)width / _scale;
    _unscaledTextureHeight = (float)height / _scale;

    // int nLevels = 3;
    int mipmapLevel = 0;

    // Use OpenGL ES to generate a name for the texture.
    glGenTextures(1, _targetTexturePointer);

    glBindTexture(GL_TEXTURE_2D, *_targetTexturePointer);
    // Set a CACHED or SHARED storage hint for requesting VRAM or AGP texturing
    // respectively GL_STORAGE_PRIVATE_APPLE is the default and specifies normal
    // texturing path glTexParameteri(GL_TEXTURE_2D,
    // GL_TEXTURE_STORAGE_HINT_APPLE , GL_STORAGE_CACHED_APPLE);

    // Eliminate a data copy by the OpenGL framework using the Apple client
    // storage extension glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

#ifdef ENABLE_MIPMAPPING
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
// GL_LINEAR_MIPMAP_NEAREST);
#else
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
#endif

    //	DDLogVerbose(@"width:%d height:%d text:%@",width,height,_originalLabel);

    // Allocated memory needed for the bitmap context
    spriteData = (GLubyte *)malloc(width * height * 4);
    // Uses the bitmatp creation function provided by the Core Graphics
    // framework.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(CFSTR("kCGColorSpaceUserRGB"));
    spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);

    // After you create the context, you can draw the sprite image to the
    // context. CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0,
    // (CGFloat)width, (CGFloat)height), spriteImage);

    if (NULL == spriteContext) {
        DDLogVerbose(@"couln't create spriteContext");
    }
    /*
        CGContextClearRect(spriteContext, CGRectMake(0, 0, width, height));
        CGContextSetRGBStrokeColor(spriteContext, 1.0f, 1.0f, 1.0f, 1.0f);
        CGContextFillRect(spriteContext, CGRectMake(10,10,20,20));
        NSRect trim = [self usedRectForSpriteData:spriteData width:width
       heignt:height]; DDLogVerbose(@"width:%d height:%d
       trim:%@",width,height,NSStringFromRect(trim));
        */
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
    //	UIGraphicsPushContext(spriteContext);

    NSGraphicsContext *gc = [NSGraphicsContext graphicsContextWithGraphicsPort:spriteContext flipped:YES];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:gc];

    // need to clear the spriteCOntetx and fill with alpha
    CGContextClearRect(spriteContext, CGRectMake(0, 0, width, height));

    // scale up the unscaled font accordingly
    CGContextSaveGState(spriteContext);
    CGContextScaleCTM(spriteContext, _scale, _scale);

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle new] autorelease];
    [style setAlignment:NSCenterTextAlignment];

    NSDictionary *fontAttributesNew = @{NSFontAttributeName : _font, NSForegroundColorAttributeName : [NSColor whiteColor]};

    [_originalLabel drawWithRect:NSMakeRect(-fontBounds.origin.x, 0, 100000, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributesNew];

    CGContextRestoreGState(spriteContext);

    /*
    NSRect trim2 = [self usedRectForSpriteData:spriteData width:width
    heignt:height];
    CGContextSetRGBStrokeColor(spriteContext, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextStrokeRect(spriteContext, NSRectToCGRect(trim2));
    */

    [NSGraphicsContext restoreGraphicsState];

#ifdef ENABLE_16_BIT_TEXTURES
    // Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
    void *tempData;
    unsigned int *inPixel32;
    unsigned short *outPixel16;
    NSUInteger i;

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
    // You don't need the context at this point, so you need to release it to
    // avoid memory leaks.
    CGContextRelease(spriteContext);

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    //		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);

#ifdef ENABLE_16_BIT_TEXTURES
    glTexImage2D(GL_TEXTURE_2D, mipmapLevel, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, spriteData);
#else
    glTexImage2D(GL_TEXTURE_2D, mipmapLevel, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    // OpenGL likes the GL_BGRA + GL_UNSIGNED_INT_8_8_8_8_REV combination
//    glTexImage2D(GL_TEXTURE_2D, mipmapLevel, GL_RGBA, width, height, 0,
//    GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, spriteData);
#endif

    // Release the image data
    free(spriteData);

#ifdef ENABLE_MIPMAPPING
    glGenerateMipmap(GL_TEXTURE_2D);
#endif
}

- (NSRect)usedRectForSpriteData:(GLubyte *)spriteData width:(int)width heignt:(int)height {
    int minX = width;
    int minY = height;
    int maxX = 0;
    int maxY = 0;

    int i, j;
    NSRect rect;

    for (i = 0; i < width; i++) {
        for (j = 0; j < height; j++) {
            if (*(spriteData + j * width * 4 + i * 4 + 3)) {
                // This pixel is not transparent! Readjust bounds.
                // DDLogVerbose(@"Pixel Occupied: (%d, %d) ", i, j);
                minX = MIN(minX, i);
                maxX = MAX(maxX, i);
                minY = MIN(minY, j);
                maxY = MAX(maxY, j);
            }
        }
    }
    rect = NSMakeRect(minX, height - maxY - 1, maxX - minX + 1, maxY - minY + 1);
    return rect;
}

// ____________________________________________________________________________________________________
// colour

- (void)setColourPointer:(GLfloat *)colourPointer {
    //	DDLogVerbose(@"setColourPointer:%d",colourPointer);
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
    NSColor *normalizedColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    [normalizedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    /*
    const CGFloat *components = CGColorGetComponents(color);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    */
    //	DDLogVerbose(@"_colours:%d",_colours);
    //	DDLogVerbose(@"red:%d",red);

    self.colourComponentRed = red;
    self.colourComponentGreen = green;
    self.colourComponentBlue = blue;
    self.colourComponentAlpha = alpha;
}

- (void)setColourComponentRed:(GLfloat)value {
    _colours[0] = value;
    _colours[4] = value;
    _colours[8] = value;
    _colours[12] = value;
    _colourComponentRed = value;
}

- (void)setColourComponentGreen:(GLfloat)value {
    _colours[1] = value;
    _colours[5] = value;
    _colours[9] = value;
    _colours[13] = value;
    _colourComponentGreen = value;
}

- (void)setColourComponentBlue:(GLfloat)value {
    _colours[2] = value;
    _colours[6] = value;
    _colours[10] = value;
    _colours[14] = value;
    _colourComponentBlue = value;
}

- (void)setColourComponentAlpha:(GLfloat)value {
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
@synthesize targetTexturePointer = _targetTexturePointer;
@synthesize colourComponentRed = _colourComponentRed;
@synthesize colourComponentGreen = _colourComponentGreen;
@synthesize colourComponentBlue = _colourComponentBlue;
@synthesize colourComponentAlpha = _colourComponentAlpha;

@end

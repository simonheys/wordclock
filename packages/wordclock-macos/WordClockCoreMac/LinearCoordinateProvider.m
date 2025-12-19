//
//  LinearCoordinateProvider.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "LinearCoordinateProvider.h"

#import "WordClockPreferences.h"
#import "WordClockWord.h"
#import "WordClockWordManager.h"

static inline NSArray *ArrayFromCGRect(CGRect r) {
    return @[ [NSNumber numberWithFloat:r.origin.x], [NSNumber numberWithFloat:r.origin.y], [NSNumber numberWithFloat:r.size.width], [NSNumber numberWithFloat:r.size.height] ];
}

static inline CGRect CGRectFromArray(NSArray *a) {
    return CGRectMake([a[0] floatValue], [a[1] floatValue], [a[2] floatValue], [a[3] floatValue]);
}

@interface LinearCoordinateProvider (LinearCoordinateProviderPrivate)
- (float)cachedScaleForRect:(CGRect)rect;
- (void)addCachedScaleForRect:(CGRect)rect size:(float)size;
- (float)computeScaleForRect:(CGRect)rect;
- (void)updateLayout;
@end

@implementation LinearCoordinateProvider

- (instancetype)initWithWordClockWordManager:(WordClockWordManager *)wordClockWordManager tweenManager:(TweenManager *)tweenManager;
{
    self = [super initWithWordClockWordManager:wordClockWordManager tweenManager:tweenManager];
    if (self != nil) {
        _wordScale = 1.0f;
        _widthUsedInPreviousUpdate = -1;
        _heightUsedInPreviousUpdate = -1;
        _sizeCache = [[NSMutableArray alloc] init];
        _rectCache = [[NSMutableArray alloc] init];
        _translateX = [WordClockPreferences sharedInstance].linearTranslateX;
        _translateY = [WordClockPreferences sharedInstance].linearTranslateY;
        _scale = [WordClockPreferences sharedInstance].linearScale;

        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCLinearMarginLeftKey options:NSKeyValueObservingOptionNew context:NULL];
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCLinearMarginRightKey options:NSKeyValueObservingOptionNew context:NULL];
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCLinearMarginTopKey options:NSKeyValueObservingOptionNew context:NULL];
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCLinearMarginBottomKey options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:WCLinearMarginLeftKey] || [keyPath isEqualToString:WCLinearMarginRightKey] || [keyPath isEqualToString:WCLinearMarginTopKey] || [keyPath isEqualToString:WCLinearMarginBottomKey]) {
        [self updateLayout];
    }
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    @try {
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCLinearMarginLeftKey];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCLinearMarginRightKey];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCLinearMarginTopKey];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCLinearMarginBottomKey];
    } @catch (NSException *exception) {
    }
    [_sizeCache release];
    [_rectCache release];
    [super dealloc];
}

// ____________________________________________________________________________________________________
// orientation

- (BOOL)needsSetupForOrientation:(WCDeviceOrientation)orientation {
    return (orientation == WCDeviceOrientationPortraitUpsideDown || orientation == WCDeviceOrientationPortrait || orientation == WCDeviceOrientationLandscapeLeft || orientation == WCDeviceOrientationLandscapeRight);
}

- (void)setupForDefaultOrientation {
    [self updateLayout];
}

- (void)updateLayout {
    NSSize screenSize = [[NSScreen mainScreen] visibleFrame].size;

    [self setupForOrientation:WCDeviceOrientationPortrait andBounds:WCRectMake([WordClockPreferences sharedInstance].linearMarginLeft, [WordClockPreferences sharedInstance].linearMarginTop, screenSize.width - ([WordClockPreferences sharedInstance].linearMarginRight + [WordClockPreferences sharedInstance].linearMarginLeft), screenSize.height - ([WordClockPreferences sharedInstance].linearMarginBottom + [WordClockPreferences sharedInstance].linearMarginTop))];
}

// values to adjust when orientation changes
- (void)setupForOrientation:(WCDeviceOrientation)orientation andBounds:(WCRect)screenBounds {
    float w = screenBounds.size.width;
    float h = screenBounds.size.height;
    _x = screenBounds.origin.x;
    _y = screenBounds.origin.y;
    switch (orientation) {
        case WCDeviceOrientationPortraitUpsideDown:
            // DDLogVerbose(@"WCDeviceOrientationPortraitUpsideDown");
            _width = w;
            _height = h;
            _rotation = M_PI;
            _vx = -1.0f;
            _vy = 0.0f;
            break;
        case WCDeviceOrientationLandscapeLeft:
            // DDLogVerbose(@"WCDeviceOrientationLandscapeLeft");
            _width = h;
            _height = w;
            _vx = 0.0f;
            _vy = 1.0f;
            _rotation = -M_PI_2;
            break;
        case WCDeviceOrientationLandscapeRight:
            // DDLogVerbose(@"WCDeviceOrientationLandscapeRight");
            _width = h;
            _height = w;
            _vx = 0.0f;
            _vy = -1.0f;
            _rotation = M_PI_2;
            break;
        case WCDeviceOrientationPortrait:
        default:
            // DDLogVerbose(@"WCDeviceOrientationPortrait");
            _width = w;
            _height = h;
            _rotation = 0;
            _vx = 1.0f;
            _vy = 0.0f;
            break;
    }
}

// ____________________________________________________________________________________________________
// update

- (void)update {
    // don't need to do anything if width or height haven't changed
    WordClockWord *word;
    uint i;
    uint j;
    uint i_firstOnCurrentLine;
    float widthOfCurrentLine;
    float xAdjust;

    // advancement vectors
    float x, y;
    float lineSpace;

    i = 0;

    x = -_width * 0.5f;
    y = -_height * 0.5f;

    NSSize screenSize = [[NSScreen mainScreen] visibleFrame].size;
    float left = -screenSize.width * 0.5f + _x;
    float top = -screenSize.height * 0.5f + _y;

    NSFont *_font = [NSFont fontWithName:[WordClockPreferences sharedInstance].fontName size:kWordClockWordUnscaledFontSize];
    NSRect fontBounds = [_font boundingRectForFont];

    x = left;
    y = top;

    _leading = [WordClockPreferences sharedInstance].leading;

    if (_width == _widthUsedInPreviousUpdate && _height == _heightUsedInPreviousUpdate) {
    } else {
        _wordScale = [self computeScaleForRect:CGRectMake(0, 0, _width, _height)];
    }

    lineSpace = _wordScale * kWordClockWordUnscaledFontSize * (1.0f + _leading);

    switch ([WordClockPreferences sharedInstance].justification) {
        case WCJustificationLeft:
            for (word in self.wordClockWordManager.word) {
                _coordinates[i].w = _scale * _wordScale * word.unscaledTextureWidth;
                _coordinates[i].h = _scale * _wordScale * word.unscaledTextureHeight;
                _coordinates[i].wBounds = _scale * _wordScale * word.unscaledSize.width;
                _coordinates[i].hBounds = _scale * _wordScale * word.unscaledSize.height;
                _coordinates[i].r = _rotation;

                if (x + _wordScale * word.unscaledSize.width > left + _width) {
                    x = left;
                    y += lineSpace;
                }

                x += _wordScale * fontBounds.origin.x;

                _coordinates[i].x = _scale * (_translateX + x * _vx - y * _vy);
                _coordinates[i].y = _scale * (_translateY + x * _vy + y * _vx);

                x += _wordScale * (word.unscaledSize.width + word.spaceSize.width);

                x -= _wordScale * fontBounds.origin.x;

                //                x += _wordScale * fontBounds.origin.x;

                i++;
            }
            break;

        case WCJustificationRight:
            i_firstOnCurrentLine = 0;
            widthOfCurrentLine = 0.0f;
            for (word in self.wordClockWordManager.word) {
                _coordinates[i].w = _scale * _wordScale * word.unscaledTextureWidth;
                _coordinates[i].h = _scale * _wordScale * word.unscaledTextureHeight;
                _coordinates[i].wBounds = _scale * _wordScale * word.unscaledSize.width;
                _coordinates[i].hBounds = _scale * _wordScale * word.unscaledSize.height;
                _coordinates[i].r = _rotation;

                if (x + _wordScale * word.unscaledSize.width > _width * 0.5f) {
                    // move it all across
                    for (j = i_firstOnCurrentLine; j < i; j++) {
                        xAdjust = (_width * 0.5f - x + word.spaceSize.width);
                        _coordinates[j].x += xAdjust * _vx - 0 * _vy;
                        _coordinates[j].y += xAdjust * _vy + 0 * _vx;
                    }

                    x = left;
                    y += _wordScale * kWordClockWordUnscaledFontSize * (1.0f + _leading);
                    i_firstOnCurrentLine = i;
                }

                _coordinates[i].x = _scale * (_translateX + x * _vx - y * _vy);
                _coordinates[i].y = _scale * (_translateY + x * _vy + y * _vx);

                x += _wordScale * (word.unscaledSize.width + word.spaceSize.width);

                i++;
            }
            // also do last line
            for (j = i_firstOnCurrentLine; j < i; j++) {
                xAdjust = (_width * 0.5f - x + word.spaceSize.width);
                _coordinates[j].x += xAdjust * _vx - 0 * _vy;
                _coordinates[j].y += xAdjust * _vy + 0 * _vx;
            }
            break;

        case WCJustificationCentre:
            i_firstOnCurrentLine = 0;
            widthOfCurrentLine = 0.0f;
            for (word in self.wordClockWordManager.word) {
                _coordinates[i].w = _scale * _wordScale * word.unscaledTextureWidth;
                _coordinates[i].h = _scale * _wordScale * word.unscaledTextureHeight;
                _coordinates[i].wBounds = _scale * _wordScale * word.unscaledSize.width;
                _coordinates[i].hBounds = _scale * _wordScale * word.unscaledSize.height;
                _coordinates[i].r = _rotation;

                if (x + _wordScale * word.unscaledSize.width > _width * 0.5f) {
                    // move it all across
                    for (j = i_firstOnCurrentLine; j < i; j++) {
                        xAdjust = (_width * 0.5f - x + word.spaceSize.width) * 0.5f * _scale;
                        _coordinates[j].x += xAdjust * _vx - 0 * _vy;
                        _coordinates[j].y += xAdjust * _vy + 0 * _vx;
                    }

                    x = left;
                    y += _wordScale * kWordClockWordUnscaledFontSize * (1.0f + _leading);
                    i_firstOnCurrentLine = i;
                }

                _coordinates[i].x = _scale * (_translateX + x * _vx - y * _vy);
                _coordinates[i].y = _scale * (_translateY + x * _vy + y * _vx);

                x += _wordScale * (word.unscaledSize.width + word.spaceSize.width);

                i++;
            }
            // also do the last line
            for (j = i_firstOnCurrentLine; j < i; j++) {
                xAdjust = (_width * 0.5f - x + word.spaceSize.width) * 0.5f * _scale;
                _coordinates[j].x += xAdjust * _vx - 0 * _vy;
                _coordinates[j].y += xAdjust * _vy + 0 * _vx;
            }
            break;

        case WCJustificationFull:
            i_firstOnCurrentLine = 0;
            widthOfCurrentLine = 0.0f;
            for (word in self.wordClockWordManager.word) {
                _coordinates[i].w = _scale * _wordScale * word.unscaledTextureWidth;
                _coordinates[i].h = _scale * _wordScale * word.unscaledTextureHeight;
                _coordinates[i].wBounds = _scale * _wordScale * word.unscaledSize.width;
                _coordinates[i].hBounds = _scale * _wordScale * word.unscaledSize.height;
                _coordinates[i].r = _rotation;

                if (x + _wordScale * word.unscaledSize.width > _width * 0.5f) {
                    // move it all across
                    for (j = i_firstOnCurrentLine; j < i; j++) {
                        // possible ditch  + word.spaceSize.width
                        xAdjust = (_width * 0.5f - x + word.spaceSize.width) * (float)(j - i_firstOnCurrentLine) / (float)(i - i_firstOnCurrentLine - 1) * _scale;

                        _coordinates[j].x += xAdjust * _vx - 0 * _vy;
                        _coordinates[j].y += xAdjust * _vy + 0 * _vx;
                    }

                    x = left;
                    y += _wordScale * kWordClockWordUnscaledFontSize * (1.0f + _leading);
                    i_firstOnCurrentLine = i;
                }

                _coordinates[i].x = _scale * (_translateX + x * _vx - y * _vy);
                _coordinates[i].y = _scale * (_translateY + x * _vy + y * _vx);

                x += _wordScale * (word.unscaledSize.width + word.spaceSize.width);

                i++;
            }
            break;
    }

    _widthUsedInPreviousUpdate = _width;
    _heightUsedInPreviousUpdate = _height;
}

// ____________________________________________________________________________________________________
// init

- (void)initialiseNewCoordinates {
    WordClockWord *word;
    uint i;
    i = 0;
    for (word in self.wordClockWordManager.word) {
        _coordinates[i].x = 0;  // -_width*0.05f+(float) rand() * _width / RAND_MAX;
        _coordinates[i].y = 0;  //-_height*0.5f+(float) rand() * _height / RAND_MAX;
        _coordinates[i].w = (float)word.unscaledTextureWidth;
        _coordinates[i].h = (float)word.unscaledTextureHeight;
        _coordinates[i].wBounds = word.unscaledSize.width;
        _coordinates[i].hBounds = word.unscaledSize.height;
        _coordinates[i].r = 0.0f;
        i++;
    }

    // TODO a little ugly to set this here, but probably pretty reliable
    _leading = [WordClockPreferences sharedInstance].leading;
    _widthUsedInPreviousUpdate = -1;
    _heightUsedInPreviousUpdate = -1;
    [_sizeCache removeAllObjects];
    [_rectCache removeAllObjects];
}

// ____________________________________________________________________________________________________
// size calculations

- (BOOL)doesScaleFit:(float)scale inRect:(CGRect)rect {
    float x;
    float y;
    float s;
    float lineSpacing;

    WordClockWord *word;

    x = 0;
    y = 0;
    lineSpacing = scale * kWordClockWordUnscaledFontSize * (1.0f + _leading);
    for (word in self.wordClockWordManager.word) {
        s = scale * word.unscaledSize.width;
        if (x + s > rect.size.width) {
            x = 0;
            y += lineSpacing;
            if (y > rect.size.height - scale * word.unscaledSize.height) {
                return NO;
            }
        }
        x += s;
        x += scale * word.spaceSize.width;
    }

    return YES;
}

- (float)computeScaleForRect:(CGRect)rect {
    float size = [self cachedScaleForRect:rect];
    if (size != -1) {
        return size;
    }

    float low, high, mid;
    float _oldLow, _oldHigh;
    BOOL lowFits = NO, midFits = NO, highFits = NO;
    BOOL done = NO;

    low = 0.01;
    high = 100;

    _oldLow = -1;
    _oldHigh = -1;
    // try both sizes and mid-size
    // keep going until we have a tiny difference
    while (!done && fabs(low - high) > FONT_SIZE_TOLERANCE) {
        if (low != _oldLow) {
            lowFits = [self doesScaleFit:low inRect:rect];
            _oldLow = low;
        }
        if (high != _oldHigh) {
            highFits = [self doesScaleFit:high inRect:rect];
            _oldHigh = high;
        }
        // low fits, high doesn't
        if (lowFits && !highFits) {
            mid = (low + high) * 0.5f;
            midFits = [self doesScaleFit:mid inRect:rect];
            if (midFits) {
                low = mid;
            } else {
                high = mid;
            }
        } else {
            done = YES;
        }
    }
    // go with the low one

    [self addCachedScaleForRect:rect size:low];

    return low;
}

- (float)cachedScaleForRect:(CGRect)rect {
    CGRect r;
    for (int i = 0; i < [_rectCache count]; i++) {
        r = CGRectFromArray(_rectCache[i]);
        if (CGSizeEqualToSize(rect.size, r.size)) {
            return [_sizeCache[i] floatValue];
        }
    }
    return -1;
}

- (void)addCachedScaleForRect:(CGRect)rect size:(float)size {
    [_sizeCache addObject:@(size)];
    [_rectCache addObject:ArrayFromCGRect(rect)];
}

// ____________________________________________________________________________________________________
// accessors

@synthesize width = _width;
@synthesize height = _height;
@synthesize wordScale = _wordScale;

@end

//
//  RotaryCoordinateProvider.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "RotaryCoordinateProvider.h"

#import "WordClockPreferences.h"
#import "WordClockWord.h"

@interface RotaryCoordinateProvider ()
- (void)updateLayout;
@end

@implementation RotaryCoordinateProvider

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    @try {
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCRotaryScaleKey];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCRotaryTranslateXKey];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCRotaryTranslateYKey];
    } @catch (NSException *exception) {
    }
    [_rotaryCoordinateProviderGroup release];
    [super dealloc];
}

- (instancetype)initWithWordClockWordManager:(WordClockWordManager *)wordClockWordManager tweenManager:(TweenManager *)tweenManager;
{
    self = [super initWithWordClockWordManager:wordClockWordManager tweenManager:tweenManager];
    if (self != nil) {
        [self updateLayout];
        //		_orientationVector.vx = 1.0f;
        //		_orientationVector.vy = 0.0f;
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCRotaryScaleKey options:NSKeyValueObservingOptionNew context:NULL];
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCRotaryTranslateXKey options:NSKeyValueObservingOptionNew context:NULL];
        [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCRotaryTranslateYKey options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:WCRotaryScaleKey] || [keyPath isEqualToString:WCRotaryTranslateXKey] || [keyPath isEqualToString:WCRotaryTranslateYKey]) {
        [self updateLayout];
    }
}

- (void)updateLayout {
    _translateX = [WordClockPreferences sharedInstance].rotaryTranslateX;
    _translateY = [WordClockPreferences sharedInstance].rotaryTranslateY;
    _scale = [WordClockPreferences sharedInstance].rotaryScale;
}
// ____________________________________________________________________________________________________
// orientation

- (BOOL)needsSetupForOrientation:(WCDeviceOrientation)orientation {
    return (orientation == WCDeviceOrientationPortraitUpsideDown || orientation == WCDeviceOrientationPortrait || orientation == WCDeviceOrientationLandscapeLeft || orientation == WCDeviceOrientationLandscapeRight);
}

- (void)setupForDefaultOrientation {
    [self setupForOrientation:WCDeviceOrientationPortrait andBounds:WCRectMake(0, 0, 320, 320)];
}

// values to adjust when orientation changes
- (void)setupForOrientation:(WCDeviceOrientation)orientation andBounds:(WCRect)screenBounds {
    // we have separate vectors for display and interaction
    //	CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float proportion = screenBounds.size.width / screenBounds.size.height;
    switch (orientation) {
        case WCDeviceOrientationPortraitUpsideDown:
            _rotation = M_PI + M_PI_2;
            _orientationScale = proportion;
            _orientationVector.vx = -1.0f;
            _orientationVector.vy = 0.0f;
            _vx = -1.0f;
            _vy = 0.0f;
            break;
        case WCDeviceOrientationLandscapeLeft:
            _rotation = -M_PI_2 + M_PI_2;
            _orientationScale = 1.0f;
            _orientationVector.vx = 0.0f;
            _orientationVector.vy = -1.0f;
            _vx = 0.0f;
            _vy = 1.0f;
            break;
        case WCDeviceOrientationLandscapeRight:
            _rotation = M_PI_2 + M_PI_2;
            _orientationScale = 1.0f;
            _orientationVector.vx = 0.0f;
            _orientationVector.vy = 1.0f;
            _vx = 0.0f;
            _vy = -1.0f;
            break;
        case WCDeviceOrientationPortrait:
        default:
            _rotation = 0 + M_PI_2;
            _orientationScale = proportion;
            _orientationVector.vx = 1.0f;
            _orientationVector.vy = 0.0f;
            _vx = 1.0f;
            _vy = 0.0f;
            break;
    }
}

// ____________________________________________________________________________________________________
// orientation

- (void)update {
    WordClockWordGroup *group;
    WordClockWord *word;

    uint wordIndexInGroup;
    uint coordinateIndex = 0;

    NSInteger numberOfWordsInGroup;

    float a;
    // float currentRadius;

    //	currentRadius = 30.0f;
    float groupAngle;
    float groupRadius;
    float baselineOffset;
    float tx, ty;

    RotaryCoordinateProviderGroup *coordinateGroup;

    // decided not to adjust scale, causes big complications with interaction
    // and maintaining several scale values s = 1.0f; s = _scale;

    tx = _translateX * _vx - _translateY * _vy;
    ty = _translateX * _vy + _translateY * _vx;

    float vx, vy;

    NSFont *_font = [NSFont fontWithName:[WordClockPreferences sharedInstance].fontName size:kWordClockWordUnscaledFontSize];
    NSRect fontBounds = [_font boundingRectForFont];

    uint i;
    i = 0;
    for (group in self.wordClockWordManager.group) {
        numberOfWordsInGroup = group.numberOfWords;
        wordIndexInGroup = 0;
        coordinateGroup = (RotaryCoordinateProviderGroup *)_rotaryCoordinateProviderGroup[i];
        [coordinateGroup update];
        groupAngle = _rotation + coordinateGroup.angle;
        groupRadius = coordinateGroup.displayedRadius + fontBounds.origin.x;
        for (word in group.word) {
            if (!word.isSpace) {
                a = groupAngle - 2 * M_PI * wordIndexInGroup / numberOfWordsInGroup;
                vx = getSinFromTable(a);
                vy = getCosFromTable(a);
                baselineOffset = 1.0f * -word.unscaledSize.height * 0.55f;  // 0.55f seems to get x-height in centre
                                                                            //				_coordinates[ coordinateIndex
                                                                            //].x = _orientationScale * _scale * ( tx + vx *
                                                                            // groupRadius + 0 *
                                                                            // vx - baselineOffset * vy );
                                                                            // _coordinates[ coordinateIndex
                                                                            //].y = _orientationScale * _scale * ( ty + vy *
                                                                            // groupRadius
                                                                            //+ 0 * vy + baselineOffset * vx );
                _coordinates[coordinateIndex].x = tx + _orientationScale * _scale * (vx * groupRadius + 0 * vx - baselineOffset * vy);
                _coordinates[coordinateIndex].y = ty + _orientationScale * _scale * (vy * groupRadius + 0 * vy + baselineOffset * vx);
                _coordinates[coordinateIndex].r = a - M_PI_2;
                _coordinates[coordinateIndex].w = _orientationScale * _scale * (float)word.unscaledTextureWidth;
                _coordinates[coordinateIndex].h = _orientationScale * _scale * (float)word.unscaledTextureHeight;
                _coordinates[coordinateIndex].w_bounds = _orientationScale * _scale * word.unscaledSize.width;
                _coordinates[coordinateIndex].h_bounds = _orientationScale * _scale * word.unscaledSize.height;
                //				_coordinates[ i ].w = (float)
                // word.textureWidth; 				_coordinates[ i ].h =
                // (float) word.textureHeight;

                //				DDLogVerbose(@"label:%@ w:%f h:%f",[word
                // label],word.unscaledTextureWidth,word.unscaledTextureHeight);
                coordinateIndex++;
            }
            wordIndexInGroup++;
        }
        // currentRadius += coordinateGroup.radius;
        // currentRadius += [coordinateGroup outsideRadius];
        i++;
    }
    // DDLogVerbose(@"updated");
}

- (void)updateTextureSizesOnly {
    WordClockWordGroup *group;
    WordClockWord *word;

    uint coordinateIndex = 0;
    for (group in self.wordClockWordManager.group) {
        for (word in group.word) {
            if (!word.isSpace) {
                _coordinates[coordinateIndex].w = (float)word.unscaledTextureWidth;
                _coordinates[coordinateIndex].h = (float)word.unscaledTextureHeight;
            }
        }
    }
}

- (void)initialiseNewCoordinates {
    WordClockWord *word;
    WordClockWordGroup *group;
    RotaryCoordinateProviderGroup *coordinateGroup;
    uint i;
    i = 0;
    for (word in self.wordClockWordManager.word) {
        _coordinates[i].x = 0;  //(float) rand() * 320.0f / RAND_MAX;
        _coordinates[i].y = 0;  // 240.0 + (float) rand() * 240.0f / RAND_MAX;
        _coordinates[i].w = (float)word.unscaledTextureWidth;
        _coordinates[i].h = (float)word.unscaledTextureHeight;
        _coordinates[i].w_bounds = word.unscaledSize.width;
        _coordinates[i].h_bounds = word.unscaledSize.height;
        _coordinates[i].r = 0.0f;
        i++;
    }

    if (_rotaryCoordinateProviderGroup) {
        [_rotaryCoordinateProviderGroup release];
    }

    _rotaryCoordinateProviderGroup = [[NSMutableArray alloc] init];
    for (group in self.wordClockWordManager.group) {
        coordinateGroup = [[RotaryCoordinateProviderGroup alloc] initWithGroup:group tweenManager:self.tweenManager];
        if ([_rotaryCoordinateProviderGroup count] > 0) {
            [coordinateGroup setParent:(RotaryCoordinateProviderGroup *)[_rotaryCoordinateProviderGroup lastObject]];
            [(RotaryCoordinateProviderGroup *)[_rotaryCoordinateProviderGroup lastObject] setChild:coordinateGroup];
        }
        [_rotaryCoordinateProviderGroup addObject:coordinateGroup];
        [coordinateGroup release];
    }

    for (coordinateGroup in _rotaryCoordinateProviderGroup) {
        [coordinateGroup establishInitialValues];
    }
}

@end

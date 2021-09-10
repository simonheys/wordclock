//
//  RotaryCoordinateProvider.m
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "RotaryCoordinateProvider.h"

@implementation RotaryCoordinateProvider

- (id)init {
    self = [super init];
    if (self != nil) {
        _translateX = [WordClockPreferences sharedInstance].rotaryTranslateX;
        _translateY = [WordClockPreferences sharedInstance].rotaryTranslateY;
        _scale = [WordClockPreferences sharedInstance].rotaryScale;

        //		_orientationVector.vx = 1.0f;
        //		_orientationVector.vy = 0.0f;
    }
    return self;
}

// ____________________________________________________________________________________________________ orientation

- (void)setupForCurrentSize {
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;

    _rotation = 0 + M_PI_2;
    _orientationScale = w > h ? 1.0f : w / h;
    _orientationVector.vx = 1.0f;
    _orientationVector.vy = 0.0f;
    _vx = 1.0f;
    _vy = 0.0f;
}

// ____________________________________________________________________________________________________ orientation

- (void)update {
    WordClockWordGroup *group;
    WordClockWord *word;

    uint wordIndexInGroup;
    uint coordinateIndex = 0;

    uint numberOfWordsInGroup;

    float a;
    // float currentRadius;

    //	currentRadius = 30.0f;
    float groupAngle;
    float groupRadius;
    float baselineOffset;
    float tx, ty;

    RotaryCoordinateProviderGroup *coordinateGroup;

    // decided not to adjust scale, causes big complications with interaction and maintaining several scale values
    // s = 1.0f;
    // s = _scale;

    tx = _translateX * _vx - _translateY * _vy;
    ty = _translateX * _vy + _translateY * _vx;

    float vx, vy;

    uint i;
    i = 0;
    for (group in [WordClockWordManager sharedInstance].group) {
        numberOfWordsInGroup = group.numberOfWords;
        wordIndexInGroup = 0;
        coordinateGroup = (RotaryCoordinateProviderGroup *)[_rotaryCoordinateProviderGroup objectAtIndex:i];
        [coordinateGroup update];
        groupAngle = _rotation + coordinateGroup.angle;
        groupRadius = coordinateGroup.displayedRadius;
        for (word in group.word) {
            if (!word.isSpace) {
                a = groupAngle - 2 * M_PI * wordIndexInGroup / numberOfWordsInGroup;
                vx = getSinFromTable(a);
                vy = getCosFromTable(a);
                baselineOffset = 1.0f * -word.unscaledSize.height * 0.55f;  // 0.55f seems to get x-height in centre
                _coordinates[coordinateIndex].x = _orientationScale * _scale * (tx + vx * groupRadius + 0 * vx - baselineOffset * vy);
                _coordinates[coordinateIndex].y = _orientationScale * _scale * (ty + vy * groupRadius + 0 * vy + baselineOffset * vx);
                _coordinates[coordinateIndex].r = a - M_PI_2;
                _coordinates[coordinateIndex].w = _orientationScale * _scale * (float)word.unscaledTextureWidth;
                _coordinates[coordinateIndex].h = _orientationScale * _scale * (float)word.unscaledTextureHeight;
                _coordinates[coordinateIndex].w_bounds = _orientationScale * _scale * word.unscaledSize.width;
                _coordinates[coordinateIndex].h_bounds = _orientationScale * _scale * word.unscaledSize.height;
                //				_coordinates[ i ].w = (float) word.textureWidth;
                //				_coordinates[ i ].h = (float) word.textureHeight;

                //				DLog(@"label:%@ w:%f h:%f",[word label],word.unscaledTextureWidth,word.unscaledTextureHeight);
                coordinateIndex++;
            }
            wordIndexInGroup++;
        }
        // currentRadius += coordinateGroup.radius;
        // currentRadius += [coordinateGroup outsideRadius];
        i++;
    }
    // DLog(@"updated");
}

- (void)updateTextureSizesOnly {
    WordClockWordGroup *group;
    WordClockWord *word;

    uint coordinateIndex = 0;
    for (group in [WordClockWordManager sharedInstance].group) {
        for (word in group.word) {
            if (!word.isSpace) {
                _coordinates[coordinateIndex].w = (float)word.unscaledTextureWidth;
                _coordinates[coordinateIndex].h = (float)word.unscaledTextureHeight;
            }
        }
    }
}

- (void)initialiseNewCoordinates {
    DLog(@"initialiseNewCoordinates");
    WordClockWord *word;
    WordClockWordGroup *group;
    RotaryCoordinateProviderGroup *coordinateGroup;
    uint i;
    i = 0;
    for (word in [WordClockWordManager sharedInstance].word) {
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
    for (group in [WordClockWordManager sharedInstance].group) {
        coordinateGroup = [[RotaryCoordinateProviderGroup alloc] initWithGroup:group];
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

- (void)dealloc {
    DLog(@"dealloc");
    [_rotaryCoordinateProviderGroup release];
    [super dealloc];
}

@end

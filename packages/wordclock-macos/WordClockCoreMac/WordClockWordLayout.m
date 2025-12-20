//
//  WordClockWordLayout.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockWordLayout.h"

#import "LinearCoordinateProvider.h"
#import "RotaryCoordinateProvider.h"
#import "TweenManager.h"
#import "WordClockPreferences.h"
#import "WordClockWord.h"
#import "WordClockWordManager.h"
#import "easing_functions.h"
#import "sin_and_cos_tables.h"

@interface WordClockWordLayout ()
@property(retain) CoordinateProvider *tweenSnapshotCoordinateProvider;
@property(nonatomic, retain) TweenManager *tweenManager;
@property(nonatomic, retain) WordClockWordManager *wordClockWordManager;
@end

#define MIN4(x, y, z, w) ((x) < (y) ? ((x) < (z) ? ((x) < (w) ? (x) : (w)) : ((w) < (z) ? (w) : (z))) : ((y) < (z) ? ((y) < (w) ? (y) : (w)) : ((z) < (w) ? (z) : (w))))

#define MAX4(x, y, z, w) ((x) > (y) ? ((x) > (z) ? ((x) > (w) ? (x) : (w)) : ((w) > (z) ? (w) : (z))) : ((y) > (z) ? ((y) > (w) ? (y) : (w)) : ((z) > (w) ? (z) : (w))))

@implementation WordClockWordLayout

@synthesize vertices = _vertices;
@synthesize scale = _scale;
@synthesize translateX = _translateX;
@synthesize translateY = _translateY;
@synthesize isTweening = _isTweening;
@synthesize transitionTweenValue = _transitionTweenValue;
@synthesize rectsForCulling = _rectsForCulling;
@synthesize tweenSnapshotCoordinateProvider = _tweenSnapshotCoordinateProvider;
@synthesize wordClockWordManager = _wordClockWordManager;
@synthesize tweenManager = _tweenManager;

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [_tweenManager release];
    [_linear release];
    [_rotary release];
    [_tweenSnapshotCoordinateProvider release];
    [_wordClockWordManager release];
    [super dealloc];
}

- (instancetype)initWithWordClockWordManager:(WordClockWordManager *)wordClockWordManager tweenManager:(TweenManager *)tweenManager {
    self = [super init];
    if (self != nil) {
        self.wordClockWordManager = wordClockWordManager;
        self.tweenManager = tweenManager;

        buildSinAndCosTables();

        _rotary = [[RotaryCoordinateProvider alloc] initWithWordClockWordManager:self.wordClockWordManager tweenManager:self.tweenManager];
        _linear = [[LinearCoordinateProvider alloc] initWithWordClockWordManager:self.wordClockWordManager tweenManager:self.tweenManager];

        _linearTranslateX = [WordClockPreferences sharedInstance].linearTranslateX;
        _linearTranslateY = [WordClockPreferences sharedInstance].linearTranslateY;
        _linearScale = [WordClockPreferences sharedInstance].linearScale;
        _rotaryTranslateX = [WordClockPreferences sharedInstance].rotaryTranslateX;
        _rotaryTranslateY = [WordClockPreferences sharedInstance].rotaryTranslateY;
        _rotaryScale = [WordClockPreferences sharedInstance].rotaryScale;

        switch ([WordClockPreferences sharedInstance].style) {
            case WCStyleLinear:
                _isLinearSelected = YES;
                _translateX = _linearTranslateX;
                _translateY = _linearTranslateY;
                _scale = _linearScale;
                break;
            case WCStyleRotary:
                _isLinearSelected = NO;
                _translateX = _rotaryTranslateX;
                _translateY = _rotaryTranslateY;
                _scale = _rotaryScale;
                break;
        }

        _isTweening = NO;
        _transitionTweenValue = 0.0f;
    }
    return self;
}

- (void)texturesDidChange {
    [_rotary texturesDidChange];
    [_linear texturesDidChange];
}

// ____________________________________________________________________________________________________
// orientation

- (void)setTranslateX:(float)value {
    if (_isLinearSelected) {
        _linearTranslateX = value;
        _linear.translateX = value;
    } else {
        _rotaryTranslateX = value;
        _rotary.translateX = value;
    }
    _translateX = value;
}

- (void)setTranslateY:(float)value {
    if (_isLinearSelected) {
        _linearTranslateY = value;
        _linear.translateY = value;
    } else {
        _rotaryTranslateY = value;
        _rotary.translateY = value;
    }
    _translateY = value;
}

- (void)setScale:(float)value {
    if (_isLinearSelected) {
        _linearScale = value;
        _linear.scale = value;
    } else {
        _rotaryScale = value;
        _rotary.scale = value;
    }
    _scale = value;
}

- (float)getTargetScale {
    if (_isLinearSelected) {
        return _linear.scale;
    } else {
        return _rotary.scale;
    }
}

- (float)getTargetTranslateX {
    if (_isLinearSelected) {
        return _linear.translateX;
    } else {
        return _rotary.translateX;
    }
}

- (float)getTargetTranslateY {
    if (_isLinearSelected) {
        return _linear.translateY;
    } else {
        return _rotary.translateY;
    }
}


- (WordClockOrientationVector)getTargetOrientationVector {
    if (_isLinearSelected) {
        return _linear.orientationVector;
    } else {
        return _rotary.orientationVector;
    }
}

- (void)tweenFromCoordinateProvider:(CoordinateProvider *)target reverse:(BOOL)reverse {
    self.tweenSnapshotCoordinateProvider = [target clone];
    _isTweening = YES;

    NSInteger numberOfWords = self.wordClockWordManager.numberOfWords;
    WordClockWord *word;
    float delay;
    float duration;

    for (NSInteger i = 0; i < numberOfWords; i++) {
        word = (self.wordClockWordManager.word)[reverse ? (numberOfWords - 1 - i) : i];
        [self.tweenManager removeTweensWithTarget:word andKeyPath:@"tweenValue"];
        word.tweenValue = 0.0f;

        switch ([WordClockPreferences sharedInstance].transitionStyle) {
            case WCTransitionStyleSlow:
                duration = 2.0f;
                delay = i * quad_ease_out((float)i / numberOfWords) * 1 / 60.0f;
                break;
            case WCTransitionStyleMedium:
                duration = 2.0f;
                delay = i * quad_ease_out((float)i / numberOfWords) * 1 / 180.0f;
                break;
            case WCTransitionStyleFast:
                duration = 1.5f;
                delay = 0.0f;
                break;
        }
        if (i == numberOfWords - 1) {
            [self.tweenManager tweenWithTarget:word keyPath:@"tweenValue" toFloatValue:1.0f delay:delay duration:duration ease:kTweenQuadEaseInOut onComplete:@selector(transitionTweenComplete:) onCompleteTarget:self];

        } else {
            [self.tweenManager tweenWithTarget:word keyPath:@"tweenValue" toFloatValue:1.0f delay:delay duration:duration ease:kTweenQuadEaseInOut];
        }
    }
}

- (void)transitionTweenComplete:(Tween *)tween {
    DDLogVerbose(@"transitionTweenComplete");
    _isTweening = NO;
}

- (void)linearSelected:(id)sender {
    DDLogVerbose(@"linearSelected");
    _isLinearSelected = YES;

    _needsOrientationUpdateNotification = YES;
    [self tweenFromCoordinateProvider:_rotary reverse:YES];
}

- (void)rotarySelected:(id)sender {
    DDLogVerbose(@"rotarySelected");
    _isLinearSelected = NO;
    _needsOrientationUpdateNotification = YES;
    [self tweenFromCoordinateProvider:_linear reverse:NO];
}

- (void)update {
    float width, height;

    float vx, vy;
    float ox, oy;
    float wvx;
    float wvy;
    float hvx;
    float hvy;

    float a;
    float m;

    CoordinateProvider *tweenFrom, *tweenTo, *current;

    if (_isLinearSelected) {
        [_linear update];
    } else {
        [_rotary update];
    }

    if (_isTweening) {
        tweenFrom = self.tweenSnapshotCoordinateProvider;
        if (_isLinearSelected) {
            tweenTo = _linear;
        } else {
            tweenTo = _rotary;
        }
    } else {
        if (_isLinearSelected) {
            current = _linear;
        } else {
            current = _rotary;
        }
    }

    uint offset = 0;

    float xtl;
    float xtr;
    float xbl;
    float xbr;
    float ytl;
    float ytr;
    float ybl;
    float ybr;


    NSInteger numberOfWords = self.wordClockWordManager.numberOfWords;
    WordClockWord *word;

    if (_isTweening) {
        for (NSInteger i = 0; i < numberOfWords; i++) {
            word = (self.wordClockWordManager.word)[i];
            m = word.tweenValue;

            a = tweenFrom.coordinates[i].r + m * (tweenTo.coordinates[i].r - tweenFrom.coordinates[i].r);

            vx = getCosFromTable(a);
            vy = -getSinFromTable(a);

            width = tweenFrom.coordinates[i].w + m * (tweenTo.coordinates[i].w - tweenFrom.coordinates[i].w);
            height = tweenFrom.coordinates[i].h + m * (tweenTo.coordinates[i].h - tweenFrom.coordinates[i].h);

            ox = tweenFrom.coordinates[i].x + m * (tweenTo.coordinates[i].x - tweenFrom.coordinates[i].x);
            oy = tweenFrom.coordinates[i].y + m * (tweenTo.coordinates[i].y - tweenFrom.coordinates[i].y);

            wvx = width * vx;
            wvy = width * vy;
            hvx = height * vx;
            hvy = height * vy;

            xtl = ox;
            xtr = ox + wvx;
            xbl = ox - hvy;
            xbr = ox + wvx - hvy;
            ytl = oy;
            ytr = oy + wvy;
            ybl = oy + hvx;
            ybr = oy + wvy + hvx;

            // top left
            _vertices[offset++] = xtl;
            _vertices[offset++] = ytl;
            // top right
            _vertices[offset++] = xtr;
            _vertices[offset++] = ytr;
            // bottom left
            _vertices[offset++] = xbl;
            _vertices[offset++] = ybl;
            // bottom right
            _vertices[offset++] = xbr;
            _vertices[offset++] = ybr;

#ifdef ENABLE_CULL
            // printf("cull");
            width = tweenFrom.coordinates[i].wBounds + m * (tweenTo.coordinates[i].wBounds - tweenFrom.coordinates[i].wBounds);
            height = tweenFrom.coordinates[i].hBounds + m * (tweenTo.coordinates[i].hBounds - tweenFrom.coordinates[i].hBounds);

            wvx = width * vx;
            wvy = width * vy;
            hvx = height * vx;
            hvy = height * vy;

            xtl = ox;
            xtr = ox + wvx;
            xbl = ox - hvy;
            xbr = ox + wvx - hvy;
            ytl = oy;
            ytr = oy + wvy;
            ybl = oy + hvx;
            ybr = oy + wvy + hvx;

            _rectsForCulling[i].i = i;

            _rectsForCulling[i].xl = MIN4(xtl, xtr, xbl, xbr);
            _rectsForCulling[i].xr = MAX4(xtl, xtr, xbl, xbr);
            _rectsForCulling[i].yt = MIN4(ytl, ytr, ybl, ybr);
            _rectsForCulling[i].yb = MAX4(ytl, ytr, ybl, ybr);
#endif
        }
    } else {
        for (NSInteger i = 0; i < numberOfWords; i++) {
            a = current.coordinates[i].r;

            vx = getCosFromTable(a);
            vy = -getSinFromTable(a);

            width = current.coordinates[i].w;
            height = current.coordinates[i].h;

            ox = current.coordinates[i].x;
            oy = current.coordinates[i].y;

            wvx = width * vx;
            wvy = width * vy;
            hvx = height * vx;
            hvy = height * vy;

            xtl = ox;
            xtr = ox + wvx;
            xbl = ox - hvy;
            xbr = ox + wvx - hvy;
            ytl = oy;
            ytr = oy + wvy;
            ybl = oy + hvx;
            ybr = oy + wvy + hvx;

            // top left
            _vertices[offset++] = xtl;
            _vertices[offset++] = ytl;
            // top right
            _vertices[offset++] = xtr;
            _vertices[offset++] = ytr;
            // bottom left
            _vertices[offset++] = xbl;
            _vertices[offset++] = ybl;
            // bottom right
            _vertices[offset++] = xbr;
            _vertices[offset++] = ybr;

#ifdef ENABLE_CULL
            width = current.coordinates[i].wBounds;
            height = current.coordinates[i].hBounds;

            wvx = width * vx;
            wvy = width * vy;
            hvx = height * vx;
            hvy = height * vy;

            xtl = ox;
            xtr = ox + wvx;
            xbl = ox - hvy;
            xbr = ox + wvx - hvy;
            ytl = oy;
            ytr = oy + wvy;
            ybl = oy + hvx;
            ybr = oy + wvy + hvx;

            _rectsForCulling[i].i = i;

            _rectsForCulling[i].xl = MIN4(xtl, xtr, xbl, xbr);
            _rectsForCulling[i].xr = MAX4(xtl, xtr, xbl, xbr);
            _rectsForCulling[i].yt = MIN4(ytl, ytr, ybl, ybr);
            _rectsForCulling[i].yb = MAX4(ytl, ytr, ybl, ybr);
#endif
        }
    }
}

- (float)getLayoutWordScale {
    if (_isLinearSelected) {
        return _linear.wordScale;
    } else {
        return 1.0f;
    }
}
@end

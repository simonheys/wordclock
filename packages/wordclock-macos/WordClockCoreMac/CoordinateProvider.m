//
//  CoordinateProvider.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "CoordinateProvider.h"

#import "TweenManager.h"
#import "WordClockWordManager.h"

@interface CoordinateProvider ()
@end

@implementation CoordinateProvider

@synthesize coordinates = _coordinates;
@synthesize scale = _scale;
@synthesize translateX = _translateX;
@synthesize translateY = _translateY;
@synthesize orientationVector = _orientationVector;
@synthesize wordClockWordManager = _wordClockWordManager;
@synthesize tweenManager = _tweenManager;

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    free(_coordinates);
    [_wordClockWordManager release];
    [_tweenManager release];
    [super dealloc];
}

- (instancetype)initWithWordClockWordManager:(WordClockWordManager *)wordClockWordManager tweenManager:(TweenManager *)tweenManager {
    self = [super init];
    if (self != nil) {
        self.wordClockWordManager = wordClockWordManager;
        self.tweenManager = tweenManager;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberOfWordsDidChange:) name:kWordClockWordManagerNumberOfWordsDidChangeNotification object:self.wordClockWordManager];

        _coordinates = malloc(self.wordClockWordManager.numberOfWords * sizeof(WordClockWordCoordinates));

        _translateX = 0.0f;
        _translateY = 0.0f;
        _scale = 1.0f;

        _orientationVector.vx = 1.0f;
        _orientationVector.vy = 0.0f;

        [self setupForDefaultOrientation];
    }
    return self;
}

- (void)numberOfWordsDidChange:(NSNotification *)notification {
    free(_coordinates);
    _coordinates = malloc(self.wordClockWordManager.numberOfWords * sizeof(WordClockWordCoordinates));
}

//- (void)texturesDidChange:(NSNotification *)notification {
- (void)texturesDidChange {
    [self initialiseNewCoordinates];
}

- (void)initialiseNewCoordinates {
}

// ____________________________________________________________________________________________________
// orientation

- (BOOL)needsSetupForOrientation:(WCDeviceOrientation)orientation {
    return NO;
}

- (void)setupForDefaultOrientation {
    _vx = 1.0f;
    _vy = 0.0f;
    _rotation = 0;
}

// values to adjust when orientation changes
- (void)setupForOrientation:(WCDeviceOrientation)orientation andBounds:(WCRect)screenBounds {
}

- (void)update {
    // get words / groups from shared provider
    // self.wordClockWordManager.group;

    // figure out where they all go
}

// move everything away from centre
- (void)shake {
    float m;
    NSInteger numberOfWords = self.wordClockWordManager.numberOfWords;
    for (uint i = 0; i < numberOfWords; i++) {
        m = (float)rand() / RAND_MAX;
        _coordinates[i].x *= (4.0 + m);
        _coordinates[i].y *= (4.0 + m);
        _coordinates[i].r = M_PI * 2 * m;
    }
}

- (CoordinateProvider *)clone {
    CoordinateProvider *clone = [[CoordinateProvider new] autorelease];
    NSInteger numberOfWords = self.wordClockWordManager.numberOfWords;
    clone.coordinates = malloc(numberOfWords * sizeof(WordClockWordCoordinates));
    for (uint i = 0; i < numberOfWords; i++) {
        clone.coordinates[i].x = _coordinates[i].x;
        clone.coordinates[i].y = _coordinates[i].y;
        clone.coordinates[i].w = _coordinates[i].w;
        clone.coordinates[i].h = _coordinates[i].h;
        clone.coordinates[i].r = _coordinates[i].r;
        clone.coordinates[i].w_bounds = _coordinates[i].w_bounds;
        clone.coordinates[i].h_bounds = _coordinates[i].h_bounds;
    }
    clone.translateX = _translateX;
    clone.translateY = _translateY;
    clone.scale = _scale;

    WordClockOrientationVector v;

    v.vx = _orientationVector.vx;
    v.vy = _orientationVector.vy;

    clone.orientationVector = v;

    return clone;
}

@end

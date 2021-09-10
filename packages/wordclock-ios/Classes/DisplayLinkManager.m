//
//  DisplayLinkManager.m
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "DisplayLinkManager.h"

@interface DisplayLinkManager (DisplayLinkManagerPrivate)
- (void)startAnimation;
- (void)animate;
- (void)stopAnimation;
@end

@implementation DisplayLinkManager

@synthesize animating;
@dynamic animationFrameInterval;

- (id)init {
    self = [super init];
    if (self != nil) {
        _targets = [[NSMutableArray alloc] init];
        _targetsForRemoval = [[NSMutableArray alloc] init];

        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;

        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.

        //		NSString *reqSysVer = @"3.1";
        //		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        //		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        //			displayLinkSupported = TRUE;
    }
    return self;
}

- (void)addTarget:(NSObject *)target selector:(SEL)selector {
    [self addTarget:target selector:selector priority:NO];
}

- (void)addTarget:(NSObject *)target selector:(SEL)selector priority:(BOOL)priority {
    DisplayLinkManagerTarget *t;
    t = [[DisplayLinkManagerTarget alloc] initWithTarget:target selector:selector];
    if (priority) {
        [_targets insertObject:t atIndex:0];
    } else {
        [_targets addObject:t];
    }
    [t release];
    if ([_targets count] == 1) {
        [self startAnimation];
    }
}

- (void)removeTarget:(NSObject *)targetObjectForRemoval {
    DisplayLinkManagerTarget *target;
    for (target in _targets) {
        if ([target.target isEqual:targetObjectForRemoval]) {
            [_targetsForRemoval addObject:target];
        }
    }
}

// we also remove objects here
// so that this array can't be mutated while we are running
- (void)update:(id)sender {
    DisplayLinkManagerTarget *target;
    if ([_targetsForRemoval count] > 0) {
        for (target in _targetsForRemoval) {
            [_targets removeObject:target];
        }
        [_targetsForRemoval removeAllObjects];
        if ([_targets count] == 0) {
            [self stopAnimation];
        }
    } else {
        NSArray *targetsNonMut = [_targets copy];

        for (target in targetsNonMut) {
            [target callSelector];
        }

        [targetsNonMut release];
    }
}

- (void)dealloc {
    [self stopAnimation];
    [_targets release];
    [_targetsForRemoval release];
    [super dealloc];
}

// ____________________________________________________________________________________________________ animation

- (NSInteger)animationFrameInterval {
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;

        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation {
    if (!animating) {
        DLog(@"startAnimation");
        if (displayLinkSupported) {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.

            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(update:)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        } else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(update:) userInfo:nil repeats:TRUE];

        animating = TRUE;
    }
}

- (void)stopAnimation {
    if (animating) {
        DLog(@"stopAnimation");
        if (displayLinkSupported) {
            [displayLink invalidate];
            displayLink = nil;
        } else {
            [animationTimer invalidate];
            animationTimer = nil;
        }

        animating = FALSE;
    }
}

// ____________________________________________________________________________________________________ singleton

+ (DisplayLinkManager *)sharedInstance {
    static dispatch_once_t once;
    static DisplayLinkManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end

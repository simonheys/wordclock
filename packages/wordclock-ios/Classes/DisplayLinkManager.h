//
//  DisplayLinkManager.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import "DisplayLinkManagerTarget.h"
#import "DLog.h"

@interface DisplayLinkManager : NSObject {
	NSMutableArray *_targets;
	NSMutableArray *_targetsForRemoval;

@private
	BOOL animating;
	BOOL displayLinkSupported;
	NSInteger animationFrameInterval;
	// Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	// CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	// The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
	// isn't available.
	id displayLink;
    NSTimer *animationTimer;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void) startAnimation;
- (void) stopAnimation;

- (void)addTarget:(NSObject *)target selector:(SEL)selector;
- (void)addTarget:(NSObject *)target selector:(SEL)selector;
- (void)addTarget:(NSObject *)target selector:(SEL)selector priority:(BOOL)priority;



- (void)removeTarget:(NSObject *)targetObjectForRemoval;
+ (DisplayLinkManager *)sharedInstance;

@end

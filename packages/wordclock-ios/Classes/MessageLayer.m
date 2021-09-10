//
//  MessageLayer.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "MessageLayer.h"

#define CORNER_RADIUS 15.0f

@implementation MessageLayer

+ (id)defaultValueForKey:(NSString *)key {
    if ([key isEqualToString:@"needsDisplayOnBoundsChange"])
        return (id)kCFBooleanTrue;

    return [super defaultValueForKey:key];
}

- (id)init {
    if (self = [super init]) {
        self.bounds = CGRectMake(0.0, 0.0, 200, 50);
        self.opacity = 0.0f;
        _showing = NO;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context {
    CGRect r = [self bounds];
    CGContextSetGrayFillColor(context, 0.15f, 0.9f);
    [self addRect:r toContext:context];
    CGContextDrawPath(context, kCGPathFill);

    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    CGContextSetGrayFillColor(context, 1.0f, 1.0f);
    CGContextSelectFont(context, "Helvetica-Bold", 16, kCGEncodingMacRoman);
    CGContextShowTextAtPoint(context, CORNER_RADIUS, CORNER_RADIUS + 14, "Double-tap for options", 22);
}

- (void)toggleShowing {
    DLog(@"toggleShowing");
    [self setShowing:!_showing];
}

- (void)setShowing:(BOOL)value {
    DLog(@"setShowing");
    if (value != _showing) {
        if (value) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(delayPassedSinceShowingCalled) userInfo:nil repeats:NO];

        } else {
            if (_timer) {
                [_timer invalidate];
            }
            CAAnimation *animation = [self displayAnimationForKeyPath:@"opacity" from:1.0f to:0.0f duration:0.2f];

            [self addAnimation:animation forKey:@"opacityAnimation"];
        }
        _showing = value;
    }
}

- (void)delayPassedSinceShowingCalled {
    DLog(@"delayPassedSinceShowingCalled");
    if (_showing) {
        CAAnimation *animation = [self displayAnimationForKeyPath:@"opacity" from:0.0f to:1.0f duration:0.2f];

        [self addAnimation:animation forKey:@"opacityAnimation"];

        _timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(delayPassedSinceStartedShowing) userInfo:nil repeats:NO];
    }
}

- (void)delayPassedSinceStartedShowing {
    DLog(@"delayPassedSinceStartedShowing");
    if (_showing) {
        CAAnimation *animation = [self displayAnimationForKeyPath:@"opacity" from:1.0f to:0.0f duration:0.2f];

        [self addAnimation:animation forKey:@"opacityAnimation"];

        _showing = NO;
    }
}

- (CAAnimation *)displayAnimationForKeyPath:(NSString *)keyPath from:(float)from to:(float)to duration:(float)duration {
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = [NSNumber numberWithFloat:from];
    animation.toValue = [NSNumber numberWithFloat:to];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

- (void)addRect:(CGRect)rect toContext:(CGContextRef)context {
    float l = CGRectGetMinX(rect);
    float b = CGRectGetMaxY(rect);
    float r = CGRectGetMaxX(rect);
    float t = CGRectGetMinY(rect);

    // top left arc
    CGContextMoveToPoint(context, l, t + CORNER_RADIUS);
    CGContextAddArc(context, l + CORNER_RADIUS, t + CORNER_RADIUS, CORNER_RADIUS, M_PI * 1.0f, M_PI * 1.5f, false);

    // top edge
    CGContextAddLineToPoint(context, r - CORNER_RADIUS, t);

    // top right arc
    CGContextAddArc(context, r - CORNER_RADIUS, t + CORNER_RADIUS, CORNER_RADIUS, M_PI * 1.5f, M_PI * 2.0f, false);

    // right edge
    CGContextAddLineToPoint(context, r, b - CORNER_RADIUS);

    // bottom right arc
    CGContextAddArc(context, r - CORNER_RADIUS, b - CORNER_RADIUS, CORNER_RADIUS, M_PI * 0.0f, M_PI * 0.5f, false);

    // bottom edge
    CGContextAddLineToPoint(context, l + CORNER_RADIUS, b);

    // bottom left arc
    CGContextAddArc(context, l + CORNER_RADIUS, b - CORNER_RADIUS, CORNER_RADIUS, M_PI * 0.5f, M_PI * 1.0f, false);

    // left edge
    CGContextAddLineToPoint(context, l, t + CORNER_RADIUS);
}

@end

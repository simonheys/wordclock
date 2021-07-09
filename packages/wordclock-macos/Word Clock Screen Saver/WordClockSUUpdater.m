//
//  WordClockSUUpdater.m
//  WordClock macOS
//
//  Created by Simon Heys on 28/11/2012.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//
    //
//  WordClockSUUpdater.m
//  WordClock
//
//  Created by Simon on 28/11/2012.
//
//

#import "WordClockSUUpdater.h"

@interface WordClockSUUpdater () <SUUpdaterDelegate>
@end

@implementation WordClockSUUpdater

+ (WordClockSUUpdater *)sharedUpdater
{
#ifdef SCREENSAVER
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
#else
	NSBundle *bundle = [NSBundle mainBundle];
#endif
    return (WordClockSUUpdater *)[self updaterForBundle:bundle];
}

- (instancetype)init
{
#ifdef SCREENSAVER
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
#else
	NSBundle *bundle = [NSBundle mainBundle];
#endif
    
    self = [self initForBundle:bundle];
    if ( self ) {
        [self setDelegate:self];
        DDLogVerbose(@"[[NSBundle mainBundle] bundlePath]:%@",[[NSBundle mainBundle] bundlePath]);
    }
    return self;
}

//- (BOOL)updaterShouldRelaunchApplication:(SUUpdater *)updater
//{
//    DDLogVerbose(@"updaterShouldRelaunchApplication");
//    return YES;
//}

- (void)updaterWillRelaunchApplication:(SUUpdater *)updater
{
    DDLogVerbose(@"updaterWillRelaunchApplication");
}

//- (BOOL)updater:(SUUpdater *)updater shouldPostponeRelaunchForUpdate:(SUAppcastItem *)update untilInvoking:(NSInvocation *)invocation
//{
//    DDLogVerbose(@"shouldPostponeRelaunchForUpdate");
//    return NO;
//}

// Returns the path which is used to relaunch the client after the update is installed. By default, the path of the host bundle.
- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater
{
    DDLogVerbose(@"pathToRelaunchForUpdater:%@",[[NSBundle mainBundle] bundlePath]);
    return [[NSBundle mainBundle] bundlePath];
}

@end

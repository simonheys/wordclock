//
//  iphone_word_clockAppDelegate.m
//  iphone_word_clock
//
//  Created by Simon on 21/07/2008.
//  Copyright Simon Heys 2008. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate ()
//@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *rootViewController;
@end

@implementation AppDelegate

- (void)dealloc {
    [_rootViewController release];
	[_window release];
	[super dealloc];
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];

	return YES;
}

- (RootViewController *)rootViewController {
	if ( nil == _rootViewController ) {
		_rootViewController = [RootViewController new];
	}
	
	return _rootViewController;
}

@end

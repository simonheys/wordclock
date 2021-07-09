//
//  RootViewController.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize wordClockViewController;
@synthesize flipsideViewController;



- (void)viewDidLoad 
{
	DLog(@"viewDidLoad");

	_startingUp = YES;

	WordClockViewController *viewController = [[WordClockViewController alloc] initWithNibName:@"WordClockView" bundle:nil];

	self.wordClockViewController = viewController;
	self.wordClockViewController.delegate = self;
//	[self.wordClockViewController beginParsing];
	[self.wordClockViewController updateFromPreferences];
	
	BOOL isRunningOnPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	if ( isRunningOnPad ) {
		startupImage.alpha = 0;
	}
	
	_mainView = self.wordClockViewController.view;
	[_mainView retain];

//	1. start with clock
	[self.view addSubview:viewController.view];
	[viewController release];
	
//	2. start with prefs - remember you also need to change the frame code in FlipsideViewController.m
//	[self loadFlipsideViewController];
//	[self.view addSubview:flipsideViewController.view];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(configSelected:)
		name:kWordClockViewControlsConfigSelected object:nil];

/*
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(flipsideViewDone:)
		name:@"FlipsideViewDone" object:nil];
*/

	[super viewDidLoad];
}

- (void)wordClockDidCompleteParsing:(WordClockViewController*)controller
{
	if ( _startingUp ) {
		CGAffineTransform transform;
		transform = CGAffineTransformMakeScale(0.9f, 0.9f);
		[UIView beginAnimations:@"init" context:NULL];
		[UIView setAnimationDuration:0.25];
		[startupImage setAlpha:0.0f];
		[startupImage setTransform:transform];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(startupImageFinishedFadingOut:finished:context:)];
		[UIView commitAnimations];
		[self.wordClockViewController begin];
	}
	else {
		//FIXME this is a little nasty
	DLog(@"skipping wordClockViewController start");
//		[self.wordClockViewController start];
	}
}

-(void)startupImageFinishedFadingOut:(NSString*) animationID
							finished:(NSNumber*) finished
							 context:(void*) context {
	DLog(@"startupImageFinishedFadingOut:%@",animationID);
	if ( [animationID isEqualToString:@"init" ] ) {
		[self.wordClockViewController appear];
		_startingUp = NO;
	}
}	

-(void)configSelected:(NSNotification *)notification
{
	DLog(@"configSelected");
//	[self toggleView];
	[self showInfo];
}

/*
// short delay allows the flipside to redraw
-(void)flipsideViewDone:(NSNotification *)notification
{
	DLog(@"flipsideViewDone");
//	[self performSelector:@selector(toggleView) withObject:nil afterDelay:0.05f];
//	[self toggleView];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
//	return NO;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}





- (void)loadFlipsideViewController {
	FlipsideViewController *viewController = [[FlipsideViewController alloc] initWithNibName:nil bundle:nil];
	self.flipsideViewController = viewController;
	[viewController release];
}

/*
// delays in this method allow each view time to redraw before view is flipped
- (IBAction)toggleView {	
	UIView *mainView = mainViewController.view;

	if (flipsideViewController == nil) {
		[self loadFlipsideViewController];
	}	
	
	if ([mainView superview] != nil) {
		[flipsideViewController viewWillAppear:YES]; // tell it to get ready
		[self performSelector:@selector(flipToFlipside) withObject:nil afterDelay:0.05f];
	} else {
		[self performSelector:@selector(flipToMain) withObject:nil afterDelay:0.05f];
//		[self flipToMain];
	}
}

- (void)flipToMain
{
	UIView *mainView = mainViewController.view;
	UIView *flipsideView = flipsideViewController.view;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];

	//FIXME this is a little nasty
	[self.mainViewController start];

	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	[self.mainViewController viewWillAppear:YES];
	[flipsideViewController viewWillDisappear:YES];
	[flipsideView removeFromSuperview];
	[self.view addSubview:mainView];
	[flipsideViewController viewDidDisappear:YES];
	[self.mainViewController viewDidAppear:YES];
	[UIView commitAnimations];
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];

}
- (void)flipToFlipside
{
	UIView *mainView = mainViewController.view;
	UIView *flipsideView = flipsideViewController.view;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];

	//FIXME this is a little nasty
	[self.mainViewController stop];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
//		[flipsideViewController viewWillAppear:YES];
	[self.mainViewController viewWillDisappear:YES];
	[mainView removeFromSuperview];
	[self.view addSubview:flipsideView];
	[self.mainViewController viewDidDisappear:YES];
	[flipsideViewController viewDidAppear:YES];
	
	[UIView commitAnimations];
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
}
*/

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller 
{
    
	[self.wordClockViewController updateFromPreferences];
	[self.wordClockViewController predrawView];
	[self.wordClockViewController start];

//	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation: UIStatusBarAnimationFade];
	[self dismissModalViewControllerAnimated:YES];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}


- (IBAction)showInfo {
	[self.wordClockViewController stop];
//	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
//	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:nil bundle:nil];
//	controller.delegate = self;
	
//	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//	[self presentModalViewController:controller animated:YES];
	
//	[controller release];

	if (flipsideViewController == nil) {
		[self loadFlipsideViewController];
		flipsideViewController.delegate = self;
		flipsideViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;// UIModalTransitionStyleFlipHorizontal;// UIModalTransitionStylePartialCurl; // UIModalTransitionStyleCoverVertical;// UIModalTransitionStyleFlipHorizontal;
	}	
//	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[flipsideViewController viewWillAppear:YES]; // tell it to get ready

	[self presentModalViewController:flipsideViewController animated:YES];

	//[self performSelector:@selector(doTheFlipThing) withObject:nil afterDelay:1.0f];

}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	DLog(@"*******VIEW DID UNLOAD*********");
}

+(float)getScale
{
	UIScreen* screen = [UIScreen mainScreen];
	return [screen respondsToSelector:@selector(scale)] ? screen.scale : 1;
}

@end

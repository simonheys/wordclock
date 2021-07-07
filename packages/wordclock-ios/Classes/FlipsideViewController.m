//
//  FlipsideViewController.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "FlipsideViewController.h"

//@synthesize myTableViewController, mySecondTableViewController;



@implementation FlipsideViewController
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	NSLog(@"FlipsideViewController:initWithNibName");
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	DLog(@"shouldAutorotateToInterfaceOrientation");
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}


@synthesize delegate;


- (void)viewDidLoad {
	DLog(@"viewDidLoad");
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];		

//	CGRect screenBounds = [[UIScreen mainScreen] bounds];
//	self.view.frame = screenBounds;

/*
	[self.view setAutoresizingMask:
		UIViewAutoresizingFlexibleHeight|
		UIViewAutoresizingFlexibleWidth|
		UIViewAutoresizingFlexibleRightMargin|
		UIViewAutoresizingFlexibleBottomMargin|
		UIViewAutoresizingFlexibleTopMargin
	];

*/


	_tabBarController = [[UITabBarController alloc] init];
	
	/*
	_tabBarController.view.frame = CGRectMake(
		0, 
		[UIApplication sharedApplication].statusBarFrame.size.height, 
		[UIApplication sharedApplication].keyWindow.bounds.size.width, 
		[UIApplication sharedApplication].keyWindow.bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height
	);
	*/
//	self.view.frame = CGRectMake(
//		0, 
//		0, 
//		[UIApplication sharedApplication].keyWindow.bounds.size.width, 
//		[UIApplication sharedApplication].keyWindow.bounds.size.height	
//	);
//	

	WordsTabViewController *wordsTabViewController = [[WordsTabViewController alloc] init];
	UINavigationController *wordsNavController = [[[UINavigationController alloc] initWithRootViewController:wordsTabViewController] autorelease];
	wordsNavController.navigationBar.barStyle = UIBarStyleBlack;
	[wordsTabViewController release];

	FontTabViewController *fontTabViewController = [[FontTabViewController alloc] init];
	UINavigationController *fontNavController = [[[UINavigationController alloc] initWithRootViewController:fontTabViewController] autorelease];
	fontNavController.navigationBar.barStyle = UIBarStyleBlack;
	[fontTabViewController release];

	TypographyTabViewController *typographyTabViewController = [
		[TypographyTabViewController alloc] 
		initWithNibName:@"FlipsideTypographyView" 
		bundle:nil
	];
	
	UINavigationController *typographyNavController = [[[UINavigationController alloc] initWithRootViewController:typographyTabViewController] autorelease];
	typographyNavController.navigationBar.barStyle = UIBarStyleBlack; 
		[typographyTabViewController release];

	FlipsideColourPickerViewController *colourTabViewController = [
		[FlipsideColourPickerViewController alloc] 
		initWithNibName:@"FlipsideColourPickerView" 
		bundle:nil
	];
	
	UINavigationController *colourNavController = [[[UINavigationController alloc] initWithRootViewController:colourTabViewController] autorelease];
	colourNavController.navigationBar.barStyle = UIBarStyleBlack;
	[colourTabViewController release];
	
	/*
	AboutTabViewController *aboutTabViewController = [[AboutTabViewController alloc] initWithNibName:@"FlipsideAboutView" bundle:nil];
	UINavigationController *aboutNavController = [[[UINavigationController alloc] initWithRootViewController:aboutTabViewController] autorelease];
	//table4NavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	aboutNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[aboutTabViewController release];
*/

	_tabBarController.viewControllers = [NSArray arrayWithObjects:
		typographyNavController, 
		wordsNavController, 
		fontNavController, 
		colourNavController, 
		/*
		aboutNavController, 
		*/
		nil
	];
	_tabBarController.delegate = self;
	
	_currentSelectedViewController = [_tabBarController.viewControllers objectAtIndex:0];
//	[_currentSelectedViewController viewWillAppear:NO];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(flipsideViewDone:)
		name:@"FlipsideViewDone" object:nil];

	self.view.backgroundColor = [UIColor blackColor];
	
//	if (!isRunningOnPad) {
		_gradientBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flipside_background.png"]];
    CGRect f;
    f = _gradientBackground.frame;
    f.size.width = self.view.bounds.size.width;
    _gradientBackground.frame = f;
    _gradientBackground.contentMode = UIViewContentModeTopLeft;
    _gradientBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//		_gradientBackground.center = CGPointMake(CGRectGetMidX(screenBounds), 480.0f/2-11);//+9
//	}
	[self.view addSubview:_gradientBackground];

_tabBarController.view.frame = self.view.bounds;
_tabBarController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_tabBarController.view];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UINavigationController *n = (UINavigationController *)_currentSelectedViewController;
    CGRect f = n.navigationBar.frame;
    f.size.height = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 32.0f : 44.0f;
    n.navigationBar.frame = f;
}

- (void)viewWillAppear:(BOOL)animated
{
	DLog(@"viewWillAppear");
	DLog(@"_currentSelectedViewController:%@",_currentSelectedViewController);
	[_currentSelectedViewController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	DLog(@"viewWillDisappear");
	[_currentSelectedViewController viewWillDisappear:animated];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	DLog(@"didSelectViewController:%@",tabBarController.selectedViewController);
	DLog(@"_currentSelectedViewController:%@",_currentSelectedViewController);
	[_currentSelectedViewController viewWillDisappear:NO];
	_currentSelectedViewController = tabBarController.selectedViewController;
	[_currentSelectedViewController viewWillAppear:NO];
}

-(void)flipsideViewDone:(NSNotification *)notification
{
	DLog(@"doneSelected");
	[_currentSelectedViewController viewWillDisappear:NO];   
	[self.delegate flipsideViewControllerDidFinish:self];	
}


/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */




- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[_gradientBackground release];
	[super dealloc];
}


@end

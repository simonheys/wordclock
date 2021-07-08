//
//  FlipsideViewController.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "FlipsideViewController.h"

//@synthesize myTableViewController, mySecondTableViewController;

@interface FlipsideViewController ()
@property (nonatomic, strong) UIViewController *currentSelectedViewController;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) UIImageView *gradientBackground;
@end

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


	self.tabBarController = [[UITabBarController alloc] init];
	
	/*
	self.tabBarController.view.frame = CGRectMake(
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
	UINavigationController *wordsNavController = [[UINavigationController alloc] initWithRootViewController:wordsTabViewController];
	wordsNavController.navigationBar.barStyle = UIBarStyleBlack;

	FontTabViewController *fontTabViewController = [[FontTabViewController alloc] init];
	UINavigationController *fontNavController = [[UINavigationController alloc] initWithRootViewController:fontTabViewController];
	fontNavController.navigationBar.barStyle = UIBarStyleBlack;

	TypographyTabViewController *typographyTabViewController = [
		[TypographyTabViewController alloc] 
		initWithNibName:@"FlipsideTypographyView" 
		bundle:nil
	];
	
	UINavigationController *typographyNavController = [[UINavigationController alloc] initWithRootViewController:typographyTabViewController];
	typographyNavController.navigationBar.barStyle = UIBarStyleBlack;

	FlipsideColourPickerViewController *colourTabViewController = [
		[FlipsideColourPickerViewController alloc] 
		initWithNibName:@"FlipsideColourPickerView" 
		bundle:nil
	];
	
	UINavigationController *colourNavController = [[UINavigationController alloc] initWithRootViewController:colourTabViewController];
	colourNavController.navigationBar.barStyle = UIBarStyleBlack;
	
	/*
	AboutTabViewController *aboutTabViewController = [[AboutTabViewController alloc] initWithNibName:@"FlipsideAboutView" bundle:nil];
	UINavigationController *aboutNavController = [[[UINavigationController alloc] initWithRootViewController:aboutTabViewController] autorelease];
	//table4NavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	aboutNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[aboutTabViewController release];
*/

	self.tabBarController.viewControllers = @[
		typographyNavController,
		wordsNavController,
		fontNavController, 
		colourNavController,
		/*
		aboutNavController, 
		*/
	];
	self.tabBarController.delegate = self;
	
	self.currentSelectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
//	[self.currentSelectedViewController viewWillAppear:NO];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(flipsideViewDone:)
		name:@"FlipsideViewDone" object:nil];

	self.view.backgroundColor = [UIColor blackColor];
	
//	if (!isRunningOnPad) {
	self.gradientBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flipside_background.png"]];
    CGRect f;
    f = self.gradientBackground.frame;
    f.size.width = self.view.bounds.size.width;
    self.gradientBackground.frame = f;
    self.gradientBackground.contentMode = UIViewContentModeTopLeft;
    self.gradientBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//		self.gradientBackground.center = CGPointMake(CGRectGetMidX(screenBounds), 480.0f/2-11);//+9
//	}
	[self.view addSubview:self.gradientBackground];

    self.tabBarController.view.frame = self.view.bounds;
    self.tabBarController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:self.tabBarController.view];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UINavigationController *n = (UINavigationController *)self.currentSelectedViewController;
    CGRect f = n.navigationBar.frame;
    f.size.height = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 32.0f : 44.0f;
    n.navigationBar.frame = f;
}

- (void)viewWillAppear:(BOOL)animated
{
	DLog(@"viewWillAppear");
	DLog(@"self.currentSelectedViewController:%@",self.currentSelectedViewController);
	[self.currentSelectedViewController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	DLog(@"viewWillDisappear");
	[self.currentSelectedViewController viewWillDisappear:animated];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	DLog(@"didSelectViewController:%@",tabBarController.selectedViewController);
	DLog(@"self.currentSelectedViewController:%@",self.currentSelectedViewController);
	[self.currentSelectedViewController viewWillDisappear:NO];
	self.currentSelectedViewController = tabBarController.selectedViewController;
	[self.currentSelectedViewController viewWillAppear:NO];
}

-(void)flipsideViewDone:(NSNotification *)notification
{
	DLog(@"doneSelected");
	[self.currentSelectedViewController viewWillDisappear:NO];
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





@end

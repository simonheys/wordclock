//
//  UITableViewControllerBlack.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "UITableViewControllerBlack.h"


@implementation UITableViewControllerBlack

@synthesize loadingViewController;

- (instancetype)init {
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_accessorySelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_accessory_checked.png"]];
		[_accessorySelected retain];
        _doneButton = [[UIBarButtonItem alloc] 
			initWithTitle:@"Done" 
			style:UIBarButtonItemStyleDone
			target:self 
			action:@selector(doneSelected)
		];
        self.navigationItem.rightBarButtonItem = _doneButton;
		_activityIndicator = [[UIActivityIndicatorView alloc] 
			initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite
		];
        _activityButton = [[UIBarButtonItem alloc] 
			initWithCustomView:_activityIndicator
		];
		_loading = NO;
	}
	return self;
}

- (void)viewDidLoad
{
	DLog(@"viewDidLoad");
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor colorWithWhite:0.3f alpha:0.5f];
//	self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.scrollEnabled = NO;		
	[self setLoading:YES];	
}

- (id)initWithStyle:(UITableViewStyle)style
{
	DLog(@"initWithStyle");
	if (self = [super initWithStyle:style]) {
		self.tableView.backgroundColor = [UIColor clearColor];
		self.tableView.separatorColor = [UIColor colorWithWhite:0.3f alpha:0.5f];
//		self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		self.tableView.showsVerticalScrollIndicator = NO;
			self.tableView.scrollEnabled = NO;		
	}
	return self;
}

- (void)dealloc {
	[_accessorySelected release];
	[_activityIndicator release];
	[_activityButton release];	
    [super dealloc];
}


// ____________________________________________________________________________________________________ Activity indiciator

-(void)loadLoadingViewController
{
	DLog(@"loadLoadingViewController");
	BOOL isRunningOnPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	TableLoadingViewController *viewController = [
		[TableLoadingViewController alloc] 
		initWithNibName:@"TableLoadingView"
		bundle:nil
	];
	self.loadingViewController = viewController;
    self.loadingViewController.view.frame = self.view.bounds;
    self.loadingViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[viewController release];
}

-(void)setLoading:(BOOL)value
{
	DLog(@"setLoading:%@",value ? @"YES" : @"NO");
	if ( _loading == value ) {
	//	return;
	}
	if ( value ) {
		self.tableView.showsVerticalScrollIndicator = NO;
		if ( self.loadingViewController == nil ) {
			[self loadLoadingViewController];
		}
	//	[self.navigationController pushViewController:self.loadingViewController animated:NO];
		self.tableView.tableHeaderView = self.loadingViewController.view;
	}
	else {
		if ( self.loadingViewController != nil ) {
			//[self.navigationController popToViewController:self animated:NO];
			self.tableView.tableHeaderView = nil;
			self.tableView.showsVerticalScrollIndicator = YES;
			self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
			self.tableView.scrollEnabled = YES;		
		}
	}
	_loading = value;
}

// ____________________________________________________________________________________________________ Header

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
	UIView *headerView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"table_header_background.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0]];
	headerView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 20);
	[headerView autorelease];
	
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, tableView.bounds.size.width-10, 20)] autorelease];
	label.textAlignment = UITextAlignmentLeft;
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
	label.backgroundColor = [UIColor clearColor];
	label.opaque = NO;
	label.text = [self tableView:tableView titleForHeaderInSection:section];//NSLocalizedString(@"my-header-title",@"");

	[headerView addSubview:label];
	return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
		cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
	}

	return cell;
}



-(void)setActivity:(BOOL)value
{
	if ( value ) {
		[_activityIndicator startAnimating];
		self.navigationItem.rightBarButtonItem = _activityButton;
	}
	else {
		[_activityIndicator stopAnimating];	
        self.navigationItem.rightBarButtonItem = _doneButton;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	DLog(@"viewWillAppear");
	[self setActivity:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	DLog(@"viewWillDisappear");
//	[self performSelector:@selector(setActivity:) withObject:NO afterDelay:0.1f];
}

-(IBAction)doneSelected 
{
	DLog(@"doneSelected");
	[self setActivity:YES];
//	[self postDoneNotification];
	[self performSelector:@selector(postDoneNotification) withObject:nil afterDelay:0.05f];
}

-(void)postDoneNotification
{
 	[[NSNotificationCenter defaultCenter] postNotificationName:@"FlipsideViewDone" object:self];
}

@end

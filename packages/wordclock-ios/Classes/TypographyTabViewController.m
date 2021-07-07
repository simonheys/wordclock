//
//  ThirdTabViewController.m
//  iphone_word_clock
//
//  Created by Simon on 17/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TypographyTabViewController.h"

@interface TypographyTabViewController (TypographyTabViewControllerPrivate)
@end

@implementation TypographyTabViewController

- (void)dealloc
{
    [_wrapperView release];
    [_preview release];
    [_scrollView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [_wrapperView release];
    _wrapperView = nil;
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
        self.title = NSLocalizedString(@"Typography", @"");
		self.tabBarItem.image = [UIImage imageNamed:@"typography.png"];
        UIBarButtonItem *anotherButton = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone
             target:self action:@selector(doneSelected)] autorelease];
        self.navigationItem.rightBarButtonItem = anotherButton;
	}
	return self;
}

- (void)viewDidLoad 
{
	BOOL isRunningOnPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

	[leadingSlider setValue:[WordClockPreferences sharedInstance].leading];
	[trackingSlider setValue:[WordClockPreferences sharedInstance].tracking];	
	
	switch ( [WordClockPreferences sharedInstance].justification  ) {
		case WCJustificationLeft:
			justifyControl.selectedSegmentIndex = 0;
			break;
		case WCJustificationCentre:
			justifyControl.selectedSegmentIndex = 1;
			break;
		case WCJustificationRight:
			justifyControl.selectedSegmentIndex = 2;
			break;
		case WCJustificationFull:
			justifyControl.selectedSegmentIndex = 3;
			break;
	}
	
	switch ( [WordClockPreferences sharedInstance].caseAdjustment  ) {
		case WCCaseAdjustmentNone:
			caseControl.selectedSegmentIndex = 0;
			break;
		case WCCaseAdjustmentUpper:
			caseControl.selectedSegmentIndex = 1;
			break;
		case WCCaseAdjustmentLower:
			caseControl.selectedSegmentIndex = 2;
			break;
	}
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	_preview = [[ShowableWordClockPreview alloc] initWithFrame:CGRectMake(
        roundf(0.5f*(self.view.bounds.size.width-240)),
        roundf(0.5f*(self.view.bounds.size.height-240)),
        240,
        240
    )];
	[self.view addSubview:_preview];
    _preview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    if ( isRunningOnPad ) {
        self.wrapperView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    }
    else {
         self.wrapperView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = self.wrapperView.bounds.size;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (IBAction)justifyChanged
{
	switch ( justifyControl.selectedSegmentIndex ) {
		case 0:
			[WordClockPreferences sharedInstance].justification = WCJustificationLeft;	
			break;
		case 1:
			[WordClockPreferences sharedInstance].justification = WCJustificationCentre;	
			break;
		case 2:
			[WordClockPreferences sharedInstance].justification = WCJustificationRight;	
			break;
		case 3:
			[WordClockPreferences sharedInstance].justification = WCJustificationFull;	
			break;
	}
}

- (IBAction)caseChanged
{
	switch ( caseControl.selectedSegmentIndex ) {
		case 0:
			[WordClockPreferences sharedInstance].caseAdjustment = WCCaseAdjustmentNone;	
			break;
		case 1:
			[WordClockPreferences sharedInstance].caseAdjustment = WCCaseAdjustmentUpper;	
			break;
		case 2:
			[WordClockPreferences sharedInstance].caseAdjustment = WCCaseAdjustmentLower;	
			break;
	}
}

- (IBAction)trackingChanged
{
	_preview.tracking = [trackingSlider value];	
}

- (IBAction)trackingChangeFinished
{
	[_preview setShowing:NO];
	DLog(@"trackingChangeFinished");
	[WordClockPreferences sharedInstance].tracking = [trackingSlider value];	
}

- (IBAction)trackingChangeStarted
{
	[_preview setShowing:YES];
}

- (IBAction)leadingChanged
{
	//[WordClockPreferences sharedInstance].leading = [leadingSlider value];		
	_preview.leading = [leadingSlider value];	
}

- (IBAction)leadingChangeFinished
{
	[_preview setShowing:NO];
	DLog(@"leadingChangeFinished");
	[WordClockPreferences sharedInstance].leading = [leadingSlider value];		
}

- (IBAction)leadingChangeStarted
{
	[_preview setShowing:YES];
}


@end

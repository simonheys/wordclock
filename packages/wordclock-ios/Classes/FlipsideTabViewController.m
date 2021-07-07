//
//  FlipsideTabViewController.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "FlipsideTabViewController.h"

@implementation FlipsideTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _doneButton = [[UIBarButtonItem alloc] 
			initWithTitle:NSLocalizedString(@"Done", @"")
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
	}
	return self;
}

- (void) dealloc
{
	[_doneButton release];
	[_activityIndicator release];
	[_activityButton release];	
	[super dealloc];
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
	DLog(@"donSelected. I am:%@",self);
	[self setActivity:YES];
//	[self postDoneNotification];
	[self performSelector:@selector(postDoneNotification) withObject:nil afterDelay:0.05f];
}

-(void)postDoneNotification
{
//	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
 	[[NSNotificationCenter defaultCenter] postNotificationName:@"FlipsideViewDone" object:self];
//	[apool release];
}

@end

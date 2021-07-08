//
//  FlipsideTabViewController.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "FlipsideTabViewController.h"

@interface FlipsideTabViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIBarButtonItem *activityButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@end

@implementation FlipsideTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.doneButton = [[UIBarButtonItem alloc]
			initWithTitle:NSLocalizedString(@"Done", @"")
			style:UIBarButtonItemStyleDone
			target:self 
			action:@selector(doneSelected)
		];
        self.navigationItem.rightBarButtonItem = self.doneButton;
		self.activityIndicator = [[UIActivityIndicatorView alloc]
			initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium
		];
        self.activityButton = [[UIBarButtonItem alloc]
			initWithCustomView:self.activityIndicator
		];
	}
	return self;
}

-(void)setActivity:(BOOL)value
{
	if ( value ) {
		[self.activityIndicator startAnimating];
		self.navigationItem.rightBarButtonItem = self.activityButton;
	}
	else {
		[self.activityIndicator stopAnimating];
        self.navigationItem.rightBarButtonItem = self.doneButton;
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

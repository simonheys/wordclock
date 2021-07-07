//
//  FifthTabViewController.m
//  iphone_word_clock
//
//  Created by Simon on 07/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AboutTabViewController.h"


@implementation AboutTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = NSLocalizedString(@"About", @"");
		self.tabBarItem.image = [UIImage imageNamed:@"about.png"];
	}
	return self;
}

-(void)viewDidLoad
{
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	NSString *swfFile= [thisBundle pathForResource:@"about" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:swfFile];
	_webView.delegate = self;
	_webView.opaque = NO;
	_webView.backgroundColor = [UIColor clearColor];
	
	NSMutableString *documentString;
	documentString = [[NSMutableString alloc] initWithContentsOfURL:url];// initWithContentsOfFile:@"about.html"];
	
	
	[documentString 
		replaceOccurrencesOfString:@"{$VERSION}" 
		withString:[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] 
		options:NSCaseInsensitiveSearch 
		range:NSMakeRange(0, [documentString length]) 
	];
	
	[documentString 
		replaceOccurrencesOfString:@"{$BUILD}" 
		withString:[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] 
		options:NSCaseInsensitiveSearch 
		range:NSMakeRange(0, [documentString length]) 
	];

	DLog(@"documentString:%@",documentString);
	
	[_webView loadHTMLString:documentString baseURL:url];
	
//	[_webView loadHTMLString:documentString baseURL:@"https://www.simonheys.com/"];
	//[_webView loadRequest:[NSURLRequest requestWithURL:url]];	
	[documentString release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	DLog(@"webView shouldStartLoadWithRequest: %@",request);
	
	//if ( [request 
	if ( ![[request URL] isFileURL] ) {
		[[UIApplication sharedApplication] openURL:[request URL]];
	}
	return YES;
}
@end

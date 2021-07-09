//
//  AboutTabViewController.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "AboutTabViewController.h"


@implementation AboutTabViewController

- (instancetype)init {
    return [self initWithNibName:nil bundle:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

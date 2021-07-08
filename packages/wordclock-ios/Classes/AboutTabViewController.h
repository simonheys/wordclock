//
//  AboutTabViewController.h
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLog.h"

#import "FlipsideTabViewController.h"

@interface AboutTabViewController : FlipsideTabViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *_webView;
}

@end

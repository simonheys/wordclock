//
//  AboutTabViewController.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLog.h"

#import "FlipsideTabViewController.h"

@interface AboutTabViewController : FlipsideTabViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *_webView;
}

@end

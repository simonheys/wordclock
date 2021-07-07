//
//  FifthTabViewController.h
//  iphone_word_clock
//
//  Created by Simon on 07/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLog.h"

#import "FlipsideTabViewController.h"

@interface AboutTabViewController : FlipsideTabViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *_webView;
}

@end

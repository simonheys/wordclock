//
//  main.m
//  iphone_word_clock
//
//  Created by Simon on 21/07/2008.
//  Copyright Simon Heys 2008. All rights reserved.
//

// rm -rf build/ ; scan-build --view xcodebuild

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
	[pool release];
	return retVal;
}

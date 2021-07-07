//
//  main.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

// rm -rf build/ ; scan-build --view xcodebuild

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
	[pool release];
	return retVal;
}

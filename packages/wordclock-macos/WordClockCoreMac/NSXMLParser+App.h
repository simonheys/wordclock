//
//  NSXMLParser+App.h
//  WordClock macOS
//
//  Created by Simon Heys on 07/10/2014.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSXMLParser (App)
+ (dispatch_queue_t)sharedQueue;
@end

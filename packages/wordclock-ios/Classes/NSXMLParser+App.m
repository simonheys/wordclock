//
//  NSXMLParser+App.m
//  WordClock
//
//  Created by Simon Heys on 07/10/2014.
//
//

#import "NSXMLParser+App.h"

@implementation NSXMLParser (App)

+ (dispatch_queue_t)sharedQueue
{
    static dispatch_once_t once;
    static dispatch_queue_t _sharedQueue;
    dispatch_once(&once, ^{
        _sharedQueue = dispatch_queue_create("NSXMLParserSharedSerialQueue", DISPATCH_QUEUE_SERIAL);
    });
    return _sharedQueue;
}

@end

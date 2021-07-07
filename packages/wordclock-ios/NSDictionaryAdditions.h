//
//  NSDictionaryAdditions.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 19/04/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSDictionary (NSDictionaryAdditions)

-(NSString *)stringForKey:(NSString *)defaultName;
-(BOOL)boolForKey:(NSString *)defaultName;
-(float)floatForKey:(NSString *)defaultName;

@end

//
//  WordClockWordsFileParser.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockWordsFileParser.h"

@interface WordClockWordsFileParser ()
@property (nonatomic, retain) NSMutableArray *logic;
@property (nonatomic, retain) NSMutableArray *label;
@end

@implementation WordClockWordsFileParser

// ____________________________________________________________________________________________________ delloc

- (void)dealloc
{
    [_logic release];
    [_label release];
	[super dealloc];
}

-(void)parseFile:(NSString *)pathToFile
{  
	self.logic = [[NSMutableArray new] autorelease];
	self.label = [[NSMutableArray new] autorelease];
 
    NSData *data = [NSData dataWithContentsOfFile:pathToFile];
    NSError *error = nil;
    id model = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
 	NSArray *groups = model[@"groups"];
    [groups enumerateObjectsUsingBlock:^(NSArray *group, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *groupLogic = [NSMutableArray new];
        NSMutableArray *groupLabel = [NSMutableArray new];
        [group enumerateObjectsUsingBlock:^(NSDictionary *entry, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *type = entry[@"type"];
            if ( [type isEqualToString:@"item"]) {
                NSArray *items = entry[@"items"];
                [items enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *highlight = item[@"highlight"];
                    NSString *text = item[@"text"];
                    [groupLogic addObject:highlight];
                    [groupLabel addObject:text ? text: @""];
                }];
            }
            else if ([type isEqualToString:@"sequence"]) {
                NSString *bind = entry[@"bind"];
                NSUInteger first = [entry[@"first"] unsignedIntegerValue];
                NSArray *textArray = entry[@"text"];
                [textArray enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *highlight = [NSString stringWithFormat:@"%@==%@",bind,@(first+idx)];
                    [groupLogic addObject:highlight];
                    [groupLabel addObject:text];
                }];
            }
            else if ( [type isEqualToString:@"space"]) {
                NSUInteger count = [entry[@"count"] unsignedIntegerValue];
                for ( NSUInteger i = 0; i < count; i++ ) {
                    [groupLogic addObject:@""];
                    [groupLabel addObject:@""];
                }
            }
        }];
        [self.logic addObject:groupLogic];
        [self.label addObject:groupLabel];
    }];
  
    if ([self.delegate respondsToSelector:@selector(wordClockWordsFileParserDidCompleteParsing:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate wordClockWordsFileParserDidCompleteParsing:self];
        });
	}
}

@end

//
//  Scene.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "Scene.h"

#import "LogicParser.h"
#import "WordClockWordManager.h"

@interface Scene ()
@property(nonatomic) CGFloat scale;
@end

@implementation Scene

@synthesize wordClockWordManager = _wordClockWordManager;
@synthesize scale = _scale;

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [_wordClockWordManager release];
    [super dealloc];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _previousSecond = -1;
    }
    return self;
}

- (void)advanceTimeBy:(float)seconds {
    //	DDLogVerbose(@"advance time by:");
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];

    NSInteger second = [dateComponents second];

    [calendar release];

    if (second != _previousSecond) {
        NSInteger twentyfourhour = [dateComponents hour];
        NSInteger hour = twentyfourhour % 12;
        if (hour == 0) {
            hour = 12;
        }

        NSInteger minute = [dateComponents minute];

#ifdef DEMO_TIME
        hour = 9;
        minute = 41;
#endif

        [LogicParser sharedInstance].hour = hour;
        [LogicParser sharedInstance].twentyfourhour = twentyfourhour;
        [LogicParser sharedInstance].minute = minute;
        [LogicParser sharedInstance].second = second;
        [LogicParser sharedInstance].day = [dateComponents weekday] - 1;  //-1 for compatibility with flash d.getDay();
        // DDLogVerbose(@"day:%d",[LogicParser sharedInstance].day);
        [LogicParser sharedInstance].date = [dateComponents day];         // d.getDate();
        [LogicParser sharedInstance].month = [dateComponents month] - 1;  //-1 for compatibility with flash d.getMonth();
        //[(WordClockRenderView *)self.view highlightForCurrentTime];
        [self.wordClockWordManager highlightForCurrentTime];
        _previousSecond = second;
    }
}

- (void)setViewportRect:(NSRect)bounds {
    self.scale = bounds.size.width / [[NSScreen mainScreen] visibleFrame].size.width;
}

@end

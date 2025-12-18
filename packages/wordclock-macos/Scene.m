//
//  Scene.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "Scene.h"

#import <OpenGL/gl.h>

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
        //[(WordClockGLView *)self.view highlightForCurrentTime];
        [self.wordClockWordManager highlightForCurrentTime];
        _previousSecond = second;
    }
}

- (void)render {
    //    glClearColor(0, 0, 1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    /*
    static const GLfloat squareVertices[] = {
        -50.0f,  -50.0f,
         50.0f,  -50.0f,
        -50.0f,   50.0f,
         50.0f,   50.0f,
    };

    static const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
  //    glEnableClientState(GL_VERTEX_ARRAY);
  //    glEnableClientState(GL_COLOR_ARRAY);

    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    */

    //	glMatrixMode(GL_COLOR); glLoadIdentity();
}

- (void)setViewportRect:(NSRect)bounds {
    self.scale = bounds.size.width / [[NSScreen mainScreen] visibleFrame].size.width;

    glViewport(0, 0, bounds.size.width, bounds.size.height);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    //    gluPerspective(30, bounds.size.width / bounds.size.height, 1.0,
    //    1000.0);
    //	glMatrixMode(GL_MODELVIEW);

    glOrtho(-bounds.size.width / 2, bounds.size.width / 2, bounds.size.height / 2, -bounds.size.height / 2, -1.0f, 1.0f);

    //	glEnable(GL_COLOR_ARRAY);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glScalef(self.scale, self.scale, 1.0f);

    glDisable(GL_DEPTH_TEST);
    glDisable(GL_FOG);
    glDisable(GL_LIGHTING);
    glDisable(GL_ALPHA_TEST);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnable(GL_TEXTURE_2D);

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    // test test
    glShadeModel(GL_FLAT);
    //	glEnable (GL_MULTISAMPLE_ARB);
    //	glHint (GL_MULTISAMPLE_FILTER_HINT_NV, GL_NICEST);

    // test test

    // allow alhpa, but has noise artifacts
    //    glEnable( GL_BLEND );
    //    glBlendEquation( GL_FUNC_ADD );
    //    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

    //	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //    glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //	glBlendFunc(GL_SRC_COLOR, GL_DST_ALPHA);
    //	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_DST_ALPHA);

    //	glEnable( GL_COLOR_MATERIAL );
    //

    //	glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
}

@end

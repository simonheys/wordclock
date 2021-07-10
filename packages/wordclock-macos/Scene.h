//
//  Scene.h
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

@class WordClockWordManager;

@interface Scene : NSObject {
@private
	NSInteger _previousSecond;
    WordClockWordManager *_wordClockWordManager;
    CGFloat _scale;
}

- (void)setViewportRect:(NSRect)bounds;
- (void)render;
- (void)advanceTimeBy:(float)seconds;

@property (nonatomic, retain) WordClockWordManager *wordClockWordManager;
@property (nonatomic, readonly) CGFloat scale;
@end

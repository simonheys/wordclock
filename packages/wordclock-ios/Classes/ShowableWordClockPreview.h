//
//  ShowableWordClockPreview.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 11/03/2009.
//  Copyright 2009 Simon Heys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordClockPreview.h"
#import "image_utilities.h"

@interface ShowableWordClockPreview : WordClockPreview {
@private
	BOOL _showing;
	NSTimer *_statusTimer;
	Tween *_visibilityTween;
	CGImageRef _maskImage;
	CGContextRef _bufferImageRef;
	UIImage *_shadow;
	float _contentScale;
}
- (void)setShowing:(BOOL)visible;
- (CGImageRef) createCircularMaskImageWithWidth:(int)pixelsWide height:(int)pixelsHigh;

@end

//
//  ShowableWordClockPreview.h
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
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

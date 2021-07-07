//
//  LinearCoordinateProvider.h
//  iphone_word_clock_open_gl
//
//  Created by Simon on 15/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoordinateProvider.h"

#define FONT_SIZE_TOLERANCE 0.05


@interface LinearCoordinateProvider : CoordinateProvider 
{
@private
	NSMutableArray *_sizeCache;
	NSMutableArray *_rectCache;

//	float _tracking;
	float _leading;

	float _width;
	float _height;
	float _wordScale;
	float _widthUsedInPreviousUpdate;
	float _heightUsedInPreviousUpdate;
}

@property float width;
@property float height;
@property float wordScale;

@end

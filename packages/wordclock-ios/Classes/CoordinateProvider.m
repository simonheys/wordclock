//
//  CoordinateProvider.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "CoordinateProvider.h"

@interface CoordinateProvider (CoordinateProviderPrivate)
@end

@implementation CoordinateProvider

- (id)init
{
	self = [super init];
	if (self != nil) {
		DLog(@"init");
		[[NSNotificationCenter defaultCenter] 
			addObserver:self
			selector:@selector(numberOfWordsDidChange:)
			name:kWordClockWordManagerNumberOfWordsDidChangeNotification 
			object:nil
		];
		
		[[NSNotificationCenter defaultCenter] 
			addObserver:self
			selector:@selector(texturesDidChange:)
			name:@"kWordClockGLViewTexturesDidChangeNotification" 
			object:nil
		];

		_translateX = 0.0f;
		_translateY = 0.0f;
		_scale = 1.0f;
		
		_orientationVector.vx = 1.0f;
		_orientationVector.vy = 0.0f;
	}
	return self;
}

- (void)numberOfWordsDidChange:(NSNotification *)notification
{
	DLog(@"numberOfWordsDidChange:%@",@([WordClockWordManager sharedInstance].numberOfWords));
	free(_coordinates);
	_coordinates = malloc([WordClockWordManager sharedInstance].numberOfWords * sizeof(WordClockWordCoordinates));
}

- (void)texturesDidChange:(NSNotification *)notification
{
	DLog(@"texturesDidChange");
	[self initialiseNewCoordinates];
}

- (void)initialiseNewCoordinates
{

}

// ____________________________________________________________________________________________________ orientation

- (void)setSize:(CGSize)size
{
    if ( CGSizeEqualToSize(size, _size)) {
        return;
    }
    _size = size;
    [self setupForCurrentSize];
}

- (void)update 
{
	// get words / groups from shared provider
	// [WordClockWordManager sharedInstance].group;
	
	//figure out where they all go
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] 
		removeObserver:self
		name:kWordClockWordManagerNumberOfWordsDidChangeNotification 
		object:nil
	];
	[[NSNotificationCenter defaultCenter] 
		removeObserver:self
		name:@"kWordClockGLViewTexturesDidChangeNotification" 
		object:nil
	];
	[[NSNotificationCenter defaultCenter] 
		removeObserver:self
		name:@"UIDeviceOrientationDidChangeNotification" 
		object:nil
	];

	free(_coordinates);
	[super dealloc];
}

// move everything away from centre
- (void)shake
{
	DLog(@"shake");
	float m;
	int numberOfWords = [WordClockWordManager sharedInstance].numberOfWords;
	for (uint i = 0; i < numberOfWords; i++ ) {
		m = (float) rand() / RAND_MAX;
		_coordinates[i].x *= (4.0+m);
		_coordinates[i].y *= (4.0+m);
		_coordinates[i].r = M_PI * 2 * m;
	}
}

- (CoordinateProvider *)clone
{
	CoordinateProvider *clone = [[CoordinateProvider alloc] init];
	int numberOfWords = [WordClockWordManager sharedInstance].numberOfWords;
	clone.coordinates = malloc(numberOfWords * sizeof(WordClockWordCoordinates));
	for (uint i = 0; i < numberOfWords; i++ ) {
		clone.coordinates[i].x = _coordinates[i].x;
		clone.coordinates[i].y = _coordinates[i].y; 
		clone.coordinates[i].w = _coordinates[i].w;
		clone.coordinates[i].h = _coordinates[i].h;  
		clone.coordinates[i].r = _coordinates[i].r;
		clone.coordinates[i].w_bounds = _coordinates[i].w_bounds;
		clone.coordinates[i].h_bounds = _coordinates[i].h_bounds;
	}
	clone.translateX = _translateX;
	clone.translateY = _translateY;
	clone.scale = _scale;
	
	WordClockOrientationVector v;
	
	v.vx = _orientationVector.vx;
	v.vy = _orientationVector.vy;
	
	clone.orientationVector = v;
	
	return [clone autorelease];
}

@end

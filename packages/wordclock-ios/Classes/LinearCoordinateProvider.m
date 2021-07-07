//
//  LinearCoordinateProvider.m
//  iphone_word_clock_open_gl
//
//  Created by Simon on 15/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LinearCoordinateProvider.h"


static inline NSArray *ArrayFromCGRect(CGRect r)
{
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:r.origin.x],
                                     [NSNumber numberWithFloat:r.origin.y],
                                     [NSNumber numberWithFloat:r.size.width],
                                     [NSNumber numberWithFloat:r.size.height],
                                     nil];
}

static inline CGRect CGRectFromArray(NSArray *a)
{
    return CGRectMake([[a objectAtIndex:0] floatValue],
                      [[a objectAtIndex:1] floatValue],
                      [[a objectAtIndex:2] floatValue],
                      [[a objectAtIndex:3] floatValue]);
}



@interface LinearCoordinateProvider ( LinearCoordinateProviderPrivate )
	-(float)cachedScaleForRect:(CGRect)rect;
	-(void)addCachedScaleForRect:(CGRect)rect size:(float)size;
	-(float)computeScaleForRect:(CGRect)rect;
@end



@implementation LinearCoordinateProvider

- (id) init
{
	self = [super init];
	if (self != nil) {
//		self.width = 320.0f;
//		self.height = 480.0f;
		_wordScale = 1.0f;
		_widthUsedInPreviousUpdate = -1;
		_heightUsedInPreviousUpdate = -1;
		_sizeCache = [[NSMutableArray alloc] init];
		_rectCache = [[NSMutableArray alloc] init];
		_translateX = [WordClockPreferences sharedInstance].linearTranslateX;
		_translateY = [WordClockPreferences sharedInstance].linearTranslateY;
		_scale = [WordClockPreferences sharedInstance].linearScale;
	}
	return self;
}

- (void) dealloc
{
	[_sizeCache release];
	[_rectCache release];
	[super dealloc];
}


// ____________________________________________________________________________________________________ orientation

- (void)setupForCurrentSize
{
	CGFloat w = self.size.width;
	CGFloat h = self.size.height;
    
    _width = w;
    _height = h;
    _rotation = 0;
    _vx = 1.0f;
    _vy = 0.0f;
}

// ____________________________________________________________________________________________________ update

- (void)update 
{
	// don't need to do anything if width or height haven't changed
	WordClockWord *word;
	uint i;
	uint j;
	uint i_firstOnCurrentLine;
	float widthOfCurrentLine;
	float xAdjust;
	
	//advancement vectors
	float x,y;
	float lineSpace;
		
	i = 0;
	
	x = -_width * 0.5f;
	y = -_height * 0.5f;
	
	
//	_tracking = [WordClockPreferences sharedInstance].tracking;
	_leading = [WordClockPreferences sharedInstance].leading;

	if ( _width == _widthUsedInPreviousUpdate && _height == _heightUsedInPreviousUpdate ) {
	//	return;
	}	
	else {
		_wordScale = [self computeScaleForRect:CGRectMake(0, 0, _width, _height)];
	}
	
	lineSpace = _wordScale * kWordClockWordUnscaledFontSize * (1.0f+_leading);
	
	switch ( [WordClockPreferences sharedInstance].justification ) {
		case WCJustificationLeft:
			for ( word in [WordClockWordManager sharedInstance].word ) {
				_coordinates[ i ].w = _scale * _wordScale * word.unscaledTextureWidth;
				_coordinates[ i ].h = _scale *_wordScale * word.unscaledTextureHeight;
				_coordinates[ i ].w_bounds = _scale *_wordScale * word.unscaledSize.width;
				_coordinates[ i ].h_bounds = _scale *_wordScale * word.unscaledSize.height;
				_coordinates[ i ].r = _rotation;
		//		printf("w_bounds:%f\r",_wordScale * word.size.width);
		//		printf("h_bounds:%f\r",_wordScale * word.sizeword.height);

				if ( x + _wordScale * word.unscaledSize.width > _width*0.5f ) {
					x = -_width*0.5f;
					y += lineSpace;
				}

				_coordinates[ i ].x = _scale * ( _translateX + x * _vx - y * _vy );
				_coordinates[ i ].y = _scale * ( _translateY + x * _vy + y * _vx );

				x += _wordScale * ( word.unscaledSize.width + word.spaceSize.width );
				
				i++;
			}
			break;
			
		case WCJustificationRight:
			i_firstOnCurrentLine = 0;
			widthOfCurrentLine = 0.0f;
			for ( word in [WordClockWordManager sharedInstance].word ) {
				_coordinates[ i ].w = _scale * _wordScale * word.unscaledTextureWidth;
				_coordinates[ i ].h = _scale *_wordScale * word.unscaledTextureHeight;
				_coordinates[ i ].w_bounds = _scale *_wordScale * word.unscaledSize.width;
				_coordinates[ i ].h_bounds = _scale *_wordScale * word.unscaledSize.height;
				_coordinates[ i ].r = _rotation;

				if ( x + _wordScale * word.unscaledSize.width > _width*0.5f ) {
					// move it all across
					for ( j = i_firstOnCurrentLine; j < i; j++ ) {
						xAdjust = (_width*0.5f - x + word.spaceSize.width);
						_coordinates[ j ].x += xAdjust * _vx - 0 * _vy;			
						_coordinates[ j ].y += xAdjust * _vy + 0 * _vx;			
					}
				
					x = -_width*0.5f;
					y += _wordScale * kWordClockWordUnscaledFontSize * (1.0f+_leading);
					i_firstOnCurrentLine = i;
				}

				_coordinates[ i ].x = _scale * ( _translateX + x * _vx - y * _vy );
				_coordinates[ i ].y = _scale * ( _translateY + x * _vy + y * _vx );

				x += _wordScale * ( word.unscaledSize.width + word.spaceSize.width );
				
				i++;
			}
			// also do last line
			for ( j = i_firstOnCurrentLine; j < i; j++ ) {
				xAdjust = (_width*0.5f - x + word.spaceSize.width);
				_coordinates[ j ].x += xAdjust * _vx - 0 * _vy;			
				_coordinates[ j ].y += xAdjust * _vy + 0 * _vx;			
			}
			break;
			
		case WCJustificationCentre:
			i_firstOnCurrentLine = 0;
			widthOfCurrentLine = 0.0f;
			for ( word in [WordClockWordManager sharedInstance].word ) {
				_coordinates[ i ].w = _scale * _wordScale * word.unscaledTextureWidth;
				_coordinates[ i ].h = _scale *_wordScale * word.unscaledTextureHeight;
				_coordinates[ i ].w_bounds = _scale *_wordScale * word.unscaledSize.width;
				_coordinates[ i ].h_bounds = _scale *_wordScale * word.unscaledSize.height;
				_coordinates[ i ].r = _rotation;

				if ( x + _wordScale * word.unscaledSize.width > _width*0.5f ) {
					// move it all across
					for ( j = i_firstOnCurrentLine; j < i; j++ ) {
						xAdjust = (_width*0.5f - x + word.spaceSize.width) * 0.5f * _scale;
						_coordinates[ j ].x += xAdjust * _vx - 0 * _vy;			
						_coordinates[ j ].y += xAdjust * _vy + 0 * _vx;			
					}
				
					x = -_width*0.5f;
					y += _wordScale * kWordClockWordUnscaledFontSize * (1.0f+_leading);
					i_firstOnCurrentLine = i;
				}

				_coordinates[ i ].x = _scale * ( _translateX + x * _vx - y * _vy );
				_coordinates[ i ].y = _scale * ( _translateY + x * _vy + y * _vx );

				x += _wordScale * ( word.unscaledSize.width + word.spaceSize.width );
				
				i++;
			}
			// also do the last line
			for ( j = i_firstOnCurrentLine; j < i; j++ ) {
				xAdjust = (_width*0.5f - x + word.spaceSize.width) * 0.5f * _scale;
				_coordinates[ j ].x += xAdjust * _vx - 0 * _vy;			
				_coordinates[ j ].y += xAdjust * _vy + 0 * _vx;			
			}
			break;
			
		case WCJustificationFull:
			i_firstOnCurrentLine = 0;
			widthOfCurrentLine = 0.0f;
			for ( word in [WordClockWordManager sharedInstance].word ) {
				_coordinates[ i ].w = _scale * _wordScale * word.unscaledTextureWidth;
				_coordinates[ i ].h = _scale *_wordScale * word.unscaledTextureHeight;
				_coordinates[ i ].w_bounds = _scale *_wordScale * word.unscaledSize.width;
				_coordinates[ i ].h_bounds = _scale *_wordScale * word.unscaledSize.height;
				_coordinates[ i ].r = _rotation;

				if ( x + _wordScale * word.unscaledSize.width > _width*0.5f ) {
					// move it all across
					for ( j = i_firstOnCurrentLine; j < i; j++ ) {
					// possible ditch  + word.spaceSize.width
						xAdjust = (_width*0.5f - x + word.spaceSize.width) * (float)(j-i_firstOnCurrentLine) / (float)(i-i_firstOnCurrentLine-1) * _scale;

						_coordinates[ j ].x += xAdjust * _vx - 0 * _vy;			
						_coordinates[ j ].y += xAdjust * _vy + 0 * _vx;			
					}
				
					x = -_width*0.5f;
					y += _wordScale * kWordClockWordUnscaledFontSize * (1.0f+_leading);
					i_firstOnCurrentLine = i;
				}

				_coordinates[ i ].x = _scale * ( _translateX + x * _vx - y * _vy );
				_coordinates[ i ].y = _scale * ( _translateY + x * _vy + y * _vx );

				x += _wordScale * ( word.unscaledSize.width + word.spaceSize.width );
				
				i++;
			}
			break;
	}
	
	_widthUsedInPreviousUpdate = _width;
	_heightUsedInPreviousUpdate = _height;
}

// ____________________________________________________________________________________________________ init

- (void)initialiseNewCoordinates
{
	DLog(@"initialiseNewCoordinates");
	WordClockWord *word;
	uint i;
	i = 0;
	for ( word in [WordClockWordManager sharedInstance].word ) {
		_coordinates[ i ].x = 0;// -_width*0.05f+(float) rand() * _width / RAND_MAX;
		_coordinates[ i ].y = 0;//-_height*0.5f+(float) rand() * _height / RAND_MAX;
		_coordinates[ i ].w = (float) word.unscaledTextureWidth;
		_coordinates[ i ].h = (float) word.unscaledTextureHeight;
		_coordinates[ i ].w_bounds = word.unscaledSize.width;
		_coordinates[ i ].h_bounds = word.unscaledSize.height;
		_coordinates[ i ].r = 0.0f;
		i++;
	}
	
	// TODO a little ugly to set this here, but probably pretty reliable
//	_tracking = [WordClockPreferences sharedInstance].tracking;
	_leading = [WordClockPreferences sharedInstance].leading;
	_widthUsedInPreviousUpdate = -1;
	_heightUsedInPreviousUpdate = -1;
	[_sizeCache removeAllObjects];
	[_rectCache removeAllObjects];
}

// ____________________________________________________________________________________________________ size calculations

-(BOOL)doesScaleFit:(float)scale inRect:(CGRect)rect
{
	float x;
	float y;
	float s;
	float lineSpacing;
	
//	DLog(@"doesScaleFit:%f inRect:%f x %f",scale,rect.size.width,rect.size.height); 
		
	WordClockWord *word;
	
	x = 0;
	y = 0;
	lineSpacing = scale * kWordClockWordUnscaledFontSize * (1.0f+_leading);
	for ( word in [WordClockWordManager sharedInstance].word ) {
	//	s = [word sizeWithFont:font];
		s = scale * word.unscaledSize.width;
//		DLog(@"scale:%f word.unscaledSize.width:%f word.spaceSize.width:%f",scale,word.unscaledSize.width,word.spaceSize.width);
		if ( x + s > rect.size.width ) {
			x = 0;
			y += lineSpacing;
			if ( y > rect.size.height - scale * word.unscaledSize.height ) {
				return NO;
			}
		}
		x += s;
		x += scale * word.spaceSize.width;
	}
	
//	NSLog(@"YES:%f < %f",y,rect.size.height);
	return YES;
}

-(float)computeScaleForRect:(CGRect)rect
{
//	DLog(@"computeScaleForRect:%f x %f",rect.size.width,rect.size.height);
//		DLog(@"_leading:%f",_leading);
//		DLog(@"_tracking:%f",_tracking);
	float size = [self cachedScaleForRect:rect];
	if ( size != -1 ) {
//		DLog(@"returning cached size:%f",size);
		return size;
	}

	float low, high, mid;
	float _oldLow, _oldHigh;
	BOOL lowFits = NO, midFits = NO, highFits = NO;
	BOOL done = NO;

	low = 0.01;
	high = 100;
	
	_oldLow = -1;
	_oldHigh = -1;
	// try both sizes and mid-size
	// keep going until we have a tiny difference
	while (!done && fabs(low-high) > FONT_SIZE_TOLERANCE) {
		if ( low != _oldLow ) {
			lowFits = [self doesScaleFit:low inRect:rect];
			_oldLow = low;
		}
		if ( high != _oldHigh ) {
			highFits = [self doesScaleFit:high inRect:rect];
			_oldHigh = high;
		}
		// low fits, high doesn't
		if ( lowFits && !highFits) {
			mid = (low+high)*0.5f;
			midFits = [self doesScaleFit:mid inRect:rect];
			if ( midFits ) {
				low = mid;
			}
			else {
				high = mid;
			}
		}
		else {
			done=YES;
		}
	}
//	NSLog(@"going with:%f",low);
	// go with the low one	
		
	[self addCachedScaleForRect:rect size:low];
	
//	DLog(@"computeScaleForRect=%f",low);
	return low;
}

-(float)cachedScaleForRect:(CGRect)rect
{
	CGRect r;
	for ( int i = 0; i < [_rectCache count]; i++ ) {
		r = CGRectFromArray([_rectCache objectAtIndex:i]);
		if ( CGSizeEqualToSize(rect.size, r.size)) {
			return [[_sizeCache objectAtIndex:i] floatValue];
		}
	}
	return -1;
}

-(void)addCachedScaleForRect:(CGRect)rect size:(float)size
{
	NSLog(@"cacheing rect:%@",ArrayFromCGRect(rect));
	[_sizeCache addObject:[NSNumber numberWithFloat:size]];
	[_rectCache addObject:ArrayFromCGRect(rect)];
}

// ____________________________________________________________________________________________________ accessors

@synthesize width = _width;
@synthesize height = _height;
@synthesize wordScale = _wordScale;

@end

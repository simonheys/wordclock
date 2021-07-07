//
//  WordClockUIView.m
//  iphone_word_clock
//
//  Created by Simon on 21/07/2008.
//  Copyright 2008 Simon Heys. All rights reserved.
//

#import "WordClockGLView.h"


/*

TODO

write an intelligent texture re-rendering class.
things that are in or around the current viewing area need ot be high-res
anythign that's offscreen can be low-res.

needs a priority system / queue

would be nice to be able to have 1024x1024 textures at some points.

*/
@interface WordClockGLView (WordClockGLViewPrivate)
	- (void)setupView;
	- (void)doUpdateFromPreferences;
@end


@implementation WordClockGLView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self setupGL];
        [self setupView];
        
    }
    return self;
}

// ____________________________________________________________________________________________________ init

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (void)setupGL
{
		DLog(@"creating view etc...");
        
		// Get the layer
        /*
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		
		// TODO check if RGB565 is really faster or not
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
//			[NSNumber numberWithBool:FALSE], 
//			kEAGLDrawablePropertyRetainedBacking, 
			kEAGLColorFormatRGB565, //
			//kEAGLColorFormatRGBA8, 
			kEAGLDrawablePropertyColorFormat, 
			nil
		];
        */
    
    self.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
    
//	CGRect screenBounds = [[UIScreen mainScreen] bounds];
//		eaglLayer.bounds = screenBounds;
		
		_updateFromPreferences = NO;
		
		self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(!self.context || ![EAGLContext setCurrentContext:self.context] ) {
			[self release];
			return;
		}
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
//		glGenFramebuffersOES(1, &defaultFramebuffer);
//		glGenRenderbuffersOES(1, &colorRenderbuffer);
//		glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
//		glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
//		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
		
		_translateX = 0.0f;
		_translateY = 0.0f;
		_scale = 1.0f;
		
		_textureRenderRotaIndex = 1;
		_textureScalingEnabled = YES;
		
		_layout = [[WordClockWordLayout alloc] init];
		
        self.contentScaleFactor = [UIScreen mainScreen].scale;


	_initialised = YES;

}

// ____________________________________________________________________________________________________ setup view

- (void)layoutSubviews
{
	DLog(@"layoutSubviews:%@",NSStringFromCGRect(self.bounds));

    _layout.size = self.bounds.size;
	// left, right, bottom, top, near, far
	// left, right, bottom, top, near, far
        
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(
		-self.bounds.size.width/2, 
		self.bounds.size.width/2, 
		self.bounds.size.height/2, 
		-self.bounds.size.height/2, 
		-1.0f, 
		1.0f
	);
    
    // refresh the buffer, otherwise it can go blurry
    [self deleteDrawable];
    
//    self.drawableMultisample = GLKViewDrawableMultisampleNone;
}

- (void)setupView
{
	DLog(@"setupView");

//	glMatrixMode(GL_PROJECTION);
//	glLoadIdentity();
//
//	glMatrixMode(GL_MODELVIEW);
	
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_FOG);
	glDisable(GL_LIGHTING);
	glDisable(GL_ALPHA_TEST);
	glDisable(GL_DEPTH_TEST);
    
	// Clears the view with black
//	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	// Sets up pointers and enables states needed for using vertex arrays and textures
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	// Set a blending function to use
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

	// Enable blending (alpha channels in textures)
	glEnable(GL_BLEND);	
	
//	[self updateFromPreferences];
}

- (void)drawRect:(CGRect)rect
{
//	double startTimeInSeconds = getUpTime();
	
//    DLog(@"drawRect");
    
	NSMutableArray *highlightedIndices;
	highlightedIndices = [[NSMutableArray alloc] init];
    [[TweenManager sharedInstance] update];
	[_layout update];
//
//	[EAGLContext setCurrentContext:self.context];
//	
//    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
	glClear(GL_COLOR_BUFFER_BIT);

//	glPushMatrix();

#ifdef ENABLE_CULL
	float minX = -160;
	float maxX = 160;
	float minY = -240;
	float maxY = 240;
#endif

	// render all the vertices based on the coordinates in layout	
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	glTexCoordPointer(2, GL_SHORT, 0, _coordinates);
	glColorPointer(4, GL_FLOAT, 0, _colours);
	//	-(int)cullRects:(WordClockRectsForCulling *)rects length:(int)numberOfRects inRect:(CGRect)rect resultArrayPointer:(void *)resultPointer;

#ifdef ENABLE_CULL
	int numberOfVisibleWords = cull_rects(_rectsForCulling, _numberOfWords, CGRectMake(minX,minY,maxX-minX,maxY-minY),_visibleWordIndices);
	int visibleWordIndex;

	for ( uint i=0; i < numberOfVisibleWords; i++ ) {
		visibleWordIndex = _visibleWordIndices[i];

		if ( _highlighted[visibleWordIndex] ) {
			[highlightedIndices addObject:[NSNumber numberWithInt:visibleWordIndex]];
		}
		else {
			glBindTexture(GL_TEXTURE_2D, _spriteTexture[visibleWordIndex]);
			glDrawArrays(GL_TRIANGLE_STRIP, visibleWordIndex<<2, 4);
		}
	}
#else
	for ( uint i=0; i < _numberOfWords; i++ ) {
		if ( _highlighted[i] ) {
			[highlightedIndices addObject:[NSNumber numberWithInt:i]];
		}
		else {
			glBindTexture(GL_TEXTURE_2D, _spriteTexture[i]);
			glDrawArrays(GL_TRIANGLE_STRIP, i<<2, 4);
		}
	}
#endif
	

	/*
	for ( uint i=0; i < _numberOfWords; i++ ) {
		visibleWordIndex = i;
		if ( _highlighted[visibleWordIndex] ) {
			[highlightedIndices addObject:[NSNumber numberWithInt:visibleWordIndex]];
		}
		else {
		//	if ( i == 0 ) {
		//		DLog(@"f:%f minX:%f",_vertices[i<<2],minX);
		//	}
		//	if ( _vertices[i<<2] >= minX && _vertices[i<<2] <= maxX && _vertices[1+i<<2] >= minY && _vertices[1+i<<2] <= maxY) {
			glBindTexture(GL_TEXTURE_2D, _spriteTexture[visibleWordIndex]);
			glDrawArrays(GL_TRIANGLE_STRIP, visibleWordIndex<<2, 4);
		//	}
		}
	}
*/

	// now draw the highlighted ones
	for ( NSNumber *index in highlightedIndices ) {
		uint i = [index intValue];
		glBindTexture(GL_TEXTURE_2D, _spriteTexture[i]);
		glDrawArrays(GL_TRIANGLE_STRIP, i<<2, 4);
	}
	
//	glEnable(GL_DEPTH_TEST);
//	glPopMatrix();
	
//	glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
//    [context presentRenderbuffer:GL_RENDERBUFFER_OES];

	[highlightedIndices release];
	
	// redraw one textrue with current scale
	// re-render visible words only
	
#ifdef ENABLE_TEXTURE_SCALING
	#ifdef ENABLE_CULL
	if ( !_layout.isTweening ) {
		_textureRenderRotaIndex = ( _textureRenderRotaIndex + 1 ) % numberOfVisibleWords;
		visibleWordIndex = _visibleWordIndices[_textureRenderRotaIndex];
		[[[WordClockWordManager sharedInstance].word objectAtIndex:visibleWordIndex] 
			rerenderToOpenGlTexture:&_spriteTexture[visibleWordIndex] 
			withScale:_layout.scale*[_layout getLayoutWordScale]
		];
	}
	#else
	if ( !_layout.isTweening ) {
		_textureRenderRotaIndex = ( _textureRenderRotaIndex + 1 ) % _numberOfWords;
		[[[WordClockWordManager sharedInstance].word objectAtIndex:_textureRenderRotaIndex] 
			rerenderToOpenGlTexture:&_spriteTexture[_textureRenderRotaIndex] 
			withScale:_layout.scale*[_layout getLayoutWordScale]
		];
	}
	#endif
#else
	if ( !_layout.isTweening ) {
		_textureRenderRotaIndex = ( _textureRenderRotaIndex + 1 ) % _numberOfWords;
//		[[[WordClockWordManager sharedInstance].word objectAtIndex:_textureRenderRotaIndex] renderMipMap];
	}
#endif

	
//	double drawTimeInSeconds = getUpTime() - startTimeInSeconds;
	
//	DLog(@"drawTimeInSeconds:%f / %f",drawTimeInSeconds,1.0f/kFramesPerSecond);
	
}

// ____________________________________________________________________________________________________ update

// prefs have changed; need to re-render all the textures
- (void)setLogic:(NSArray *)logicArray label:(NSArray *)labelArray
{	
	DLog(@"setLogic");

	// ditch all the old textures
	[self deleteTextures];
	
	// need to update logic in WordClockWordManager
	[[WordClockWordManager sharedInstance] setLogic:logicArray label:labelArray];
	
	_numberOfWords = [WordClockWordManager sharedInstance].numberOfWords;
	
	// because logic has changed, number of words has probably changed
	// so need a new set of coordinates and vertices
	free(_coordinates);
	
	_coordinates = malloc(_numberOfWords * 8 * sizeof(GLshort));
	uint offset = 0;
	for ( uint i=0; i < _numberOfWords; i++ ) {
		_coordinates[offset++] = 0;
		_coordinates[offset++] = 1;
		_coordinates[offset++] = 1;
		_coordinates[offset++] = 1;
		_coordinates[offset++] = 0;
		_coordinates[offset++] = 0;
		_coordinates[offset++] = 1;
		_coordinates[offset++] = 0;
	}
	
	free(_vertices);
	_vertices = malloc(_numberOfWords * 8 * sizeof(GLfloat));
	
	free(_rectsForCulling);
	_rectsForCulling = malloc(_numberOfWords * sizeof(WordClockRectsForCulling));
	
	// layout should calculate all the vertices directly into this array
//	DLog(@"&_vertices[0]:%d",&_vertices[0]);
	_layout.vertices = _vertices;
	_layout.rectsForCulling = _rectsForCulling;

	free(_colours);
	_colours = malloc(_numberOfWords * 4 * 4 * sizeof(GLfloat));
	
	free(_highlighted);
	_highlighted = malloc(_numberOfWords * sizeof(BOOL));
	
	free(_visibleWordIndices);
	_visibleWordIndices = malloc(_numberOfWords * sizeof(int));
	
	[self renderTextures];
}

// ____________________________________________________________________________________________________ textures

- (void)renderTextures
{
	WordClockWord *w;
	uint i;
	uint totalPixels;
	uint sparePixelsSoFar;
	uint pixelsPerWord;
	
	// realloc spriteTextures[] to new length
	_spriteTexture = malloc(_numberOfWords * sizeof(GLuint));
	
	// render all the new ones by calling renderToOpenGlTexture: on every word
	i = 0;
	totalPixels = 0;
	sparePixelsSoFar = 0;
	pixelsPerWord = kWordClockWordTextureMaximumPixelsCombined / [WordClockWordManager sharedInstance].numberOfWords;
	
	for ( w in [WordClockWordManager sharedInstance].word ) {
		[w setColourPointer:&_colours[i*4*4]];
		[w setHighlightedPointer:&_highlighted[i]];
		w.texturePixelsMaximum = pixelsPerWord+sparePixelsSoFar;
		[w renderToOpenGlTexture:&_spriteTexture[i] withScale:4.0f];
//	DLog(@"w:%d h:%d",w.textureWidth,w.textureHeight);
		
//	DLog(@"Max pixels:%d w:%d h:%d Spare pixels:%d",w.texturePixelsMaximum,w.textureWidth,w.textureHeight, ( w.texturePixelsMaximum - ( w.textureWidth * w.textureHeight ) ) );
	
		sparePixelsSoFar = ( w.texturePixelsMaximum - ( w.textureWidth * w.textureHeight ) ) ;
		// increase by the sapre pixels;
//		if ( maxPixelsForCurrentWord < UINT_MAX-1024*1024 ) {
//			maxPixelsForCurrentWord += (maxPixelsForCurrentWord - ( w.textureWidth * w.textureHeight ) );
//		}
		
		totalPixels+= ( w.textureWidth * w.textureHeight );
		i++;
	}
	
	DLog(@"total texture pixels:%u",totalPixels);
}

- (void)deleteTextures
{
	// free memory spriteTextures[]
	// http://www.khronos.org/opengles/documentation/opengles1_0/html/glDeleteTextures.html
	
	glDeleteTextures(_numberOfWords, _spriteTexture);
	free(_spriteTexture);
}

// ____________________________________________________________________________________________________ preferences

- (void)updateFromPreferences
{	
	DLog(@"updateFromPreferences");
	WordClockWord *w;

	// check what's changed and act accrodingly
	// just kerning? just leading?
	// typeface changes? etc.

	// update base size calulcations for all the words
	NSString *fontName = [WordClockPreferences sharedInstance].fontName;
	float tracking = [WordClockPreferences sharedInstance].tracking;
	WCCaseAdjustment caseAdjustment = [WordClockPreferences sharedInstance].caseAdjustment;
	for ( w in [WordClockWordManager sharedInstance].word ) {
		[w setFontWithName:fontName tracking:tracking caseAdjustment:caseAdjustment];
	}
	
	[self deleteTextures];
	// TODO check if new logic is needed...
	[self renderTextures];
	
	// set background colour
	CGColorRef color = [[WordClockPreferences sharedInstance] backgroundColour].CGColor;
	const CGFloat *components = CGColorGetComponents(color);
	CGFloat red = components[0];
	CGFloat green = components[1];
	CGFloat blue = components[2];
	
//	red = 1.0f;
	
	glClearColor(red, green, blue, 1.0f);

	[[NSNotificationCenter defaultCenter] 
		postNotificationName:@"kWordClockGLViewTexturesDidChangeNotification" 
		object:self
	];
	
//	[self drawView];
}

// ____________________________________________________________________________________________________ touches

- (void)setScale:(float)value
{
	_layout.scale = value;
	_scale = value;
}

- (void)setTranslateX:(float)value
{
	_layout.translateX = value;
	_translateX = value;
}

- (void)setTranslateY:(float)value
{
	_layout.translateY = value;
	_translateY = value;
}

// ____________________________________________________________________________________________________ dealloc

- (void)dealloc 
{
	DLog(@"dealloc");
	// Tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffersOES(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}

	if (colorRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	// Tear down context
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[super dealloc];
	[self deleteTextures];
	free(_coordinates);
	free(_vertices);
	free(_rectsForCulling);
	free(_colours);
	free(_highlighted);
	free(_visibleWordIndices);
	
	[_layout release];
	[super dealloc];
}

// ____________________________________________________________________________________________________ accessors

@synthesize translateX = _translateX;
@synthesize translateY = _translateY;
@synthesize scale = _scale;
@synthesize layout = _layout;
@synthesize textureScalingEnabled = _textureScalingEnabled;

@end
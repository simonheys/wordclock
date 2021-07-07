//
//  WordClockPreview.m
//  iphone_word_clock_open_gl
//
//  Created by Simon on 11/03/2009.
//  Copyright 2009 Simon Heys. All rights reserved.
//

#import "WordClockPreview.h"

@interface WordClockPreview (WordClockPreviewPrivate)
	-(void)updateLabels;
	-(void)customSetup;
@end


@implementation WordClockPreview

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
	{
		[self customSetup];
	}
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder])) {
		[self customSetup];
	}	
	return self;
}

-(void)updateFromPreferences
{
	_tracking = [WordClockPreferences sharedInstance].tracking;
	_leading = [WordClockPreferences sharedInstance].leading;
	self.backgroundColour = [WordClockPreferences sharedInstance].backgroundColour;
	self.foregroundColour = [WordClockPreferences sharedInstance].foregroundColour;
	self.highlightColour = [WordClockPreferences sharedInstance].highlightColour;
}

-(void)customSetup
{
	[self updateFromPreferences];

	// Initialization code
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(logicAndLabelsDidChange:)
		name:kWordClockWordManagerLogicaAndLabelsDidChangeNotification object:nil];
	[self updateLabels];
}


-(void)logicAndLabelsDidChange:(NSNotification *)notification
{
	DLog(@"logicaAndLabelsDidChange");
	[self updateLabels];
	[self setNeedsDisplay];
}

-(void)updateLabels
{
	if (_word) {
		[_word release];
	}
	WordClockWord *w;
	
	_word = [[NSMutableArray alloc] init];
	
	NSArray *labelArray = [[WordClockWordManager sharedInstance] longestLabelArray];
	for ( NSString *label in labelArray) {
		w = [[WordClockWord alloc] initWithLabel:label];
		
		if ( !w.isSpace ) {
			[_word addObject:w];
		}
		//w is retained by the array
		[w release];
	}
}

-(void)drawRect:(CGRect)rect 
{
 	NSString *fontName = [WordClockPreferences sharedInstance].fontName;
//	float tracking = [WordClockPreferences sharedInstance].tracking;
	WCCaseAdjustment caseAdjustment = [WordClockPreferences sharedInstance].caseAdjustment;

	float x, y;
	float cx, cy;
	WordClockWord *word;
	WordClockWord *centralWord;
	
	uint centre = [_word count] / 2;
	int i;
	uint totalWords;
	
	// draw the centrally highlighted one
	centralWord = [_word objectAtIndex:centre];
	[centralWord setFontWithName:fontName tracking:_tracking caseAdjustment:caseAdjustment];
	
	cx = CGRectGetMidX(rect) - centralWord.unscaledSize.width/2;
	cy = CGRectGetMidY(rect) - centralWord.unscaledSize.height/2;
	

//	[[WordClockPreferences sharedInstance].backgroundColour set];
	[_backgroundColour set];
	UIRectFill(rect);
	
	//x -= word.unscaledSize.width * 0.5f;
	x = cx - centralWord.spaceSize.width;
	y = cy;
	 
//	[[WordClockPreferences sharedInstance].foregroundColour set];
	[_foregroundColour set];
	
	// go left towards the beginning
	for ( i = centre-1; i >=0; i-- ) {
		word = [_word objectAtIndex:i];
		[word setFontWithName:fontName tracking:_tracking caseAdjustment:caseAdjustment];
		x -= word.unscaledSize.width;
		[word renderInCurrentGraphicsContentAtPoint:CGPointMake(x,y)];
		x -= word.spaceSize.width;
		if ( x < rect.origin.x ) {
			// move up one line
			y -= kWordClockWordUnscaledFontSize * (1.0f+_leading);
			x = CGRectGetMaxX(rect);
		}
		if ( y < -kWordClockWordUnscaledFontSize * (1.0f+_leading) -word.unscaledSize.height ) {
			break;
		}
	}
	
	x = cx + centralWord.spaceSize.width + centralWord.unscaledSize.width;
	y = cy;
	
	// go right towards the end
	totalWords = [_word count];
	for ( i = centre+1; i < totalWords; i++ ) {
		word = [_word objectAtIndex:i];
		[word setFontWithName:fontName tracking:_tracking caseAdjustment:caseAdjustment];
		[word renderInCurrentGraphicsContentAtPoint:CGPointMake(x,y)];
		x += word.unscaledSize.width;
		x += word.spaceSize.width;
		if ( x > CGRectGetMaxX(rect)) {
			// move down one line
			y += kWordClockWordUnscaledFontSize * (1.0f+_leading);
			x = rect.origin.x;
		}
		if ( y > CGRectGetMaxY(rect)) {
			break;
		}
	}
	
	[_highlightColour set];
//	[[WordClockPreferences sharedInstance].highlightColour set];
	[centralWord renderInCurrentGraphicsContentAtPoint:CGPointMake(cx,cy)];
}

- (void)setTracking:(float)value
{
	_tracking = value;
	[self setNeedsDisplay];
}

- (void)setLeading:(float)value
{
	_leading = value;
	[self setNeedsDisplay];
}

- (void)setForegroundColour:(UIColor *)colour
{
	[_foregroundColour release];
	_foregroundColour = [colour retain];
	[self setNeedsDisplay];
}

- (void)setBackgroundColour:(UIColor *)colour
{
	[_backgroundColour release];
	_backgroundColour = [colour retain];
	[self setNeedsDisplay];
}

- (void)setHighlightColour:(UIColor *)colour
{
	[_highlightColour release];
	_highlightColour = [colour retain];
	[self setNeedsDisplay];
}

- (void)dealloc 
{
	[_foregroundColour release];
	[_backgroundColour release];
	[_highlightColour release];
	[_word release];
    [super dealloc];
}

@synthesize tracking = _tracking;
@synthesize leading = _leading;
@synthesize foregroundColour = _foregroundColour;
@synthesize backgroundColour = _backgroundColour;
@synthesize highlightColour = _highlightColour;

@end

//
//  WordClockPreferences.m
//  iphone_word_clock
//
//  Created by Simon on 23/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WordClockPreferences.h"

NSString *WCXMLFileKey = @"xmlFile";
NSString *WCFontNameKey = @"fontName";
NSString *WCHighlightColourKey = @"highlightColour";
NSString *WCForegroundColourKey = @"foregroundColour";
NSString *WCBackgroundColourKey = @"backgroundColour";
NSString *WCLeadingKey = @"leading";
NSString *WCTrackingKey = @"tracking";
NSString *WCJustificationKey = @"justification";
NSString *WCCaseAdjustmentKey = @"caseAdjustment";
NSString *WCStyleKey = @"style";

NSString *const WCLinearTranslateXKey = @"linearTranslateX";
NSString *const WCLinearTranslateYKey = @"linearTranslateY";
NSString *const WCLinearScaleKey = @"linearScale";

NSString *const WCRotaryTranslateXKey = @"rotaryTranslateX";
NSString *const WCRotaryTranslateYKey = @"rotaryTranslateY";
NSString *const WCRotaryScaleKey = @"rotaryScale";

NSString *WCLockedKey = @"locked";

@implementation WordClockPreferences

// ____________________________________________________________________________________________________ defaults

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults registerDefaults:[self factoryDefaults]];
	
	DLog(@"registered defaults");
}

+ (NSDictionary *)factoryDefaults
{
	BOOL isRunningOnPad = NO;
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
		isRunningOnPad = YES;
	}
	NSDictionary *factoryDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
		@"English.xml", WCXMLFileKey,
		@"Helvetica-Bold", WCFontNameKey,
		[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0]],WCHighlightColourKey,
		[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0]],WCForegroundColourKey,
		[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0]],WCBackgroundColourKey,
		[NSNumber numberWithFloat:0.0f],WCLeadingKey,
		[NSNumber numberWithFloat:0.0f],WCTrackingKey,
		[NSNumber numberWithUnsignedInt:WCJustificationLeft],WCJustificationKey,
		[NSNumber numberWithUnsignedInt:WCStyleLinear],WCStyleKey,
		[NSNumber numberWithFloat:0.0f],WCLinearTranslateXKey,
		[NSNumber numberWithFloat:0.0f],WCLinearTranslateYKey,
		[NSNumber numberWithFloat:1.0f],WCLinearScaleKey,
		isRunningOnPad ? [NSNumber numberWithFloat:-512.0f/1.5f] : [NSNumber numberWithFloat:-240.0f/0.75f],WCRotaryTranslateXKey,
		[NSNumber numberWithFloat:0.0f],WCRotaryTranslateYKey,
		isRunningOnPad ? [NSNumber numberWithFloat:1.5f] : [NSNumber numberWithFloat:0.75f],WCRotaryScaleKey,
		[NSNumber numberWithBool:YES],WCLockedKey,
		nil		
	];
	return factoryDefaults;
}

- (void) dealloc
{
	[_backgroundColour release];
	[_foregroundColour release];
	[_highlightColour release];
	[_fontName release];
	[super dealloc];
}

// ____________________________________________________________________________________________________ xml file

- (void)setXmlFile:(NSString *)value
{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:WCXMLFileKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)xmlFile
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:WCXMLFileKey];
}

// ____________________________________________________________________________________________________ font name

- (void)setFontName:(NSString *)value
{
	if ( [value isEqual:_fontName] ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:WCFontNameKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_fontName = [value retain];
}

- (NSString *)fontName
{
	if ( !_fontName ) {
		_fontName = [[NSUserDefaults standardUserDefaults] stringForKey:WCFontNameKey];
		[_fontName retain];
	}
	return _fontName;
}

- (void)setLeading:(float)value
{
	if ( _leading == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:value] forKey:WCLeadingKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_leading = value;
}

- (float)leading
{
	if ( !_leading ) {
		_leading = [[NSUserDefaults standardUserDefaults] floatForKey:WCLeadingKey];
	}
	return _leading;
}

- (void)setTracking:(float)value
{
	if ( _tracking == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:value] forKey:WCTrackingKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_tracking = value;
}

- (float)tracking
{
	if ( !_tracking ) {
		_tracking = [[NSUserDefaults standardUserDefaults] floatForKey:WCTrackingKey];
	}
	return _tracking;
}

- (void)setCaseAdjustment:(WCCaseAdjustment)value
{
	if ( _caseAdjustment == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInt:value] forKey:WCCaseAdjustmentKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_caseAdjustment = value;
	
}

- (WCCaseAdjustment)caseAdjustment
{
	if ( !_caseAdjustment ) {
		_caseAdjustment = [[NSUserDefaults standardUserDefaults] integerForKey:WCCaseAdjustmentKey];
	}
	return _caseAdjustment;
}

- (void)setJustification:(WCJustification)value
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInt:value] forKey:WCJustificationKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (WCJustification)justification
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:WCJustificationKey];
}

- (void)setStyle:(WCStyle)value
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInt:value] forKey:WCStyleKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (WCStyle)style
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:WCStyleKey];
}

// ____________________________________________________________________________________________________ colour

- (void)setBackgroundColour:(UIColor *)colour
{
	if ( [colour isEqual:_backgroundColour] ) {
		DLog(@"setBackgroundColour: colour is same, not saving");
		return;
	}
	[_backgroundColour release];
	NSData *theData;
	theData=[NSKeyedArchiver archivedDataWithRootObject:colour];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:WCBackgroundColourKey];	
	[[NSUserDefaults standardUserDefaults] synchronize];
	_backgroundColour = [colour retain];
}

- (void)setForegroundColour:(UIColor *)colour
{
	if ( [colour isEqual:_foregroundColour] ) {
		DLog(@"setForegroundColour: colour is same, not saving");
		return;
	}
	[_foregroundColour release];
	NSData *theData;
	theData=[NSKeyedArchiver archivedDataWithRootObject:colour];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:WCForegroundColourKey];	
	[[NSUserDefaults standardUserDefaults] synchronize];
	_foregroundColour = [colour retain];
}

- (void)setHighlightColour:(UIColor *)colour
{
	if ( [colour isEqual:_highlightColour] ) {
		DLog(@"setHighlightColour: colour is same, not saving");
		return;
	}
	[_highlightColour release];
	NSData *theData;
	theData=[NSKeyedArchiver archivedDataWithRootObject:colour];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:WCHighlightColourKey];
	[[NSUserDefaults standardUserDefaults] synchronize];	
	_highlightColour = [colour retain];
}

-(UIColor *)backgroundColour
{
	if ( !_backgroundColour ) {
		_backgroundColour = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:WCBackgroundColourKey]];
		[_backgroundColour retain];
	}
	return _backgroundColour;
}

-(UIColor *)foregroundColour
{	
	if ( !_foregroundColour ) {
		_foregroundColour = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:WCForegroundColourKey]];
		[_foregroundColour retain];
	}
	return _foregroundColour;
}

-(UIColor *)highlightColour
{
	if ( !_highlightColour ) {
		_highlightColour = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:WCHighlightColourKey]];
		[_highlightColour retain];
	}
	return _highlightColour;
}

// ____________________________________________________________________________________________________ Translate & Scale

- (void)setLinearTranslateX:(float)value
{
	if ( _linearTranslateX == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:value] forKey:WCLinearTranslateXKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_linearTranslateX = value;
}

- (float)linearTranslateX
{
	if ( !_linearTranslateX ) {
		_linearTranslateX = [[NSUserDefaults standardUserDefaults] floatForKey:WCLinearTranslateXKey];
	}
	return _linearTranslateX;
}

- (void)setLinearTranslateY:(float)value
{
	if ( _linearTranslateY == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:value] forKey:WCLinearTranslateYKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_linearTranslateY = value;
}

- (float)linearTranslateY
{
	if ( !_linearTranslateY ) {
		_linearTranslateY = [[NSUserDefaults standardUserDefaults] floatForKey:WCLinearTranslateYKey];
	}
	return _linearTranslateY;
}

- (void)setLinearScale:(float)value
{
	if ( _linearScale == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:value] forKey:WCLinearScaleKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_linearScale = value;
}

- (float)linearScale
{
	if ( !_linearScale ) {
		_linearScale = [[NSUserDefaults standardUserDefaults] floatForKey:WCLinearScaleKey];
		if ( _linearScale > kTouchableViewMaximumScale ) { _linearScale = kTouchableViewMaximumScale; }
		if ( _linearScale < kTouchableViewMinimumScale ) { _linearScale = kTouchableViewMinimumScale; }
	}
	return _linearScale;
}

- (void)setRotaryTranslateX:(float)value
{
	if ( _rotaryTranslateX == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:value] forKey:WCRotaryTranslateXKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_rotaryTranslateX = value;
}

- (float)rotaryTranslateX
{
	if ( !_rotaryTranslateX ) {
		_rotaryTranslateX = [[NSUserDefaults standardUserDefaults] floatForKey:WCRotaryTranslateXKey];
	}
	return _rotaryTranslateX;
}

- (void)setRotaryTranslateY:(float)value
{
	if ( _rotaryTranslateY == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:value] forKey:WCRotaryTranslateYKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_rotaryTranslateY = value;
}

- (float)rotaryTranslateY
{
	if ( !_rotaryTranslateY ) {
		_rotaryTranslateY = [[NSUserDefaults standardUserDefaults] floatForKey:WCRotaryTranslateYKey];
	}
	return _rotaryTranslateY;
}

- (void)setRotaryScale:(float)value
{
	if ( _rotaryScale == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:value] forKey:WCRotaryScaleKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_rotaryScale = value;
}

- (float)rotaryScale
{
	if ( !_rotaryScale ) {
		_rotaryScale = [[NSUserDefaults standardUserDefaults] floatForKey:WCRotaryScaleKey];
		if ( _rotaryScale > kTouchableViewMaximumScale ) { _rotaryScale = kTouchableViewMaximumScale; }
		if ( _rotaryScale < kTouchableViewMinimumScale ) { _rotaryScale = kTouchableViewMinimumScale; }
	}
	return _rotaryScale;
}

// ____________________________________________________________________________________________________ Locked

- (void)setLocked:(BOOL)value
{
	if ( _locked == value ) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:WCLockedKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_locked = value;
}

- (BOOL)locked
{
	if ( !_locked ) {
		_locked = [[NSUserDefaults standardUserDefaults] boolForKey:WCLockedKey];
	}
	return _locked;
}

// ____________________________________________________________________________________________________ Singleton

static WordClockPreferences *sharedWordClockPreferencesInstance = nil;

+ (WordClockPreferences*)sharedInstance
{
    @synchronized(self) {
        if (sharedWordClockPreferencesInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedWordClockPreferencesInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedWordClockPreferencesInstance == nil) {
            sharedWordClockPreferencesInstance = [super allocWithZone:zone];
            return sharedWordClockPreferencesInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

// ____________________________________________________________________________________________________ Getters / Setters

@synthesize xmlFile;
@synthesize fontName;
@synthesize highlightColour;
@synthesize foregroundColour;
@synthesize backgroundColour;
@synthesize leading;
@synthesize tracking;
@synthesize justification;
@synthesize caseAdjustment;
@synthesize style;

@synthesize linearTranslateX;
@synthesize linearTranslateY;
@synthesize linearScale;

@synthesize rotaryTranslateX;
@synthesize rotaryTranslateY;
@synthesize rotaryScale;

@synthesize locked;


@end

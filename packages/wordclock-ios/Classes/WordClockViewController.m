//
//  WordClockViewController.m
//  iphone_word_clock
//
//  Created by Simon on 22/07/2008.
//  Copyright 2008 Simon Heys. All rights reserved.
//

#import "WordClockViewController.h"
#import "WordClockGLView.h"

@implementation WordClockViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	DLog(@"initWithNibName");
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.preferredFramesPerSecond = 60;
	}
	return self;
}

// ____________________________________________________________________________________________________ init

- (void)loadView
{
    self.view = [[[WordClockGLView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
}

- (void)viewDidLoad 
{
	DLog(@"viewDidLoad");
	
	_running = NO;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	_controls = [[WordClockViewControls alloc] initWithFrame:self.view.bounds];
    _controls.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_controls.delegate = self;
	
	[self.view addSubview:_controls];
	
	[self.view setAlpha:0];	
}

// ____________________________________________________________________________________________________ startup

- (void)logicXmlFileParserDidCompleteParsing:(LogicXmlFileParser*)parser
{
	DLog(@"logicXmlFileParserDidCompleteParsing");
	[(WordClockGLView *)self.view setLogic:parser.logic label:parser.label];
	if ([delegate respondsToSelector:@selector(wordClockDidCompleteParsing:)]) {
		[delegate wordClockDidCompleteParsing:self];
	}			
}

// ____________________________________________________________________________________________________ update from flipside view

- (void)updateFromPreferences
{
	DLog(@"updateFromPreferences");

	NSString *xmlFile = [WordClockPreferences sharedInstance].xmlFile;

	[self stop];

	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	
	[_parser release];
	_parser = [[LogicXmlFileParser alloc] init];
	[_parser setDelegate:self];

	_currentXmlFile = xmlFile;
	DLog(@"updateFromPreferences - Parse xml:%@",xmlFile);
	[_parser parseFile:[thisBundle pathForResource:_currentXmlFile ofType:nil]];

	DLog(@"updateFromPreferences - I'm back");
	[(WordClockGLView *)self.view updateFromPreferences];
	
//	self.view.backgroundColor = [WordClockPreferences sharedInstance].backgroundColour;	
	
	// highlight words
	_previousSecond = -1;
	[self runLoop];
}

// ____________________________________________________________________________________________________ begin

// start for first time
-(void)begin
{
	DLog(@"begin");

	// highlight words
	_previousSecond = -1;
//	[self runLoop];

//	[(WordClockGLView *)self.view drawView];
	[self start];
}

-(void)predrawView
{
	_previousSecond = -1;
	[self runLoop];

//	[(WordClockGLView *)self.view drawView];

}

// fade in for first time
-(void)appear
{
	DLog(@"appear");

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.25];
	[self.view setAlpha:1.0];
	[UIView commitAnimations];
}

// ____________________________________________________________________________________________________ start

-(void)start
{
	DLog(@"start");
	if ( !_running ) {
		_running = YES;
		[[DisplayLinkManager sharedInstance] addTarget:self selector:@selector(runLoop) priority:YES];
//		[(WordClockGLView *)self.view startAnimation];
        self.paused = NO;
	}
}

// ____________________________________________________________________________________________________ stop

-(void)stop
{
	DLog(@"stop");
	if ( _running ) {
		_running = NO;
		[[DisplayLinkManager sharedInstance] removeTarget:self];
//		[(WordClockGLView *)self.view stopAnimation];
        self.paused = YES;
	}
}

// ____________________________________________________________________________________________________ run

-(void)runLoop
{	
	NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSCalendarUnit unitFlags = 
		NSYearCalendarUnit | 
		NSMonthCalendarUnit |  
		NSDayCalendarUnit | 
		NSHourCalendarUnit | 
		NSMinuteCalendarUnit | 
		NSSecondCalendarUnit | 
		NSWeekdayCalendarUnit;
	NSDate *date = [NSDate date];
	NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];

	NSInteger second = [dateComponents second];

	[calendar release];

	if ( second != _previousSecond ) {
//		DLog(@"runLoop:tick");
		NSInteger hour = [dateComponents hour];

		// amke hour from 1..12
//		NSLog(@"HOUR:%d",hour);
		hour %= 12;
		if ( hour == 0 ) {
			hour = 12;
		}
//		DLog(@"HOUR:%d",hour);
//		NSLog(@"HOUR:%d",hour);
		
		[LogicParser sharedInstance].hour = hour;
		[LogicParser sharedInstance].twentyfourhour = [dateComponents hour];
		[LogicParser sharedInstance].minute = [dateComponents minute];
		[LogicParser sharedInstance].second = second;
		[LogicParser sharedInstance].day = [dateComponents weekday]-1;//-1 for compatibility with flash d.getDay();
		//DLog(@"day:%d",[LogicParser sharedInstance].day);
		[LogicParser sharedInstance].date = [dateComponents day];// d.getDate();
		[LogicParser sharedInstance].month = [dateComponents month]-1;//-1 for compatibility with flash d.getMonth();
		//[(WordClockGLView *)self.view highlightForCurrentTime];
		[[WordClockWordManager sharedInstance] highlightForCurrentTime];
		_previousSecond = second;
	}
}

// ____________________________________________________________________________________________________ cleanup

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc 
{
	if ( delegate ) {
		[delegate release];
	}
	[super dealloc];
}

// ____________________________________________________________________________________________________ touches

- (void)touchableViewDidChange:(TouchableView*)touchableView 
{
//	DLog(@"touchableViewDidChange");
	((WordClockGLView *)self.view).scale = touchableView.scale;
	((WordClockGLView *)self.view).translateX = touchableView.translationX;
	((WordClockGLView *)self.view).translateY = touchableView.translationY;
}

- (void)touchableViewTrackingTouchesEnded:(TouchableView*)touchableView 
{
//	DLog(@"touchableViewTrackingTouchesEnded");
	
	switch ( [WordClockPreferences sharedInstance].style  ) {
		case WCStyleLinear:
			[WordClockPreferences sharedInstance].linearTranslateX = touchableView.translationX;
			[WordClockPreferences sharedInstance].linearTranslateY = touchableView.translationY;
			[WordClockPreferences sharedInstance].linearScale = touchableView.scale;
			break;
		case WCStyleRotary:
			[WordClockPreferences sharedInstance].rotaryTranslateX = touchableView.translationX;
			[WordClockPreferences sharedInstance].rotaryTranslateY = touchableView.translationY;
			[WordClockPreferences sharedInstance].rotaryScale = touchableView.scale;
			break;
	}
	
	((WordClockGLView *)self.view).textureScalingEnabled = YES;
}

- (void)touchableViewTrackingTouchesBegan:(TouchableView*)touchableView 
{
//	DLog(@"touchableViewTrackingTouchesBegan");
	((WordClockGLView *)self.view).textureScalingEnabled = NO;
}

@end

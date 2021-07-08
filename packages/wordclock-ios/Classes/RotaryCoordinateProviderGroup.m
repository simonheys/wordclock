//
//  RotaryCoordinateProviderGroup.m
//  WordClock-iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "RotaryCoordinateProviderGroup.h"

const int kWCNumberOfFramesInRotationAnimation = 25;
const float kWCWheelSpacing = 3.0f;
//const float kWCEaseOvershoot = 1.70158f; // 2.0f;// 1.70158f;

@interface RotaryCoordinateProviderGroup (RotaryCoordinateProviderGroupPrivate)
	-(void)calculateMaximumLabelWidth;
	-(void)checkAngleConstraint;
	-(void)animateToAngle:(float)value;
	-(void)updateForSelectedIndex:(int)selectedIndex;
@end


@implementation RotaryCoordinateProviderGroup

-(id)initWithGroup:(WordClockWordGroup *)group
{
//	DLog(@"initWithGroup:%@",group);
	self = [super init];
	if (self != nil) {
		self.group = group;
		
		// word textures have already been created
		[self calculateMaximumLabelWidth];

		_displayedRadius = 0;
		_radius = 60.0f;
		_scaleFactor = 1.0f;
		self.angle = -1;
		
		[[NSNotificationCenter defaultCenter] 
			addObserver:self
			selector:@selector(logicWillChange:)
			name:kWordClockWordManagerLogicaAndLabelsWillChangeNotification 
			object:nil
		];

		[self.group addObserver:self
			forKeyPath:@"selectedIndex"
			options:NSKeyValueObservingOptionNew
			context:NULL
		];
		_observingGroup = YES;
		
		
//		DLog(@"_maximumLabelWidth:%f",_maximumLabelWidth);
	}
	return self;
}

// called once everything is connected up
-(void)establishInitialValues
{
	if ( self.group.selectedIndex != -1 ) {
		[self updateForSelectedIndex:self.group.selectedIndex];
	}
}


// stop observing our groups, they are about to change
-(void)logicWillChange:(NSNotification *)notification
{
	[self.group removeObserver:self
		forKeyPath:@"selectedIndex"
	];
	_observingGroup = NO;
}

// make sure angle is 0...2pi
-(void)checkAngleConstraint
{
	while ( self.angle >= 2*M_PI ) {
		self.angle -= 2*M_PI;
	}
	while ( self.angle < 0 ) {
		self.angle += 2*M_PI;	
	}		
}

-(void)update
{
	if ( _displayedRadius != _radius ) {
		_displayedRadius += ( _radius - _displayedRadius ) / 2.0f;
		if ( fabs( _displayedRadius - _radius ) < 0.5f) {
			_displayedRadius = _radius;
		}
	}
}

// this gets fired even when the rotary clock is nopt showing
// thats because it is monitoring the selected index of the group
// probably not much of an overhead to worry about

-(void)animateToAngle:(float)value
{

	if ( _angleTween ) {
		[_angleTween cancel];
		[_angleTween release];
	}
	_angleTween = [Tween  
		tweenWithTarget:self
		keyPath:@"angle" 
		toFloatValue:value 
		delay:0.0f 
		duration:0.3f 
		ease:kTweenEaseOutBack
	];
	
	[_angleTween retain];
	
}

- (void) dealloc
{
	if ( _angleTween ) {
		[_angleTween cancel];
		[_angleTween release];
	}
	
	[[NSNotificationCenter defaultCenter] 
		removeObserver:self 
		name:kWordClockWordManagerLogicaAndLabelsWillChangeNotification 
		object:nil
	];
	
	if ( _observingGroup ) {
		[self.group removeObserver:self
			forKeyPath:@"selectedIndex"
		];
	}
	
	[super dealloc];
}



-(void)calculateMaximumLabelWidth
{
	WordClockWord *word;
	_maximumLabelWidth = 0;
	
	for ( word in self.group.word ) {
		if ( word.unscaledSize.width > _maximumLabelWidth ) {
			_maximumLabelWidth = word.unscaledSize.width;
		}
	}
}

// ____________________________________________________________________________________________________ radius

-(void)parentOutsideRadiusWasUpdated
{
//	DLog(@"parentOutsideRadiusWasUpdated");
	float radius;
	
	radius = _parent ? [_parent outsideRadius] : _radius;
	
	if ( radius == _radius ) {
		return;
	}
	
	_radius = radius;
	
//	DLog(@"radius:%f",_radius);
	
	if ( _child ) {
		[_child parentOutsideRadiusWasUpdated];
	}
}

-(float)outsideRadius
{
	float width;
	// TODO this is a bit of a mouthful
	// AND the wheel spacing isn't consistent with word spacing
	
	if ( self.group.selectedIndex == -1 ) {
		return _radius;
	}
	
	
	WordClockWord *selectedWord;
	selectedWord = [self.group.word objectAtIndex:self.group.selectedIndex];
	width = self.group.selectedIndex == -1 ? 0 : selectedWord.unscaledSize.width;
	
	//word.spaceSize.width
	//return width < 2 ? _radius : _radius + width + kWCWheelSpacing * _scaleFactor;
	return width < 2 ? _radius : _radius + width + selectedWord.spaceSize.width * _scaleFactor;
}

- (void)updateForSelectedIndex:(int)selectedIndex
{
	float a;
	// will be -1 if it's the first time
	if ( -1 == self.angle ) {
		a =  2 * M_PI * (float)selectedIndex / self.group.numberOfWords;
		[self animateToAngle:a];
	}
	else {
		[self checkAngleConstraint];

		a = 2 * M_PI * (float)selectedIndex / self.group.numberOfWords;
		
		if ( (a - self.angle) > M_PI ) {
			// it's a long way, so go the other way round
			a -= 2*M_PI;
		}
		else if ( (a - self.angle) < -M_PI ) {
			// it's a long way, so go the other way round
			a += 2*M_PI;
		}
		
		[self animateToAngle:a];
	}
	
	if ( _child ) {
		[_child parentOutsideRadiusWasUpdated];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	int selectedIndex;
	
    if ([keyPath isEqual:@"selectedIndex"]) {
//		DLog(@"selectedIndex:%d", [[change objectForKey:NSKeyValueChangeNewKey] intValue]);
		
		selectedIndex = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
		
		[self updateForSelectedIndex:selectedIndex];
    }
	
//	DLog(@"_angle:%f",_angle);
}

@synthesize angle = _angle;
@synthesize radius = _radius;
@synthesize scaleFactor = _scaleFactor;
@synthesize maximumLabelWidth = _maximumLabelWidth;
@synthesize group = _group;
@synthesize parent = _parent;
@synthesize child = _child;
@synthesize displayedRadius = _displayedRadius;
@end

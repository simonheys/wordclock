//
//  ColourWellControl.h
//  iphone_custom_button
//
//  Created by Simon on 11/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColourWellControl : UIControl {
	UIColor *_colour;
	UIImage *_colourWellEmboss;
	UIImage *_colourWellHighlight;
}
-(void)setColour:(UIColor *)colour;
@end

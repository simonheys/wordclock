//
//  image_utilities.c
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//
/*
 *  image_utilities.c
 *  iphone_custom_button
 *
 *  Created by Simon on 10/03/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "image_utilities.h"
	
CGContextRef CreateARGBBitmapContext(size_t pixelsWide, size_t pixelsHigh )
{
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
//	void *          bitmapData;
//	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
//	size_t pixelsWide = CGImageGetWidth(inImage);
//	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
//	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	/*
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate(
		bitmapData,
		pixelsWide,
		pixelsHigh,
		8,      // bits per component
		bitmapBytesPerRow,
		colorSpace,
		kCGBitmapByteOrder32Big|kCGImageAlphaPremultipliedFirst
	);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	*/
	
	context = CGBitmapContextCreate(
		NULL,
		pixelsWide,
		pixelsHigh,
		8,      // bits per component
		bitmapBytesPerRow,
		colorSpace,
		kCGBitmapByteOrder32Big|kCGImageAlphaPremultipliedFirst
	);

	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	CGContextClearRect(context, CGRectMake(0, 0, pixelsWide, pixelsHigh));
	return context;
}

/*
 *  sin_and_cos_tables.h
 *  iphone_word_clock_open_gl
 *
 *  Created by Simon on 22/02/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import "math.h"

#define SIN_TABLE_SIZE		4096
#define SIN_TABLE_BITMASK	4095

float _sinTable[SIN_TABLE_SIZE];
float _cosTable[SIN_TABLE_SIZE];

void buildSinAndCosTables();

static inline float getSinFromTable(float d)
{
	return _sinTable[(int)(d * 651.8986469f) & SIN_TABLE_BITMASK];
}

static inline float getCosFromTable(float d)
{
	return _cosTable[(int)(d * 651.8986469f) & SIN_TABLE_BITMASK];
}
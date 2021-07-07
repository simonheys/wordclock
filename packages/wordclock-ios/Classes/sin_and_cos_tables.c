/*
 *  sin_and_cos_tables.c
 *  iphone_word_clock_open_gl
 *
 *  Created by Simon on 22/02/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "sin_and_cos_tables.h"

void buildSinAndCosTables()
{
	for ( int i = 0; i < SIN_TABLE_SIZE; i++ ) {
		_sinTable[i] = sinf( 2 * M_PI * i / SIN_TABLE_SIZE );
		_cosTable[i] = cosf( 2 * M_PI * i / SIN_TABLE_SIZE );
	}
}
